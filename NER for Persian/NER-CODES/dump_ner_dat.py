# -*- coding: utf-8 -*-

import os, gensim
import numpy as np
import numpy as np
import sys

def simil(model, word):
    with open('/tmp/x.out', 'w') as fh:
        for k in model.most_similar(word):
            fh.write("{0}\t{1}\n".format(k[0], k[1]))

source_dir = "NER-data"
stoplist_path = "stoplist.txt"
stoplist = set(open(stoplist_path, 'r').read().split())


model = gensim.models.Word2Vec.load('word2vec_fawiki.model')

def iterate_words(source_dir):
    for filename in os.listdir(source_dir):
        if filename.startswith('.'):
            continue
        with open(os.path.join(source_dir, filename)) as fh:
            #print filename
            flg = False
            buf = []
            for line in fh:
                if not flg:
                    flg = True
                    continue
                spl_line = line.split()


                word = '‌'.join(spl_line[4:-1])
                if word in ('.', ':', "!", "?", "؟"):
                    yield None, None, None, None, None
                if spl_line[2] == 'DELM':
                    continue                    
                if word in stoplist:
                    continue
                cls = spl_line[-1]
                tag = spl_line[2]
                tags = spl_line[3].split(',')
                yield word, model[word], cls, tag, tags
                
sentences_words = [[]]
sentences_samples = [[]]
sentences_samples_tag = [[]]
sentences_samples_tags = [[]]
sentences_samples_target = [[]]
sentences_targets = [False]

whole_tag = set()
whole_tags = set()

for word, vec, cls, tag, tags in iterate_words(source_dir):
    if word is None:
        if not len(sentences_words[-1]):
            continue
        sentences_words.append([])
        sentences_samples.append([])
        sentences_samples_tag.append([])
        sentences_samples_tags.append([])
        sentences_samples_target.append([])
        sentences_targets.append(False)
    else:
        if cls.endswith('PRO'):
            cls = 'O'
        if cls != 'O':
            sentences_targets[-1] = True
        sentences_words[-1].append(word)
        sentences_samples[-1].append(vec)
        sentences_samples_tag[-1].append(tag)
        sentences_samples_tags[-1].append(tags)
        whole_tag.add(tag)
        for t in tags:
            whole_tags.add(t)
        sentences_samples_target[-1].append(cls)    

import cPickle as cp
cp.dump({
         'sentences_words': sentences_words,
         'sentences_targets': sentences_targets,
         'sentences_samples': sentences_samples,
         'sentences_samples_tag': sentences_samples_tag,
         'sentences_samples_tags': sentences_samples_tags,
         'whole_tag': list(whole_tag),
         'whole_tags': list(whole_tags),
         'sentences_samples_target': sentences_samples_target}, open('NER_samples.dat', 'wb'))

