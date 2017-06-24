
# coding: utf-8

# ### Linear Regression

# In[39]:

import numpy as np #خواندن داده از فایل
data = np.load(r"data.npz")


# In[40]:

#نام گذاری اده ها برای دسترسی ساده تر
X1   = data['x1'] 
X2   = data['x2']
Y    = data['y']
X1_T = data['x1_test']
X2_T = data['x2_test']
Y_T  = data['y_test']


# In[41]:

#یک ماتریس 0 میسازیم برای نوشتن همه ی هشت هزار ورودی 2 بعدی
X = np.matrix([[0.0 for i in range(3)] for j in range(len(X1))])


# In[42]:

#پرکردن ماتریس بالا با داده های ورودی
for i in range(len(X1)):
    X[i,0] = float(1)
    X[i,1] = float(X1[i])
    X[i,2] = float(X2[i])


# In[43]:

#محاسبه ی ترانهاده ماتریس بالا
XT = np.transpose(X)


# In[44]:

#محاسبه ی ماتریس امگا با استفاده از فرمول بسته ی موجود در کتاب
W = np.matmul(np.matmul(np.linalg.inv(np.matmul(XT,X)),XT),Y)


# In[45]:

#ساخت ماتریس خالی برای پر کردن با نتایج حاصله از فرمول بدست آمده
Y_new=np.array([0.0 for j in range(len(X1_T))])

#ماتریس بدست آمده برای خروجی بر اساس داده های ورودی تست
for i in range(len(X1_T)):
    Y_new[i] = W[0,0] + W[0,1]*X1_T[i] + W[0,2]*X2_T[i]


# In[46]:

#ساختن ماتریس برای تست گرفتن 
comp = np.matrix([[0.0 for i in range(1)] for j in range(len(X1_T))])


# In[47]:

#پرکردن ماتریس تست (هر درایه قدرمطلق اختلاف خروجی تست با مقدار پیدا شده توسط امگاهای ماست)
for i in range(len(comp)):
    comp[i] = abs(Y_T[i] -  Y_new[i])


# In[48]:

#ماتریس خطا برای داده های آزمایش
#ساخت ماتریس صفر برای مقایسه کردن داده ها
compT = np.matrix([[0.0 for i in range(1)] for j in range(len(X1))])

#مقایسه نتایج حاصل از تابع تخمین(روی داده های تست) و داده های هدف تست
for i in range(len(compT)):
    compT[i] = abs(Y[i] - ( W[0,0] + W[0,1]*X1[i] + W[0,2]*X2[i]))


# In[49]:

#ماتریس خطا برای داده های تست
comp


# In[50]:

#ماتریس خطا برای داده های آموزش
compT


# In[51]:

#مجموع مربعات خطا برای داده های تست
sum(pow(i,2) for i in comp)


# In[52]:

#مجموع مربعات خطا برای داده های آموزشی
sum(pow(i,2) for i in compT)


# In[53]:

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
    xs2 = X1
    ys2 = X2
    zs2 = Y
    ax.scatter(xs2, ys2, zs2)

ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')

plt.show()


# In[ ]:



