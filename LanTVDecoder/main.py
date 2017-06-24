# Copyright Nima Mohammadi, 2012
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import thread
import sys
import socket
import win32con
import ctypes as C
import Queue
import DVBParser
import time
import datetime
import select
import win32gui
import ConfigParser
import os
libc = C.CDLL('msvcrt.dll')

DVB_PACKET_LENGTH = 188
BUFFER_LENGTH = 188 * 2048
justConnected = False
HWND = None

config = ConfigParser.ConfigParser()
config.read('config.ini')
if not config.has_section('Main'):
    print "Error: Malformed configuration file: The Configuration file must have a section named 'Main'."
    sys.exit(1)


FilterCallback = C.CFUNCTYPE(None, C.c_int, C.c_int, C.c_voidp)

MDAPI_GET_VERSION = 0x01020100
MDAPI_GET_PROGRAMM = 0x01020010
MDAPI_START_FILTER = 0x01020020
MDAPI_STOP_FILTER = 0x01020021
MDAPI_DVB_COMMAND = 0x01020060
LOG_MESSAGE = 0x00030201



class TCA_System(C.Structure):
    _fields_ = [("ca_type", C.c_ushort),
                ("ecm", C.c_ushort),
                ("emm", C.c_ushort),
                ("provider_id", C.c_uint)]

class PID_FILTER(C.Structure):
    _fields_ = [("filter_name", C.c_char * 5),
		("filter_id", C.c_char),
		("PID", C.c_int16)]

class TProgramm(C.Structure):
    _fields_ = [("name", C.c_char * 30),
                ("provider", C.c_char * 30),
                ("country", C.c_char * 30),
                ("frequency", C.c_ulong),
                ("type", C.c_int8),
                ("voltage", C.c_int8),
                ("afc", C.c_int8),
                ("diseqc", C.c_int8),
                ("symbolrate", C.c_uint),
                ("quam", C.c_int8),
                ("fec", C.c_int8),
                ("tvnorm", C.c_int8),
                ("tpid", C.c_int16),
                ("vpid", C.c_int16),
                ("apid", C.c_int16),
                ("tpid", C.c_int16),
                ("pmt", C.c_int16),
                ("pcr", C.c_int16),
                ("ecm", C.c_int16),
                ("sid", C.c_int16),
                ("ac3", C.c_int16),
                ("tvtype", C.c_int8),
                ("servicetype", C.c_int8),
                ("ca_id", C.c_int8),
                ("temp_audio", C.c_int16),
                ("filter_count", C.c_int16),
                ("filters", PID_FILTER * 32),
                ("ca_count", C.c_int16),
                ("ca_system", TCA_System * 32),
                ("ca_country", C.c_char * 5),
                ("merker", C.c_int8),
                ("link_tp", C.c_int16),
                ("link_sid", C.c_int16),
                ("dynamic", C.c_int8),
                ("extern_buffer", C.c_char * 16),
                ]
    
class FilterInfo(C.Structure):
    _fields_ = [("plugin_id", C.c_int16),
                ("filter_id", C.c_int16),
                ("pid", C.c_int16),
                ("name", C.c_char * 32),
                ("function_pointer", C.c_ulong),
                ("running_id", C.c_int),
                ("filter_type", C.c_int)
        ]
class TDVB_COMMAND(C.Structure):
    _fields_ = [("length", C.c_int16),
                ("buf", C.c_uint8 * 32)]
    
class DCW(C.Structure):
    _fields_ = [("number", C.c_longlong),
                ("key", C.c_byte * 8)]
    
def LOG(msg, color = None):
    if color:
        msg = '<span style="color:%s">%s</span>' % (color, msg)
    msg = '<b>' + msg + '</b>'
    msg = '<span style="color:#AAAAAA">' + time.strftime("%H:%M:%S ") + '</span>' + msg
    buf_ptr = libc.malloc(len(msg)+1)
    libc.strcpy(buf_ptr, msg)
    win32gui.PostMessage(HWND, win32con.WM_USER, LOG_MESSAGE, buf_ptr)

