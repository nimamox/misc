import numpy as np
import matplotlib.pyplot as plt 
import math
label = np.array([[2,2], [5,1], [6,3], [2,6]])
dist = np.zeros(4)
x1 = []
x2 = []
x3 = []
y1 = []
y2 = []
y3 = []
for i in np.arange(0, 10, .1):
    for j in np.arange(0, 10, .1):
        for k in range(4):
            dist[k] = math.hypot(label[k,0] - i, label[k,1] - j)
        m = np.argmin(dist) 
        if (m==0 or m==1):
            x1.append(i)
            y1.append(j)
        elif (m==2):
            x2.append(i)
            y2.append(j)
        else:
            x3.append(i)
            y3.append(j)
plt.plot(x1, y1, 'b.', x2, y2, 'y.', x3, y3, 'r.')
plt.show()