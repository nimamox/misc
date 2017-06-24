# -*- coding: utf-8 -*-

import os

source_dir = "/home/nima/WIKI/extracted/"
output_file = open("wiki_out.txt", 'w')

sentences = set()

for directory in os.listdir(source_dir):
    if directory.startswith('.'):
        continue    
    for filename in os.listdir(os.path.join(source_dir, directory)):
        if filename.startswith('.'):
            continue
        with open(os.path.join(source_dir, directory, filename)) as fh:
            print fh.name
            for line in fh:
                if len(line) < 10:
                    continue
                if line.startswith('<'):
                    continue
                elif line.startswith('='):
                    continue
                elif '[' in line:
                    continue
                line = line.replace('،', '').replace('؛', '').strip().split('.')
                for s1 in line:
                    for s2 in s1.split('؟'):
                        for s3 in s2.split('!'):
                            for s4 in s3.split(':'):
                                s4 = s4.strip()
                                if s4.startswith("="):
                                    continue
                                sentences.add(s4)

for s in sentences:
    output_file.write(s)
    output_file.write('\n')
output_file.close()