class Buffer(object):
    def __init__(self, length):
        self.buf = C.create_string_buffer(length)
        self.length = length
        self.lrp = 0 # last read position
        self.lwp = 0 # last write position
        
    def append(self, str):
        strlen = len(str)
        e = self.lwp + strlen
        if e > self.length - 1:
            p = self.length - self.lwp
            self.buf[self.lwp:] = str[:p]
            self.lwp = e - self.length
            self.buf[:self.lwp] = str[p:]
        else:
            self.buf[self.lwp:self.lwp + strlen] = str
            self.lwp = self.lwp + strlen
            
    def cached_stream_len(self):
        if self.lwp > self.lrp:
            return self.lwp - self.lrp
        else:
            return self.length - self.lrp + self.lwp
        
    def get_packets(self):
        packets = []
        packet_numbers = self.cached_stream_len() // DVB_PACKET_LENGTH
        for p in xrange(packet_numbers):
            packet = C.create_string_buffer(DVB_PACKET_LENGTH)
            packetStart = self.lrp
            packetEnd = self.lrp + DVB_PACKET_LENGTH
            if packetStart > self.length:
                packetStart %= self.length
            if packetEnd > self.length:
                packetEnd %= self.length
            if packetStart > packetEnd:
                #libc.memcpy(packet, C.byref(self.buf, packetStart), self.length-packetStart)
                #libc.memcpy(C.byref(packet, self.length-packetStart), self.buf, packetEnd)
                packets.append((self.buf, packetStart, self.length-packetStart, packetEnd))
            else:
                #libc.memcpy(packet, C.byref(self.buf, packetStart), DVB_PACKET_LENGTH)
                packets.append((self.buf, packetStart, DVB_PACKET_LENGTH))
            self.lrp = (self.lrp + DVB_PACKET_LENGTH) % self.length
        return packets
    def reset(self):
        self.lrp = 0
        self.lwp = 0

def producer(queue, host, port):
    global kill_received, justConnected
    buf = Buffer(BUFFER_LENGTH)
    while True:
        while True:
            try:
                if kill_received:
                    return
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.connect((host, port))
                break
            except socket.error, e:
                s.close()
                LOG("Attempt to connect to %s:%s failed. Retrying in 3 seconds..." % (host, port), color='#FF0000')
                time.sleep(3)
        justConnected = True
        LOG("Connected to %s:%d" % (host, port), color='#00FF00')
        s.send('GET /bbc HTTP/1.0\n\n')
        buf.reset()
        time.sleep(0.5)
        flag = 0
        pos = 0
        attempt = 0
        while True:
            if kill_received:
                return
            try:
                data = s.recv(20:48)
            except socket.error, e
                if e.errno == 10054:
                    attempt = 3
                    data = ''
            if (not flag):
                pos = data.find("\r\n\r\n")
                data = data[pos+4:]
                flag = 1
            if len(data) > 0:
                buf.append(data)
                packets = buf.get_packets()
                for p in packets:
                    queue.put(p)
            elif attempt < 3:
                attempt += 1
                time.sleep(0.1)
            else:
                LOG("Disconected", color="#FF0000")
                s.close()
                time.sleep(1)
                break
                

def accept(conn, clients):
    def threaded():
        while True:
            try:
                req = conn.recv(1024)
            except socket.error:
                continue
            conn.sendall('HTTP/1.1 200 OK\r\n')
            conn.sendall('Content-Type: application/octet-stream\r\n')
            #conn.sendall('Date: Thu, 20 Jul 2012 19:10:59 GMT\r\n')
            conn.sendall('Pragma: no-cache\r\n')
            conn.sendall('Cache-Control: no-cache\r\n')
            conn.sendall('Connection: close\r\n\r\n')      
            LOG("New connection established %s:%d" % conn.getpeername())
            clients.append(conn)
            break
    thread.start_new_thread(threaded, ())
