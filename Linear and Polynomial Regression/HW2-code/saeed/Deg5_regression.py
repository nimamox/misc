
# coding: utf-8

# # Deg5_regression

# In[25]:

import numpy as np #خواندن داده از فایل
data = np.load(r"data.npz")

#نام گذاری اده ها برای دسترسی ساده تر
X1   = data['x1'] 
X2   = data['x2']
Y    = data['y']
X1_T = data['x1_test']
X2_T = data['x2_test']
Y_T  = data['y_test']

#یک ماتریس صفر می سازیم تا داده های ورودی را در آن قرار دهیم
XF = np.matrix([[0.0 for i in range(21)] for j in range(len(X1))])

#پرکردن ماتریس بالا با همه ی ترکیبات موجود در چندجمله ای درجه پنج حاصل از داده های مسئله
for i in range(len(X1)):
    XF[i,0]  = float(1)
    XF[i,1]  = float(X1[i])
    XF[i,2]  = float(X2[i])
    XF[i,3]  = float(X1[i]*X2[i])
    XF[i,4]  = float(pow(X1[i],2))
    XF[i,5]  = float(pow(X2[i],2))
    XF[i,6]  = float(pow(X1[i],3))
    XF[i,7]  = float(pow(X2[i],3))
    XF[i,8]  = float(pow(X1[i],2)*X2[i])
    XF[i,9]  = float(pow(X2[i],2)*X1[i])
    XF[i,10] = float(pow(X1[i],4))
    XF[i,11] = float(pow(X2[i],4))
    XF[i,12] = float(pow(X1[i],3)*X2[i])
    XF[i,13] = float(pow(X2[i],3)*X1[i])
    XF[i,14] = float(pow(X2[i],2)*(pow(X1[i],2)))
    XF[i,15] = float(pow(X1[i],5))
    XF[i,16] = float(pow(X2[i],5))
    XF[i,17] = float(pow(X1[i],4)*X2[i])
    XF[i,18] = float(pow(X2[i],4)*X1[i])
    XF[i,19] = float(pow(X1[i],2)*(pow(X2[i],3)))
    XF[i,20] = float(pow(X1[i],3)*(pow(X2[i],2)))   
    
#ترانهاده ماتریس بالا
XFT   = np.transpose(XF)

#فرم بسته ی ماتریس وزن ها با استفاده از فرمول کتاب
WXF   = np.matmul(np.matmul(np.linalg.inv(np.matmul(XFT,XF)),XFT),Y)

#ساخت ماتریس صفر برای مقایسه کردن داده ها
comp3 = np.matrix([[0.0 for i in range(1)] for j in range(len(X1_T))])

#مقایسه نتایج حاصل از تابع تخمین(روی داده های تست) و داده های هدف تست
for i in range(len(comp3)):
    comp3[i] = abs(Y_T[i] - (WXF[0,0] + WXF[0,1]*X1_T[i] + WXF[0,2]*X2_T[i] + WXF[0,3]*(X1_T[i]*X2_T[i]) + WXF[0,4]*(pow(X1_T[i],2)) + WXF[0,5]*(pow(X2_T[i],2)) + WXF[0,6]*(pow(X1_T[i],3)) + WXF[0,7]*(pow(X2_T[i],3)) + WXF[0,8]*(pow(X1_T[i],2)*X2_T[i]) + WXF[0,9]*(pow(X2_T[i],2)*X1_T[i]) + WXF[0,10]*(pow(X1_T[i],4)) + WXF[0,11]*(pow(X2_T[i],4)) + WXF[0,12]*(pow(X1_T[i],3)*X2_T[i]) + WXF[0,13]*(pow(X2_T[i],3)*X1_T[i]) + WXF[0,14]*(pow(X2_T[i],2)*(pow(X1_T[i],2))) + WXF[0,15]*(pow(X1_T[i],5)) + WXF[0,16]*(pow(X2_T[i],5)) + WXF[0,17]*(pow(X1_T[i],4)*X2_T[i]) + WXF[0,18]*(pow(X2_T[i],4)*X1_T[i]) + WXF[0,19]*(pow(X1_T[i],2)*(pow(X2_T[i],3)))  + WXF[0,20]*(pow(X1_T[i],3)*(pow(X2_T[i],2)))))


