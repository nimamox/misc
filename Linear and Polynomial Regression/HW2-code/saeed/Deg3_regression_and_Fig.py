
# coding: utf-8

# # Deg3 regression

# In[56]:

import numpy as np #خواندن داده از فایل
data = np.load(r"data.npz")

#نام گذاری اده ها برای دسترسی ساده تر
X1   = data['x1'] 
X2   = data['x2']
Y    = data['y']
X1_T = data['x1_test']
X2_T = data['x2_test']
Y_T  = data['y_test']

#یک ماتریس 0 میسازیم برای نوشتن همه ی هشت هزار ورودی 2 بعدی
M = np.matrix([[0.0 for i in range(10)] for j in range(len(X1))])

#ساختن ماتریس خالی برای پرشدن با داده های درجه سه ورودی
M = np.matrix([[0.0 for i in range(10)] for j in range(len(X1))])
for i in range(len(X1)):
    M[i,0] = float(1)
    M[i,1] = float(X1[i])
    M[i,2] = float(X2[i])
    M[i,3] = float(X1[i]*X2[i])
    M[i,4] = float(pow(X1[i],2))
    M[i,5] = float(pow(X2[i],2))
    M[i,6] = float(pow(X1[i],3))
    M[i,7] = float(pow(X2[i],3))
    M[i,8] = float(pow(X1[i],2)*X2[i])
    M[i,9] = float(pow(X2[i],2)*X1[i])
    
#ترانهاده ماتریس بالا
MT    = np.transpose(M)

#ساختن ماتریس (از روی فرمول بسته) وزن ها
WM    = np.matmul(np.matmul(np.linalg.inv(np.matmul(MT,M)),MT),Y)

#ساخت ماتریس خالی برای پر کردن با نتایج حاصله از فرمول بدست آمده
Y_new=np.array([0.0 for j in range(len(X1_T))])

#ماتریس بدست آمده برای خروجی بر اساس داده های ورودی تست
for i in range(len(X1_T)):
    Y_new[i] = (WM[0,0] + WM[0,1]*X1_T[i] + WM[0,2]*X2_T[i] + WM[0,3]*(X1_T[i]*X2_T[i]) + WM[0,4]*(pow(X1_T[i],2)) + WM[0,5]*(pow(X2_T[i],2)) + WM[0,6]*(pow(X1_T[i],3)) + WM[0,7]*(pow(X2_T[i],3)) + WM[0,8]*(pow(X1_T[i],2)*X2_T[i]) + WM[0,9]*(pow(X2_T[i],2)*X1_T[i]))

#ساخت ماتریس خالی برای مقایسه نتایج حاصله از داده های تست و فرمول بدست آمده
comp = np.matrix([[0.0 for i in range(1)] for j in range(len(X1_T))])

#پرکردن ماتریس مقایسه
for i in range(len(comp)):
    comp[i] = abs(Y_T[i] - Y_new[i])


# In[57]:

#ماتریس خطا برای داده های آزمایش
#ساخت ماتریس صفر برای مقایسه کردن داده ها
compT = np.matrix([[0.0 for i in range(1)] for j in range(len(X1))])

#مقایسه نتایج حاصل از تابع تخمین(روی داده های تست) و داده های هدف تست
for i in range(len(compT)):
    compT[i] = abs(Y[i] - (WM[0,0] + WM[0,1]*X1[i] + WM[0,2]*X2[i] + WM[0,3]*(X1[i]*X2[i]) + WM[0,4]*(pow(X1[i],2)) + WM[0,5]*(pow(X2[i],2)) + WM[0,6]*(pow(X1[i],3)) + WM[0,7]*(pow(X2[i],3)) + WM[0,8]*(pow(X1[i],2)*X2[i]) + WM[0,9]*(pow(X2[i],2)*X1[i])))


# In[58]:

#ماتریس خطا برای داده های تست
comp


# In[59]:

#ماتریس خطا برای داده های آزمایش
compT


# In[60]:

#مجموع مربعات خطا برای داده های تست
sum(pow(i,2) for i in comp)


# In[61]:

#مجموع مربعات خطا برای داده های آموزشی
sum(pow(i,2) for i in compT)


# In[62]:

#کشیدن شکل پراکندگی داده ها همزمان با داده های بدست آمده از فرمول(مشاهده می شود که بسیار بر هم منطبق اند)
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt



fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

for i in range(5):
    xs = X1_T
    ys = X2_T
    zs = Y_new
    ax.scatter(xs, ys, zs, c='r', marker='o')

ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')


for i in range(5):
    xs2 = X1_T
    ys2= X2_T
    zs2 = Y_T
    ax.scatter(xs2, ys2, zs2)

ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')

plt.show()


# In[ ]:



