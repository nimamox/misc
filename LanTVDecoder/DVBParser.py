# Copyright Nima Mohammadi, 2012
DVB_PACKET_LENGTH = 188

def print_binary_seq(seq):
    print ("%02X "*len(seq)) % tuple(map(ord, seq))
    
def slice_bit(b, low_bit, high_bit = None):
    if not high_bit:
        high_bit = low_bit
    b &= 2 ** high_bit - 1
    b >>= low_bit - 1
    return b

def processCAT(p):
    CAT_table = {}
    #current_next_indicator = slice_bit(ord(p[10]), 1)
    section_length = slice_bit(ord(p[6]) << 8 | ord(p[7]), 1, 12)
    if section_length > DVB_PACKET_LENGTH - 8:
        return False
    total_descriptors_length = section_length - 9
    if total_descriptors_length > 0:
        i = 0
        while i < total_descriptors_length:
            descriptor_tag = ord(p[13 + i])
            descriptor_length = ord(p[14 + i])
            if descriptor_tag == 0x09:
                ca_system_id = ord(p[15 + i]) << 8 | ord(p[16 + i])
                ca_pid = slice_bit(ord(p[17 + i]) << 8 | ord(p[18 + i]), 1, 13)
            #print "%X" % descriptor_tag, descriptor_length
            #print "%X: %X(%d)" % (ca_system_id, ca_pid, ca_pid)
            CAT_table[ca_system_id] = ca_pid
            i += 2 + descriptor_length 
    return CAT_table

def processPAT(p):
    PAT_table = {}
    section_length = slice_bit(ord(p[6]) << 8 | ord(p[7]), 1, 12)
    if section_length > DVB_PACKET_LENGTH - 8:
        return False
    total_services = (section_length - 9) / 4
    for i in xrange(total_services):
        sid = ord(p[13+(i*4)]) << 8 | ord(p[14+(i*4)])
        pmt = slice_bit(ord(p[15+(i*4)]) << 8 | ord(p[16+(i*4)]), 1, 13)
        PAT_table[sid] = pmt
    return PAT_table
    
def processPMT(p, length):
    PMT_table = {}
    PMT_table['ECMs'] = {}
    PMT_table['ESs'] = {}
    #current_next_indicator = slice_bit(ord(p[10]), 1)
    #print 'current_next_indicator:', current_next_indicator
    section_length = slice_bit(ord(p[6]) << 8 | ord(p[7]), 1, 10)
    if section_length > length - 8:
        return False
    program_info_length = slice_bit(ord(p[15]) << 8 | ord(p[16]), 1, 12)
    remaining_bytes = (section_length - program_info_length - 13)
    
    if program_info_length > 0:
        i = 0
        while i < program_info_length:
            descriptor_tag = ord(p[17 + i])
            descriptor_length = ord(p[18 + i])
            if descriptor_tag == 0x09:
                ca_system_id = ord(p[19 + i]) << 8 | ord(p[20 + i])
                ca_pid = slice_bit(ord(p[21 + i]) << 8 | ord(p[22 + i]), 1, 13)
                #print 'system: %X, caid: %d' % (ca_system_id, ca_pid)
                PMT_table['ECMs'][ca_system_id] = ca_pid
            i += 2 + descriptor_length
    i = 0
    while i < remaining_bytes:
        stream_type = ord(p[i + 17 + program_info_length])
        elementary_pid = slice_bit(ord(p[i + 18 + program_info_length]) << 8 | ord(p[i + 19 + program_info_length]), 1, 13)
        ES_info_length = slice_bit(ord(p[i + 20 + program_info_length]) << 8 | ord(p[i + 21 + program_info_length]), 1, 10)
        #PMT_table[elementary_pid] = stream_type
        #print "ES %d %d %d" % (elementary_pid, stream_type, ES_info_length)
        PMT_table['ESs'][elementary_pid] = {'elementary_pid': elementary_pid, 'stream_type': stream_type, 'tags': {}}
        #print 'X', ES_info_length
        if ES_info_length > 0:
            j = 0
            while j < ES_info_length:
                descriptor_tag = ord(p[i + 22 + program_info_length + j])
                descriptor_length = ord(p[i + 23 + program_info_length + j])
                if descriptor_tag == 0x09:
                    ca_system_id = ord(p[24 + i + program_info_length + j]) << 8 | ord(p[25 + i + program_info_length + j])
                    ca_pid = slice_bit(ord(p[26 + i + program_info_length + j]) << 8 | ord(p[27 + i + program_info_length + j]), 1, 13)                    
                    PMT_table['ECMs'][ca_system_id] = ca_pid                
                #print 'Xdesc (%02X): ' % descriptor_tag, 17 + i, descriptor_length
                #PMT_table['ESs'][elementary_pid]['tags'] = (descriptor_tag, None)
                j += 2 + descriptor_length 
        #print '\t %X %X %X' % (ord(p[i + 21 + program_info_length]), ord(p[i + 22 + program_info_length]), ord(p[i + 23 + program_info_length]))
        i += 5 + ES_info_length 
    return PMT_table
