import matplotlib.pyplot as plt

throughput_log = """hw_raid1_with_cache_large_req.parv.out:Overall I/O System Requests per second:   	54.152121
hw_raid1_with_cache_medium_req.parv.out:Overall I/O System Requests per second:   	74.839183
hw_raid1_with_cache_small_req.parv.out:Overall I/O System Requests per second:   	80.245812
hw_raid1_with_nocache_large_req.parv.out:Overall I/O System Requests per second:   	64.680562
hw_raid1_with_nocache_medium_req.parv.out:Overall I/O System Requests per second:   	93.480399
hw_raid1_with_nocache_small_req.parv.out:Overall I/O System Requests per second:   	96.909472
hw_raid31_with_cache_large_req.parv.out:Overall I/O System Requests per second:   	44.663290
hw_raid31_with_cache_medium_req.parv.out:Overall I/O System Requests per second:   	61.719199
hw_raid31_with_cache_small_req.parv.out:Overall I/O System Requests per second:   	68.005914
hw_raid31_with_nocache_large_req.parv.out:Overall I/O System Requests per second:   	60.838577
hw_raid31_with_nocache_medium_req.parv.out:Overall I/O System Requests per second:   	85.674496
hw_raid31_with_nocache_small_req.parv.out:Overall I/O System Requests per second:   	90.890062
hw_raid71_with_cache_large_req.parv.out:Overall I/O System Requests per second:   	57.806363
hw_raid71_with_cache_medium_req.parv.out:Overall I/O System Requests per second:   	69.962464
hw_raid71_with_cache_small_req.parv.out:Overall I/O System Requests per second:   	75.039194
hw_raid71_with_nocache_large_req.parv.out:Overall I/O System Requests per second:   	82.021575
hw_raid71_with_nocache_medium_req.parv.out:Overall I/O System Requests per second:   	94.068864
hw_raid71_with_nocache_small_req.parv.out:Overall I/O System Requests per second:   	96.135604
hw_single_with_cache_large_req.parv.out:Overall I/O System Requests per second:   	37.556862
hw_single_with_cache_medium_req.parv.out:Overall I/O System Requests per second:   	54.998343
hw_single_with_cache_small_req.parv.out:Overall I/O System Requests per second:   	62.007962
hw_single_with_nocache_large_req.parv.out:Overall I/O System Requests per second:   	47.418344
hw_single_with_nocache_medium_req.parv.out:Overall I/O System Requests per second:   	67.961751
hw_single_with_nocache_small_req.parv.out:Overall I/O System Requests per second:   	74.595594
"""

avg_rt_log ="""hw_raid1_with_cache_large_req.parv.out:Overall I/O System Response time average: 	87.410663
hw_raid1_with_cache_medium_req.parv.out:Overall I/O System Response time average: 	33.459932
hw_raid1_with_cache_small_req.parv.out:Overall I/O System Response time average: 	24.477941
hw_raid1_with_nocache_large_req.parv.out:Overall I/O System Response time average: 	152.808413
hw_raid1_with_nocache_medium_req.parv.out:Overall I/O System Response time average: 	41.368288
hw_raid1_with_nocache_small_req.parv.out:Overall I/O System Response time average: 	27.666542
hw_raid31_with_cache_large_req.parv.out:Overall I/O System Response time average: 	130.703169
hw_raid31_with_cache_medium_req.parv.out:Overall I/O System Response time average: 	62.105883
hw_raid31_with_cache_small_req.parv.out:Overall I/O System Response time average: 	47.150294
hw_raid31_with_nocache_large_req.parv.out:Overall I/O System Response time average: 	174.720636
hw_raid31_with_nocache_medium_req.parv.out:Overall I/O System Response time average: 	67.642395
hw_raid31_with_nocache_small_req.parv.out:Overall I/O System Response time average: 	50.400269
hw_raid71_with_cache_large_req.parv.out:Overall I/O System Response time average: 	70.416513
hw_raid71_with_cache_medium_req.parv.out:Overall I/O System Response time average: 	41.424422
hw_raid71_with_cache_small_req.parv.out:Overall I/O System Response time average: 	33.742821
hw_raid71_with_nocache_large_req.parv.out:Overall I/O System Response time average: 	79.612017
hw_raid71_with_nocache_medium_req.parv.out:Overall I/O System Response time average: 	38.923116
hw_raid71_with_nocache_small_req.parv.out:Overall I/O System Response time average: 	31.485917
hw_single_with_cache_large_req.parv.out:Overall I/O System Response time average: 	161.435756
hw_single_with_cache_medium_req.parv.out:Overall I/O System Response time average: 	82.329793
hw_single_with_cache_small_req.parv.out:Overall I/O System Response time average: 	63.087211
hw_single_with_nocache_large_req.parv.out:Overall I/O System Response time average: 	261.629921
hw_single_with_nocache_medium_req.parv.out:Overall I/O System Response time average: 	137.002508
hw_single_with_nocache_small_req.parv.out:Overall I/O System Response time average: 	110.414437"""


