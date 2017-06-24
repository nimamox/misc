# -*- coding: utf-8 -*-
import gensim, os, time

input_dir = "NER-data2"
stoplist_path = "stoplist.txt"

stoplist = set(open(stoplist_path, 'r').read().split())

class MySentences(object):
    def __init__(self, dirname):
        self.dirname = dirname
    def __iter__(self):
        for fname in os.listdir(self.dirname):
            print fname
            if fname.startswith('last'):
                print
            for line in open(os.path.join(self.dirname, fname)):
                yield [word for word in line.split() if word not in stoplist]

sentences = MySentences(input_dir)

tic = time.time()

print 'START TRAINING'
model = gensim.models.Word2Vec(sentences, min_count=1)
print 'FINISHED TRAINING'
print time.time() - tic, 'seconds'

model.save('word2vec_fawiki.model')

w = 'اصفهان'
for k in model.most_similar(w):
    print k[0], k[1]

print