# In[26]:

#ماتریس خطا برای داده های آزمایش
#ساخت ماتریس صفر برای مقایسه کردن داده ها
compT = np.matrix([[0.0 for i in range(1)] for j in range(len(X1))])

#مقایسه نتایج حاصل از تابع تخمین(روی داده های تست) و داده های هدف تست
for i in range(len(compT)):
    compT[i] = abs(Y[i] - (WXF[0,0] + WXF[0,1]*X1[i] + WXF[0,2]*X2[i] + WXF[0,3]*(X1[i]*X2[i]) + WXF[0,4]*(pow(X1[i],2)) + WXF[0,5]*(pow(X2[i],2)) + WXF[0,6]*(pow(X1[i],3)) + WXF[0,7]*(pow(X2[i],3)) + WXF[0,8]*(pow(X1[i],2)*X2[i]) + WXF[0,9]*(pow(X2[i],2)*X1[i]) + WXF[0,10]*(pow(X1[i],4)) + WXF[0,11]*(pow(X2[i],4)) + WXF[0,12]*(pow(X1[i],3)*X2[i]) + WXF[0,13]*(pow(X2[i],3)*X1[i]) + WXF[0,14]*(pow(X2[i],2)*(pow(X1[i],2))) + WXF[0,15]*(pow(X1[i],5)) + WXF[0,16]*(pow(X2[i],5)) + WXF[0,17]*(pow(X1[i],4)*X2[i]) + WXF[0,18]*(pow(X2[i],4)*X1[i]) + WXF[0,19]*(pow(X1[i],2)*(pow(X2[i],3)))  + WXF[0,20]*(pow(X1[i],3)*(pow(X2[i],2)))))


# In[27]:

#ماتریس خطا برای داده های تست
comp3


# In[28]:

#ماتریس خطا برای داده های آزمایش
compT


# In[29]:

#مجموع مربعات خطا برای داده های تست
sum(pow(i,2) for i in comp3)


# In[30]:

#مجموع مربعات خطا برای داده های آموزشی
sum(pow(i,2) for i in compT)


# In[31]:

#کشیدن شکل پراکندگی داده ها همزمان با داده های بدست آمده از فرمول(مشاهده می شود که بسیار بر هم منطبق اند)
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt

#ساخت ماتریس خالی برای پر کردن با نتایج حاصله از فرمول بدست آمده
Y_new=np.array([0.0 for j in range(len(X1_T))])

#ماتریس بدست آمده برای خروجی بر اساس داده های ورودی تست
for i in range(len(X1_T)):
    Y_new[i] = WXF[0,0] + WXF[0,1]*X1_T[i] + WXF[0,2]*X2_T[i] + WXF[0,3]*(X1_T[i]*X2_T[i]) + WXF[0,4]*(pow(X1_T[i],2)) + WXF[0,5]*(pow(X2_T[i],2)) + WXF[0,6]*(pow(X1_T[i],3)) + WXF[0,7]*(pow(X2_T[i],3)) + WXF[0,8]*(pow(X1_T[i],2)*X2_T[i]) + WXF[0,9]*(pow(X2_T[i],2)*X1_T[i]) + WXF[0,10]*(pow(X1_T[i],4)) + WXF[0,11]*(pow(X2_T[i],4)) + WXF[0,12]*(pow(X1_T[i],3)*X2_T[i]) + WXF[0,13]*(pow(X2_T[i],3)*X1_T[i]) + WXF[0,14]*(pow(X2_T[i],2)*(pow(X1_T[i],2))) + WXF[0,15]*(pow(X1_T[i],5)) + WXF[0,16]*(pow(X2_T[i],5)) + WXF[0,17]*(pow(X1_T[i],4)*X2_T[i]) + WXF[0,18]*(pow(X2_T[i],4)*X1_T[i]) + WXF[0,19]*(pow(X1_T[i],2)*(pow(X2_T[i],3)))  + WXF[0,20]*(pow(X1_T[i],3)*(pow(X2_T[i],2)))

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