throughput = {}

for line in throughput_log.strip().split('\n'):
    spl_line = line.split()
    spl1 = spl_line[0].split('_')
    #print spl_line
    throughput[spl1[1]] = {'cache':{}, 'nocache':{}}
for line in throughput_log.strip().split('\n'):
    spl_line = line.split()
    spl1 = spl_line[0].split('_')
    throughput[spl1[1]][spl1[3]][spl1[4]] = spl_line[-1]

avgrt = {}

for line in avg_rt_log.strip().split('\n'):
    spl_line = line.split()
    spl1 = spl_line[0].split('_')
    #print spl_line
    avgrt[spl1[1]] = {'cache':{}, 'nocache':{}}
for line in avg_rt_log.strip().split('\n'):
    spl_line = line.split()
    spl1 = spl_line[0].split('_')
    avgrt[spl1[1]][spl1[3]][spl1[4]] = spl_line[-1]

print avgrt



labels = ['4', '16', '64']
ll = {'raid1': 'RAID1', 'raid31': 'RAID3+1',
      'raid71': 'RAID7+1', 'single': 'Single'}

colors = {'raid1': 'k', 'raid31': 'r',
      'raid71': 'g', 'single': 'b'}

k = 'raid71'

fig = plt.figure(figsize=(12, 10))
ax = fig.add_subplot(111)
for l1 in ['single', 'raid1', 'raid31', 'raid71']:
    #if l1!=k:
        #continue
    for l2 in throughput[l1].keys():
        points = [throughput[l1][l2]['small'], throughput[l1][l2]['medium'], throughput[l1][l2]['large']]
        #print "{0} ({1}) & {2}                   & {3}                    & {4}                   \\\\ \\hline".format(ll[l1], l2, points[0], points[1], points[2])
        if l2=='cache':
            ax.plot([4, 16, 64], points, c=colors[l1], label='{0} ({1})'.format(ll[l1], l2))
        else:
            ax.plot([4, 16, 64], points, c=colors[l1], ls='dashed', label='{0} ({1})'.format(ll[l1], l2))
        ax.scatter([4, 16, 64], points, c='k')

plt.xticks([4, 16, 64], labels, rotation='vertical')
plt.xlabel('Req Size')
plt.ylabel('Throughput')
plt.legend()
plt.savefig('plot1.pdf', transparent=True)
#plt.show()


##################

fig = plt.figure(figsize=(12, 10))
ax = fig.add_subplot(111)
for l1 in ['single', 'raid1', 'raid31', 'raid71']:
    #if l1!=k:
        #continue    
    for l2 in avgrt[l1].keys():
        points = [avgrt[l1][l2]['small'], avgrt[l1][l2]['medium'], avgrt[l1][l2]['large']]
        print "{0} ({1}) & {2}                   & {3}                    & {4}                   \\\\ \\hline".format(ll[l1], l2, points[0], points[1], points[2])
        if l2=='cache':
            ax.plot([4, 16, 64], points, label='{0} ({1})'.format(ll[l1], l2))
        else:
            ax.plot([4, 16, 64], points, ls='dashed', label='{0} ({1})'.format(ll[l1], l2))
        ax.scatter([4, 16, 64], points, c='k')

plt.xticks([4, 16, 64], labels, rotation='vertical')
plt.xlabel('Req Size')
plt.ylabel('Average RT')
plt.legend()
plt.savefig('plot2.pdf', transparent=True)
#plt.show()

