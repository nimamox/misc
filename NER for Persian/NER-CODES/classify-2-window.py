# -*- coding: utf-8 -*-

import os
import numpy as np
import cPickle as cp
import sys
import random

try:
    D = cp.load(open('ramdisk/NER_samples.dat', 'rb'))
except:
    D = cp.load(open('NER_samples.dat', 'rb'))
sentences_words = D['sentences_words']
sentences_targets = D['sentences_targets']
sentences_samples = D['sentences_samples']
sentences_samples_target = D['sentences_samples_target']
sentences_samples_tag = D['sentences_samples_tag']
sentences_samples_tags = D['sentences_samples_tags']
whole_tag = D['whole_tag']
whole_tags = D['whole_tags']

LABELS = {'O': 0, 'B_LOC': 1, 'I_LOC': 2, 'B_ORG': 3, 'I_ORG': 4, 'B_PERS': 5, 'I_PERS': 6}

from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation
from keras.optimizers import SGD


from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation
from keras.optimizers import SGD

NN = Sequential()
NN.add(Dense(500 + len(whole_tags), 200, init='uniform'))
NN.add(Activation('tanh'))
NN.add(Dropout(0.75))
NN.add(Dense(200, 80, init='uniform'))
NN.add(Activation('tanh'))
NN.add(Dropout(0.3))
NN.add(Dense(80, 7, init='uniform'))
NN.add(Activation('softmax'))

sgd = SGD(lr=0.1, decay=1e-6, momentum=0.97, nesterov=True)
NN.compile(loss='mean_squared_error', optimizer=sgd)

X_train = []
y_train = []
y2_train = []

X_test = []
y_test = []
y2_test = []

null_vec = np.array([-1] * 100)

LABELS_count = {'O': 0, 'B_LOC': 0, 'I_LOC': 0, 'B_ORG': 0, 'I_ORG': 0, 'B_PERS': 0, 'I_PERS': 0}
nonzeros_count = 0
for si in xrange(len(sentences_samples)):
    for wi in xrange(len(sentences_samples[si])):
        LABELS_count[sentences_samples_target[si][wi]] += 1
        if sentences_samples_target[si][wi] != 'O':
            nonzeros_count += 1

ttrain = []
ttest = []
for si in xrange(len(sentences_samples)):
    prev = null_vec
    prev2 = null_vec
    if si % 2:
        if not sentences_targets[si]:
            #if random.random() < .7:
            continue
        X = X_train
        y = y_train
        y2 = y2_train
        ttrain.append(sentences_targets[si])
    else:
        X = X_test
        y = y_test
        y2 = y2_test
        ttest.append(sentences_targets[si])
    for wi in xrange(len(sentences_samples[si])):
        try:
            post = sentences_samples[si][wi+1]
        except:
            post = null_vec
        try:
            post2 = sentences_samples[si][wi+2]
        except:
            post2 = null_vec        
        #tag_vec = [0] * len(whole_tag)
        tags_vec = [0] * len(whole_tags)
        #tag_vec[whole_tag.index(sentences_samples_tag[si][wi])] = 1
        for t in sentences_samples_tags[si][wi]:
            tags_vec[whole_tags.index(t)] = 1
        
        X.append(np.concatenate([prev, prev2, sentences_samples[si][wi], post, post2, tags_vec]))
        prev = prev2
        prev2 = sentences_samples[si][wi]
        targ = [0, 0, 0, 0, 0, 0, 0]
        targ[LABELS[sentences_samples_target[si][wi]]] = 1
        y.append(targ)
        y2.append(LABELS[sentences_samples_target[si][wi]])

X_train = np.array(X_train)
y_train = np.array(y_train)
y2_train = np.array(y2_train)

X_test = np.array(X_test)
y_test = np.array(y_test)
y2_test = np.array(y2_test)

NN.fit(X_train, y_train, nb_epoch=60, batch_size=1000, show_accuracy=True, verbose=2)
loss, accuracy = NN.evaluate(X_test, y_test, show_accuracy=True)

print 'Loss:', loss
print 'Accuracy:', accuracy

predictions = NN.predict_classes(X_test)

confusion_matrix = np.zeros([7, 7], dtype=int)

for i in xrange(predictions.shape[0]):
    confusion_matrix[y2_test[i]][predictions[i]] += 1

print confusion_matrix

q = y2_test[y2_test!=0]
w = predictions[y2_test!=0]


print "Correctly classified non-zero:", np.sum(q == w)
print "Incorrectly classified non-zero:", np.sum(q != w)
print "Non-zero predictions:", np.sum(predictions!=0)

print
