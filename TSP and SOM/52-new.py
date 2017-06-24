import numpy as np
import matplotlib.pyplot as plt 
import math
from scipy import io

data = io.loadmat('berlin52.mat')
target=data['berlin52']


p=52
weights=np.random.rand(p,2)
weights=(weights*1700)+20


dist=np.zeros(p)
alpha=0.95
beta=0.7
from numpy.random import shuffle

print("hi")
neigh=15
for index1 in range(30000):
    target_ordering = range(52)
    shuffle(target_ordering)    
    for index2 in target_ordering:#target
        
        for index3 in range(p):# weight
            dist[index3] = math.hypot(target[index2,0] - weights[index3,0], target[index2,1] - weights[index3,1])
        m=np.argmin(dist)
        
        weights[m,0]=(1-alpha)*weights[m,0]+alpha*target[index2,0]
        weights[m,1]=(1-alpha)*weights[m,1]+alpha*target[index2,1]
        for index4 in range (neigh):
            weights[((m+index4+1)%52),0]=(1-beta)*weights[((m+index4+1)%52),0]+beta*target[index2,0]
            weights[((m+index4+1)%52),1]=(1-beta)*weights[((m+index4+1)%52),1]+beta*target[index2,1]
            
            weights[((m-(index4+1))%52),0]=(1-beta)*weights[((m-(index4+1))%52),0]+beta*target[index2,0]
            weights[((m-(index4+1))%52),1]=(1-beta)*weights[((m-(index4+1))%52),1]+beta*target[index2,1]        
    if(index1%25==0 ):
        alpha=alpha*0.9
        beta=beta*0.7
    if(index1%30==0 and neigh>1):
        neigh=neigh-1;
weights2=np.transpose(weights)
target2=np.transpose(target)
#plt.plot(target2[0],target2[1],"bs")
plt.plot(weights2[0], weights2[1],"r-",target2[0],target2[1],"bs")
plt.show()        
        
di=0
for index1 in range (p):
    di =di+ math.hypot(weights[index1,0] - weights[(index1-1)%p,0], weights[index1,1] - weights[(index1-1)%p,1])

print(di)
print("end")