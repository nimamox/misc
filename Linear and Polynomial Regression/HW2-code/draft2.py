import numpy as np

def poly(x, deg=1):
    r = []
    for i in range(deg+1):
        for j in range(deg+1):
            if (i+j) <= deg:
                r.append(x[:,0] ** j * x[:,1] ** i)
    return np.array(r).T

class LinearRegression:
    def __init__(self, lambda_ = 0, deg=1):
        self.deg = deg
        self.lambda_ = lambda_
    def fit_closed_form(self, X, y):
        X = poly(X, self.deg)
        n, d = X.shape
        regMatrix = self.lambda_ * np.eye(d)
        regMatrix[0][0] = 0
        self.theta = np.linalg.pinv(X.T.dot(X)+regMatrix).dot(X.T).dot(y)
        
    def cost(self, theta, X, y):
        return np.sum((y - X.dot(theta)) ** 2)
        
    def fit_iterative(self, X, y, theta, learning_rate, max_iter):
        X = poly(X, self.deg)
        for i in range(max_iter):
            gradient = learning_rate * (X.dot(theta) - y).dot(X)
            theta = theta - gradient
            #print i, gradient, theta
            #print self.cost(theta, X, y)
        self.theta = theta
        
    def predict(self, X):
        n, d = X.shape
        X = poly(X, self.deg)
        return X.dot(self.theta)
        

a = np.load('data.npz')

x1 = a['x1']
x2 = a['x2']
x1_test = a['x1_test']
x2_test = a['x2_test']
y = a['y']
y_test = a['y_test']

X = np.vstack([x1, x2]).T


closed = LinearRegression()
closed.fit_closed_form(X, y)
print "theta for closed form:", closed.theta

iterative = LinearRegression()
init_theta = np.array([0, 0, 0])
iterative.fit_iterative(X, y, init_theta, .0000001, 100000)
print "theta for iterative form:", iterative.theta

predictions = closed.predict(X)
#print closed.cost(closed.theta, X, y)