def serving_clients(clients, port):
    LOG('Listening on 0.0.0.0:%d' % port, color='#00FF00')
    dock_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    dock_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    dock_socket.setblocking(False)
    dock_socket.bind(('', port))
    dock_socket.listen(1)    
    while True:
        while True:
            try:
                conn = dock_socket.accept()[0]
            except socket.error:
                break
            accept(conn, clients)
        time.sleep(.2)

class DigitalTimer(QLCDNumber):
    def __init__(self, parent = None):
        QLCDNumber.__init__(self, parent)
        self.setSegmentStyle(QLCDNumber.Filled)
        self.initTime = datetime.datetime.now()
        self.setToolTip(self.initTime.strftime("%d/%m/%y %H:%M:%S"))
        self.showTime()
        timer = QTimer(self)
        timer.start(1000)
        self.connect(timer, SIGNAL('timeout()'), self.showTime)
    def showTime(self):
        currentTime = datetime.datetime.now()
        delta = currentTime - self.initTime
        hours, remainder = divmod(delta.seconds + delta.days * 3600 * 24, 3600)
        minutes, seconds = divmod(remainder, 60)
        delta_str = "%02d:%02d:%02d" % (hours, minutes, seconds)
        self.setNumDigits(len(delta_str))
        self.display(delta_str)
        
