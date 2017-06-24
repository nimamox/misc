# -*- coding: utf-8 -*-

import os, gensim

source_dir = "/Users/nima/Babaali/NER-data"
stoplist_path = "/Users/nima/Babaali/stoplist.txt"
stoplist = set(open(stoplist_path, 'r').read().split())

model = gensim.models.Word2Vec.load('word2vec_fawiki.model')

def iterate_words(source_dir):
    for filename in os.listdir(source_dir):
        if filename.startswith('.'):
            continue
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
                    continue
                word = '‌'.join(spl_line[4:-1])
                if word in stoplist:
                    continue
                cls = spl_line[-1]
                try:
                    model[word]
                except:
                    print word
                yield word, model[word], cls


for word, vec, cls in iterate_words(source_dir):
    pass#print word, vec, cls
