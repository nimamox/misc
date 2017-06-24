# -*- coding: utf-8 -*-
import os

source_dir = "/Users/nima/Babaali/NER-data"
target_dir = "/Users/nima/Babaali/NER-data2"
classes = set()
tags = set()
delms = set()

for filename in os.listdir(source_dir):
    if filename.startswith('.'):
        continue
    with open(os.path.join(target_dir, filename), 'w') as fh2:
        with open(os.path.join(source_dir, filename)) as fh:
            print filename
            flg = False
            buf = []
            for line in fh:
                if not flg:
                    flg = True
                    continue
                spl_line = line.split()
                if spl_line[2] == 'DELM':
                    delms.add(' '.join(spl_line[4:-1]))
                #tags.add(spl_line[2])
                word = '‌'.join(spl_line[4:-1])
                if word in ['.', '!', '؟', '؛'] and buf:
                    fh2.write(' '.join(buf))
                    buf = []
                    fh2.write('\n')
                else:
                    buf.append(word)
            if buf:
                fh2.write(' '.join(buf))
                buf = []
                fh2.write('\n')                
                #print ' '.join(spl_line[4:-1]),
            #print
print 'DELMS:'
for i, delm in enumerate(delms):
    print delm, 