class MyDialog(QDialog):
    def __init__(self, parent = None):
        global HWND
        QDialog.__init__(self, parent)
        self.setWindowTitle("LanTV Scrambled TV Decoder")
        self.q = Queue.Queue()
        self.clients = []
        self.receivedKey = False
        self.SID = None
        self.PAT_table = None
        self.CAT_table = None
        self.PMT_table = None
        HWND = int(self.winId())
        self.filter_packet = C.create_string_buffer(DVB_PACKET_LENGTH)
        self.tmp_packet = C.create_string_buffer(DVB_PACKET_LENGTH)
        self.encrypted_packets = []
        self.cluster = (C.c_char_p * 5)()
        self.filters = {}
        self.pluginLoaded = False
        #self.dumpfile = open(r'encrypted.ts', 'wb')
        self.decrypted_dumpfile = None
        layout = QGridLayout()
        clientsLabel = QLabel("Clients:")
        self.clientsCounter = QLCDNumber(3)
        uptimeLabel = QLabel("Uptime:")
        uptimeCounter= DigitalTimer()
        timer = QTimer(self)
        timer.start(1000)
        self.connect(timer, SIGNAL('timeout()'), self.updateClientsCounter)
        evenKeyLabel = QLabel("Even Key:")
        self.evenKeyWidget = QLineEdit()
        self.evenKeyWidget.setMinimumWidth(130)
        self.evenKeyWidget.setReadOnly(True)
        oddKeyLabel = QLabel("Odd Key:")
        self.oddKeyWidget = QLineEdit()
        self.oddKeyWidget.setReadOnly(True)
        self.recordingBtn = QPushButton("Start Recording")
        self.recordingBtn.setCheckable(True)
        self.recordingBtn.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.MinimumExpanding)
        self.connect(self.recordingBtn, SIGNAL('clicked()'), self.capture)
        copyLogBtn = QPushButton('Copy to Clipboard')
        self.connect(copyLogBtn, SIGNAL('clicked()'), self.copyToClipboard)
        saveLogBtn = QPushButton('Save to file')
        self.logViewer = QPlainTextEdit()
        layout.addWidget(clientsLabel, 0, 0)
        layout.addWidget(self.clientsCounter, 0, 1)
        layout.addWidget(uptimeLabel, 1, 0)
        layout.addWidget(uptimeCounter, 1, 1)
        layout.setColumnMinimumWidth(2, 50)
        layout.addWidget(evenKeyLabel, 0, 3)
        layout.addWidget(self.evenKeyWidget, 0, 4)
        layout.addWidget(oddKeyLabel, 1, 3)
        layout.addWidget(self.oddKeyWidget, 1, 4)
        layout.addWidget(self.recordingBtn, 0, 5, 2, 1)
        layout.addWidget(copyLogBtn, 4, 5, 1, 1)
        layout.addWidget(saveLogBtn, 5, 5, 1, 1)
        layout.addWidget(self.logViewer, 2, 0, 4, 5)
        self.setLayout(layout)
        
    def printPAT(self):
        print self.PAT_table
    
    def printCAT(self):
        print self.CAT_table
    
    def printPMT(self):
        print self.PMT_table
        
    def copyToClipboard(self):
        clipboard = qApp.clipboard()
        clipboard.setText(self.logViewer.toPlainText())
    
    def capture(self):
        if self.recordingBtn.isChecked():
            self.recordingBtn.setText("Stop Recording")
            filename = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S") + '.ts'
            self.decrypted_dumpfile = libc.fopen("Captured/" + filename, "wb")
        else:
            self.recordingBtn.setText("Start Recording")
            libc.fclose(self.decrypted_dumpfile)
            self.decrypted_dumpfile = None
    
    def updateClientsCounter(self):
        clinet_count = len(self.clients)
        if clinet_count != self.clientsCounter.value():
            self.clientsCounter.setSegmentStyle(QLCDNumber.Filled)
        else:
            self.clientsCounter.setSegmentStyle(QLCDNumber.Outline)
        self.clientsCounter.display(clinet_count)
        
    def loadPlugin(self):
        LOG("Loading Plugin")
        for f in os.listdir("Plugin"):
            if f.endswith('.dll'):
                plugin = f
                break
        else:
            print "Error: Plugin is not found."
            sys.exit(1)
        self.dll = C.cdll.LoadLibrary("Plugin\\" + plugin)
        self.ffdecsa = C.windll.LoadLibrary("FFDecsa.dll")
        self.internal_parallelism = self.ffdecsa.get_parallelism()
        self.keys = (C.c_char * self.ffdecsa.get_keyset_size())()
        self.even = (C.c_char * 16)()
        self.odd = (C.c_char * 16)()
        name = C.create_string_buffer(128)
        self.dll.On_Send_Dll_ID_Name(name)
        LOG(name.value + ' is loaded', color='#00FF00')
        self.hinstance = C.windll.kernel32.GetModuleHandleA(None)
        hotkey = C.c_char()
        keepMeRunning = C.c_int(1)
        self.dll.On_Start(self.hinstance, HWND, False, 10, C.byref(hotkey), "MD-API Version 01.02 - 1.06", C.byref(keepMeRunning))
        self.pluginLoaded = True
        
    def unloadPlugin(self):
        self.dll.On_Exit(self.hinstance, HWND, False)
        
    def changeChannel(self):
        tp = TProgramm()
        C.memset(C.pointer(tp), 0, C.sizeof(tp))
        self.fillTPStructure(C.pointer(tp))
        self.dll.On_Channel_Change(tp)
    def winEvent(self, msg):
        if msg.message == win32con.WM_USER:
            if msg.wParam == MDAPI_GET_VERSION:
                LOG("GET_VERSION")
                libc.strcpy(msg.lParam, "MD-API Version 01.02 - 1.06")
                return True, id(msg)
            elif msg.wParam == MDAPI_GET_PROGRAMM:
                LOG("GET_PROGRAMM")
                C.memset(msg.lParam, 0, C.sizeof(TProgramm))
                self.fillTPStructure(msg.lParam)
                return True, id(msg)
            elif msg.wParam == MDAPI_START_FILTER:
                filter_info = C.cast(msg.lParam, C.POINTER(FilterInfo))
                LOG("START_FILTER id: %d, pid: %d" % (filter_info.contents.filter_id, filter_info.contents.pid))
                self.filters[filter_info.contents.pid] = {'filter_id': filter_info.contents.filter_id, 
                                                          'function_pointer': FilterCallback(filter_info.contents.function_pointer)}
                return True, id(msg)
            elif msg.wParam == MDAPI_STOP_FILTER:
                LOG("STOP_FILTER " + str(msg.lParam))
                self.filter = []
            elif msg.wParam == MDAPI_DVB_COMMAND:
                LOG("DVB_COMMAND")
                self.dvbCommand(msg.lParam)
                return True, id(msg)
            elif msg.wParam == LOG_MESSAGE:
                #print "LOG_MESSAGE"
                message = C.cast(msg.lParam, C.c_char_p).value
                libc.free(msg.lParam)
                self.logViewer.appendHtml(message)
                return True, id(msg)
            else:
                LOG("Unknown command: %x" % msg.wParam)
        return False, id(msg)
    
    def onLoad(self):
        try:
            host = config.get('Main', 'host')
            port = config.getint('Main', 'port')
            path = config.get('Main', 'path')
        except (ConfigParser.NoOptionError, ValueError):
            print "Error: Malformed configuration file: The 'Main' section must contain at least host, port and path options."
            sys.exit(1)
        try:
            listerining_port = config.getint('Main', 'listening-port')
        except:
            listerining_port = 5030
        thread.start_new_thread(producer, (self.q, host, port))
        thread.start_new_thread(serving_clients, (self.clients, listerining_port))
        QTimer.singleShot(0, self.consumer)
        QTimer.singleShot(0, self.loadPlugin)
    def consumer(self):
        global justConnected
        i = 1
        while not self.q.empty():
            if not i %  30:
                QApplication.processEvents()
            if not i % 30000:
                i = 1
            i += 1
            p_pointers = self.q.get()

            if len(p_pointers) == 3:
                p = C.cast(C.byref(p_pointers[0], p_pointers[1]), C.POINTER(C.c_char))
            else:
                libc.memcpy(self.tmp_packet, C.byref(p_pointers[0], p_pointers[1]), p_pointers[2])
                libc.memcpy(C.byref(self.tmp_packet, p_pointers[2]), p_pointers[0], p_pointers[3])
                p = self.tmp_packet
            pid = DVBParser.slice_bit(ord(p[1]) << 8 | ord(p[2]), 1, 13)

            if self.filters.has_key(pid):
                libc.memcpy(self.filter_packet, p, DVB_PACKET_LENGTH)
                #print "Called filter", self.filters[pid]['filter_id']
                self.filters[pid]['function_pointer'](self.filters[pid]['filter_id'], DVB_PACKET_LENGTH-4, C.byref(self.filter_packet, 4))

            if self.receivedKey:
                self.encrypted_packets.append(p_pointers)
                if len(self.encrypted_packets) >= 8:#self.internal_parallelism * 2:
                    packet = self.encrypted_packets[0]
                    q_start_pointer = C.byref(packet[0])
                    start_pointer = C.byref(packet[0], packet[1])
                    self.cluster[0] = C.cast(C.byref(packet[0], packet[1]), C.c_char_p)
                    broken = False
                    last_packet = None
                    for packet in self.encrypted_packets:
                        if last_packet and packet[1] < last_packet[1]:
                            broken = True
                            mid_pointer = C.byref(packet[0], BUFFER_LENGTH)
                            self.cluster[1] = C.cast(mid_pointer, C.c_char_p)
                            self.cluster[2] = C.cast(C.byref(packet[0]), C.c_char_p)
                        last_packet = packet
    
                    if broken:
                        if len(packet) == 4:
                            end_pointer = C.byref(packet[0], packet[3])
                            self.cluster[3] = C.cast(C.byref(packet[0], packet[3]), C.c_char_p)
                            self.cluster[4] = None
                        else:
                            end_pointer = C.byref(packet[0], packet[1]+packet[2])
                            self.cluster[3] = C.cast(C.byref(packet[0], packet[1]+packet[2]), C.c_char_p)
                            self.cluster[4] = None                        
                    else:
                        end_pointer = C.byref(packet[0], packet[1]+packet[2])
                        self.cluster[1] = C.cast(C.byref(packet[0], packet[1]+packet[2]), C.c_char_p)
                        self.cluster[2] = None
                    p = 0
                    while p < len(self.encrypted_packets):
                        p += self.ffdecsa.decrypt_packets(C.byref(self.cluster), C.byref(self.keys))
                        if not p:
                            break
                    del self.encrypted_packets[:]
                    if not broken:
                        cluster_length = C.cast(end_pointer, C.c_void_p).value - C.cast(start_pointer, C.c_void_p).value
                    else:
                        first_chunk_length = C.cast(mid_pointer, C.c_void_p).value - C.cast(start_pointer, C.c_void_p).value
                        second_chunk_length = C.cast(end_pointer, C.c_void_p).value - C.cast(q_start_pointer, C.c_void_p).value                        
                    if self.decrypted_dumpfile:
                        if not broken:
                            libc.fwrite(start_pointer, cluster_length, 1, self.decrypted_dumpfile)
                        else:
                            libc.fwrite(start_pointer, first_chunk_length, 1, self.decrypted_dumpfile)
                            libc.fwrite(q_start_pointer, second_chunk_length, 1, self.decrypted_dumpfile)
                    p1 = C.cast(start_pointer, C.POINTER(C.c_char))
                    if broken:
                        p2 = C.cast(q_start_pointer, C.POINTER(C.c_char))
                    if self.clients:
                        rfds, wfds, xfds = select.select(self.clients, self.clients, self.clients, 0.1)
                        #print rfds, wfds, xfds
                        for conn in wfds:
                            try:
                                if broken:
                                    conn.send(p1[:first_chunk_length] + p2[:second_chunk_length])
                                else:
                                    conn.send(p1[:cluster_length]),
                            except socket.error, e:
                                pass
                                #LOG("Socket error in send() for %s %s" % (conn.getpeername(), e))
                        for conn in rfds:
                            try:
                                conn.recv(512)
                            except socket.error, e:
                                LOG("Client disconnected: %s:%d" % conn.getpeername())
                                self.clients.remove(conn)
                    
            #Process PAT
            if pid == 0 and not self.PAT_table:
                LOG("PAT Received", color='#00FF00')
                #print ("%02X "*188) % tuple(map(ord, p))
                payload_usi = DVBParser.slice_bit(ord(p[1]), 7)
                if payload_usi:
                    self.PAT_table = DVBParser.processPAT(p)
                    if not self.PAT_table:
                        self.last_packet = p
                    else:
                        self.SID = self.PAT_table.keys()[0]
                else:
                    p2 = C.create_string_buffer(DVB_PACKET_LENGTH * 2)
                    libc.memcpy(p2, self.last_packet, DVB_PACKET_LENGTH)
                    libc.memcpy(C.byref(p2, DVB_PACKET_LENGTH), byref(p, 4), DVB_PACKET_LENGTH-4)
                    self.PAT_table = DVBParser.processPAT(p2)
                    self.SID = self.PAT_table.keys()[0]
            #Process CAT
            if pid == 1 and self.CAT_table == None:
                LOG("CAT Received", color='#00FF00')
                #print ("%02X "*188) % tuple(map(ord, p))
                payload_usi = DVBParser.slice_bit(ord(p[1]), 7)
                if payload_usi:
                    self.CAT_table = DVBParser.processCAT(p)
                    if not self.CAT_table:
                        self.last_packet = p
                else:
                    p2 = C.create_string_buffer(DVB_PACKET_LENGTH * 2)
                    libc.memcpy(p2, self.last_packet, DVB_PACKET_LENGTH)
                    libc.memcpy(C.byref(p2, DVB_PACKET_LENGTH), C.byref(p, 4), DVB_PACKET_LENGTH-4)
                    self.CAT_table = DVBParser.processCAT(p2)
            #Process PMT
            if self.PAT_table and not self.PMT_table and pid == self.PAT_table[self.SID]:
                LOG("PMT Revceived", color='#00FF00')
                #print ("%02X "*188) % tuple(map(ord, p))
                payload_usi = DVBParser.slice_bit(ord(p[1]), 7)
                if payload_usi:
                    self.PMT_table = DVBParser.processPMT(p)
                    if not self.PMT_table:
                        self.last_packet = p
                else:
                    p2 = C.create_string_buffer(DVB_PACKET_LENGTH * 2)
                    libc.memcpy(p2, self.last_packet, DVB_PACKET_LENGTH)
                    libc.memcpy(C.byref(p2, DVB_PACKET_LENGTH), C.byref(p, 4), DVB_PACKET_LENGTH-4)
                    self.PMT_table = DVBParser.processPMT(p2)
            if self.PAT_table and self.PMT_table and self.CAT_table and justConnected:
                justConnected = False
                QTimer.singleShot(1000, self.changeChannel)
        QApplication.processEvents()
        QTimer.singleShot(40, self.consumer)
        
    def fillTPStructure(self, tp_pointer):
        tp = C.cast(tp_pointer, C.POINTER(TProgramm))
        tp.contents.name = "Channel"
        if len(self.PAT_table) != 1:
            LOG("Error: PAT contains more than one service!")
        tp.contents.pmt = self.PAT_table[self.SID]
        tp.contents.sid = self.SID
        i = 0
        for ca in self.PMT_table['ECMs']:
            tp.contents.ca_system[i].ca_type = ca
            tp.contents.ca_system[i].ecm = self.PMT_table['ECMs'][ca]
            tp.contents.ca_system[i].emm = self.PMT_table['ECMs'][ca]
            i += 1
        tp.contents.ecm = self.PMT_table['ECMs'][ca]
        tp.contents.ca_count = i + 1
        
    def dvbCommand(self, command_ptr):
        dvb_command = C.cast(command_ptr, C.POINTER(TDVB_COMMAND))
        self.receivedKey = True
        #print "Command len: ", dvb_command.contents.length
        isOddKey = bool(dvb_command.contents.buf[4] )
        dcw = DCW()
        for i in xrange(4):
            dcw.key[i * 2] = dvb_command.contents.buf[6 + i * 2 + 1]
            dcw.key[i * 2 + 1] = dvb_command.contents.buf[6 + i * 2]
        key = ''
        for i in range(6, 14, 2):
            key += "%04X " % ((dvb_command.contents.buf[i+1] << 8) | dvb_command.contents.buf[i])
        if isOddKey:
            self.oddKeyWidget.setText(key)
            #self.oddKeyWidget.setFocus(Qt.MouseFocusReason)
        else:
            self.evenKeyWidget.setText(key)
            #self.evenKeyWidget.setFocus(Qt.MouseFocusReason)
        LOG((isOddKey and "Odd  " or "Even ") + key)
        if isOddKey:
            for i in range(0, 8, 2):
                self.odd[i+1] = chr(dvb_command.contents.buf[i+6])
                self.odd[i] = chr(dvb_command.contents.buf[i+7])            
            #fodd = open(r"odd.key", "a")         
            #for i in range(6, 14, 2):
            #    fodd.write("%04X " % ((dvb_command.contents.buf[i+1] << 8) | dvb_command.contents.buf[i]))
            #fodd.write("\n")
            #fodd.close()
        else:
            for i in range(0, 8, 2):
                self.even[i+1] = chr(dvb_command.contents.buf[i+6])
                self.even[i] = chr(dvb_command.contents.buf[i+7])
            #feven = open(r"even.key", "a")
            #for i in range(6, 14, 2):
                #feven.write("%04X " % ((dvb_command.contents.buf[i+1] << 8) | dvb_command.contents.buf[i]))
            #feven.write("\n")
            #feven.close()
        self.ffdecsa.set_control_words(C.byref(self.even), C.byref(self.odd), C.byref(self.keys))

    def closeEvent(self, e):
        global kill_received
        kill_received = True
        
            
kill_received = False   
app = QApplication(sys.argv)
app.setStyle("Cleanlooks")
#Dialog = type('ProgDvbEngineCommandWindow', (MyDialog,), {})
dlg = MyDialog()
QTimer.singleShot(0, dlg.onLoad)
dlg.show()
app.exec_()
