import numpy as np
import matplotlib.pyplot as plt 
import math

total_cities = 52

target = []
flag = False
with open('berlin52.tsp') as fh:
    for line in fh.readlines():
        line = line.strip()
        if line == 'NODE_COORD_SECTION':
            flag = True
            continue
        if line == 'EOF':
            break
        if not flag:
            continue
        spl_line = line.split()
        target.append([float(spl_line[1]), float(spl_line[2])])
target = np.array(target)

weights = (np.random.rand(total_cities, 2) * 1200) + 400
dist=np.zeros(total_cities)

alpha = 0.9
beta = 0.7
neigh_sigma = 0.9


for iter_ in range(100000):
    for point in np.random.permutation(range(total_cities)):
        for city in range(total_cities):
            dist[city] = math.hypot(target[point, 0] - weights[city, 0], target[point, 1] - weights[city, 1])
        bmu = np.argmin(dist)
        
        weights[bmu, 0] += alpha * (target[point, 0] - weights[bmu, 0])
        weights[bmu, 1] += alpha * (target[point, 1] - weights[bmu, 1])
        
        for neigh in range(7):
            lateral_weight = np.exp(-(neigh**2) / (2 * neigh_sigma))
            weights[((bmu+neigh)%total_cities), 0] += beta * lateral_weight * (target[point, 0] - weights[((bmu+neigh)%total_cities), 0])
            weights[((bmu+neigh)%total_cities), 1] += beta * lateral_weight * (target[point, 1] - weights[((bmu+neigh)%total_cities), 1])
    
            weights[((bmu-neigh)%total_cities), 0] += beta * lateral_weight * (target[point, 0] - weights[((bmu-neigh)%total_cities), 0])
            weights[((bmu-neigh)%total_cities), 1] += beta * lateral_weight * (target[point, 1] - weights[((bmu-neigh)%total_cities), 1])       
    if (not (iter_ % 200)):
        alpha *= .95
        beta *= .85
        neigh_sigma *= .9


weights_T = np.transpose(np.vstack((weights, weights[0])))
target_T = np.transpose(target)
fig, ax = plt.subplots()
ax.plot(weights_T[0], weights_T[1], "b--", target_T[0], target_T[1], "ro")

for i in range(target_T.shape[1]):
    t = ax.text(target_T[0][i], target_T[1][i], str(i+1))
plt.show()        

tour_length = 0
for i in range(total_cities):
    tour_length += math.hypot(weights[i, 0] - weights[(i-1)%total_cities,0], weights[i, 1] - weights[(i-1)%total_cities, 1])

print "The length of solution:", tour_length