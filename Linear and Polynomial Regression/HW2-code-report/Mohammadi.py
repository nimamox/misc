import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt

RUN = [1, 2, 3]

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
        
    def cost(self, theta, X, y, deg=0):
        if deg:
            X = poly(X, deg)
        return np.sum((y - X.dot(theta)) ** 2) / X.shape[0]
        
    def fit_iterative(self, X, y, theta, learning_rate, max_iter):
        costs = []
        iters = []
        X = poly(X, self.deg)
        m = float(X.shape[1])
        for i in range(max_iter):
            gradient = learning_rate * (X.dot(theta) - y).dot(X)
            theta = theta - (1/m) * gradient
            if not i % 1000:
                cost = self.cost(theta, X, y, deg=0)
                costs.append(cost)
                iters.append(i)
                #print i, cost
        self.theta = theta
        return costs, iters
        
    def predict(self, X):
        n, d = X.shape
        X = poly(X, self.deg)
        return X.dot(self.theta)
        

a = np.load('data.npz')

x1 = a['x1'] / 12.0
x2 = a['x2'] / 22.0
x1_test = a['x1_test'] / 12.0
x2_test = a['x2_test'] / 22.0
y = a['y']
y_test = a['y_test']

X = np.vstack([x1, x2]).T
X_test = np.vstack([x1_test, x2_test]).T

if 1 in RUN:
    #linear regression
    closed = LinearRegression()
    closed.fit_closed_form(X, y)
    #print "theta for closed form:", closed.theta
    train_cost_closed = closed.cost(closed.theta, X, y, 1)
    test_cost_closed = closed.cost(closed.theta, X_test, y_test, 1)
    predictions_closed = closed.predict(X_test)
    print "Train cost for closed form: {:.2e}".format(train_cost_closed)
    print "Test cost for closed form: {:.2e}".format(test_cost_closed)
    
    #3rd order polynomial regression
    closed3 = LinearRegression(deg=3)
    closed3.fit_closed_form(X, y)
    #print "theta for closed form:", closed.theta
    train_cost_closed3 = closed3.cost(closed3.theta, X, y, 3)
    test_cost_closed3 = closed3.cost(closed3.theta, X_test, y_test, 3)
    predictions_closed3 = closed3.predict(X_test)
    print "Train cost for 3rd order poly closed form: {:.2e}".format(train_cost_closed3)
    print "Test cost for 3rd order poly closed form: {:.2e}".format(test_cost_closed3) 
    
    #5th order polynomial regression
    closed5 = LinearRegression(deg=5)
    closed5.fit_closed_form(X, y)
    #print "theta for closed form:", closed.theta
    train_cost_closed5 = closed3.cost(closed5.theta, X, y, 5)
    test_cost_closed5 = closed3.cost(closed5.theta, X_test, y_test, 5)
    predictions_closed5 = closed5.predict(X_test)
    print "Train cost for 5th order poly closed form: {:.2e}".format(train_cost_closed5)
    print "Test cost for 5th order poly closed form: {:.2e}".format(test_cost_closed5)
    
    from scipy.interpolate import griddata
    xi = np.linspace(x1_test.min(), x1_test.max(), 50)
    yi = np.linspace(x2_test.min(), x2_test.max(), 50)
    zi = griddata((x1_test, x2_test), y_test, (xi[None, :], yi[:, None]), method='nearest')    # create a uniform spaced grid
    xig, yig = np.meshgrid(xi, yi)        
    
    fig = plt.figure()
    ax = fig.add_subplot(221, projection='3d')
    ax.plot_wireframe(X=xig, Y=yig, Z=zi, rstride=3, cstride=3, linewidth=1)
    ax.set_title('Test Data')
    plt.tick_params(axis='both', which='major', labelsize=6)
    plt.tick_params(axis='both', which='minor', labelsize=6)      
    #ax.plot_wireframe(x1_test, x2_test, y_test, rstride=1, cstride=1, linewidth=0.1, alpha=0.7, antialiased=False)
    
    ax = fig.add_subplot(222, projection='3d')
    ax.plot_wireframe(X=xig, Y=yig, Z=zi, rstride=3, cstride=3, linewidth=1, alpha=.5)
    ax.scatter(x1_test, x2_test, predictions_closed, c='r', marker='.', s=30, antialiased=False)
    ax.set_title('LinReg')
    plt.tick_params(axis='both', which='major', labelsize=6)
    plt.tick_params(axis='both', which='minor', labelsize=6)      
    
    ax = fig.add_subplot(223, projection='3d')
    ax.plot_wireframe(X=xig, Y=yig, Z=zi, rstride=3, cstride=3, linewidth=1, alpha=.5)
    ax.scatter(x1_test, x2_test, predictions_closed3, c='r', marker='.', s=30, antialiased=False)
    ax.set_title('PolyReg (d=3)')
    plt.tick_params(axis='both', which='major', labelsize=6)
    plt.tick_params(axis='both', which='minor', labelsize=6)      
    
    ax = fig.add_subplot(224, projection='3d')
    ax.plot_wireframe(X=xig, Y=yig, Z=zi, rstride=3, cstride=3, linewidth=1, alpha=.5)
    ax.scatter(x1_test, x2_test, predictions_closed5, c='r', marker='.', s=30, antialiased=False) 
    ax.set_title('PolyReg (d=5)')
    plt.tick_params(axis='both', which='major', labelsize=6)
    plt.tick_params(axis='both', which='minor', labelsize=6)    
    
    plt.savefig('plot1.pdf', transparent=True)
    
    plt.show()       

if 2 in RUN:
    #gradient based linear regression
    iterative = LinearRegression()
    init_theta = np.zeros(3)
    costs, iters = iterative.fit_iterative(X, y, init_theta, .000001, 1000000)
    print "Train cost for GD Reg: {:.2e}".format(iterative.cost(iterative.theta, X, y, 1))
    print "Test cost for GD Reg: {:.2e}".format(iterative.cost(iterative.theta, X_test, y_test, 1))
    
    #gradient based 3rd order polynomial regression
    iterative3 = LinearRegression(deg=3)
    init_theta = np.zeros(10)
    costs3, iters3 = iterative3.fit_iterative(X, y, init_theta, .001, 1000000)
    print "Train cost for GD Poly3: {:.2e}".format(iterative3.cost(iterative3.theta, X, y, 3))
    print "Test cost for GD Poly3: {:.2e}".format(iterative3.cost(iterative3.theta, X_test, y_test, 3))
    
    #gradient based 5th order polynomial regression
    iterative5 = LinearRegression(deg=5)
    init_theta = np.zeros(21)
    costs5, iters5 = iterative5.fit_iterative(X, y, init_theta, .001, 1000000)
    print "Train cost for GD Poly5: {:.2e}".format(iterative5.cost(iterative5.theta, X, y, 5))
    print "Test cost for GD Poly5: {:.2e}".format(iterative5.cost(iterative5.theta, X_test, y_test, 5))
    
    print "plotting"
    plt.subplot(111)
    ax = plt.gca()
    ax.set_yscale('log')
    ax.plot(iters, costs, 'r', antialiased=False, label='LR')
    ax.plot(iters, costs3, 'b', antialiased=False, label='PR3')
    ax.plot(iters, costs5, 'g', antialiased=False, label='PR5')
    plt.legend()
    plt.ylabel('Log(err)')
    plt.xlabel('Iteration')
    plt.savefig('plot2.pdf', transparent=True)
    plt.show()
      

if 3 in RUN:
    num_folds = 5
    lambda_vals = [10**i for i in range(-4, 5)]
    
    indices = range(X.shape[0])
    np.random.shuffle(indices)
    fold_size = X.shape[0] / num_folds
    
    l_errs1 = -np.ones(len(lambda_vals))
    train_errs1 = -np.ones(len(lambda_vals))
    test_errs1 = -np.ones(len(lambda_vals))
    for q, l in enumerate(lambda_vals):
        #print "lambda=", l
        folds_errs = []
        for i in range(num_folds):
            mask = np.ones(X.shape[0], np.bool)
            mask[indices[i*fold_size:(i+1)*fold_size]] = 0
            train_folds_X = X[mask,:]
            train_folds_y = y[mask]
            validation_fold_X = X[~mask,:]
            validation_fold_y = y[~mask]
            closed = LinearRegression(lambda_=l)
            closed.fit_closed_form(train_folds_X, train_folds_y) 
            folds_errs.append(closed.cost(closed.theta, validation_fold_X, validation_fold_y, 1))
        l_errs1[q] = np.mean(folds_errs)
        closed = LinearRegression(lambda_=l)
        closed.fit_closed_form(X, y)
        train_errs1[q] = closed.cost(closed.theta, X, y, 1)
        test_errs1[q] = closed.cost(closed.theta, X_test, y_test, 1)
    
    print "Best lambda for linear regression:", lambda_vals[np.argmin(l_errs1)]
    
    print "*" * 10
        
    l_errs3 = -np.ones(len(lambda_vals))
    train_errs3 = -np.ones(len(lambda_vals))
    test_errs3 = -np.ones(len(lambda_vals))    
    for q, l in enumerate(lambda_vals):
        #print "lambda=", l
        folds_errs = []
        for i in range(num_folds):
            mask = np.ones(X.shape[0], np.bool)
            mask[indices[i*fold_size:(i+1)*fold_size]] = 0
            train_folds_X = X[mask,:]
            train_folds_y = y[mask]
            validation_fold_X = X[~mask,:]
            validation_fold_y = y[~mask]
            closed = LinearRegression(deg=3, lambda_=l)
            closed.fit_closed_form(train_folds_X, train_folds_y) 
            folds_errs.append(closed.cost(closed.theta, validation_fold_X, validation_fold_y, 3))
        l_errs3[q] = np.mean(folds_errs)
        closed = LinearRegression(deg=3, lambda_=l)
        closed.fit_closed_form(X, y)
        train_errs3[q] = closed.cost(closed.theta, X, y, 3)
        test_errs3[q] = closed.cost(closed.theta, X_test, y_test, 3)        
    
    print "Best lambda for 3rd order polynomial regression:", lambda_vals[np.argmin(l_errs3)]
    
    
    #import matplotlib.pyplot as plt
    #plt.subplot(111)
    #ax = plt.gca()
    #ax.plot(lambda_vals, l_errs, 'g')
    #ax.plot(lambda_vals, train_errs, 'r')
    #ax.plot(lambda_vals, test_errs, 'b')
    #ax.set_xscale('log')
    #plt.show()
    
    print "*" * 10
    
    l_errs5 = -np.ones(len(lambda_vals))
    train_errs5 = -np.ones(len(lambda_vals))
    test_errs5 = -np.ones(len(lambda_vals))    
    for q, l in enumerate(lambda_vals):
        #print "lambda=", l
        folds_errs = []
        for i in range(num_folds):
            mask = np.ones(X.shape[0], np.bool)
            mask[indices[i*fold_size:(i+1)*fold_size]] = 0
            train_folds_X = X[mask,:]
            train_folds_y = y[mask]
            validation_fold_X = X[~mask,:]
            validation_fold_y = y[~mask]
            closed = LinearRegression(deg=5, lambda_=l)
            closed.fit_closed_form(train_folds_X, train_folds_y) 
            folds_errs.append(closed.cost(closed.theta, validation_fold_X, validation_fold_y, 5))
        l_errs5[q] = np.mean(folds_errs)
        closed = LinearRegression(deg=5, lambda_=l)
        closed.fit_closed_form(X, y)
        train_errs5[q] = closed.cost(closed.theta, X, y, 5)
        test_errs5[q] = closed.cost(closed.theta, X_test, y_test, 5)
        
    print "Best lambda for 5th order polynomial regression:", lambda_vals[np.argmin(l_errs5)]
    
    
    #plt.subplot(121)
    #ax = plt.gca()
    fig = plt.figure(figsize=(20, 20))
    
    ax = fig.add_subplot(311)
    ax.plot(lambda_vals, l_errs1, 'g', label='CV Avg Err')
    ax.scatter(lambda_vals, l_errs1, c='g')
    ax.plot(lambda_vals, train_errs1, 'r', label='Train Err')
    ax.scatter(lambda_vals, train_errs1, c='r')
    ax.plot(lambda_vals, test_errs1, 'b', label='Test Err')
    ax.scatter(lambda_vals, test_errs1, c='b')
    ax.set_xscale('log')
    ax.set_title('LinReg')
    plt.legend()
    
    ax = fig.add_subplot(312)
    ax.plot(lambda_vals, l_errs3, 'g', label='CV Avg Err')
    ax.scatter(lambda_vals, l_errs3, c='g')
    ax.plot(lambda_vals, train_errs3, 'r', label='Train Err')
    ax.scatter(lambda_vals, train_errs3, c='r')
    ax.plot(lambda_vals, test_errs3, 'b', label='Test Err')
    ax.scatter(lambda_vals, test_errs3, c='b')
    ax.set_xscale('log')
    ax.set_title('PolyReg (d=3)')
    plt.legend()    
    
    ax = fig.add_subplot(313)
    ax.plot(lambda_vals, l_errs5, 'g', label='CV Avg Err')
    ax.scatter(lambda_vals, l_errs5, c='g')
    ax.plot(lambda_vals, train_errs5, 'r', label='Train Err')
    ax.scatter(lambda_vals, train_errs5, c='r')
    ax.plot(lambda_vals, test_errs5, 'b', label='Test Err')
    ax.scatter(lambda_vals, test_errs5, c='b')
    ax.set_xscale('log')
    ax.set_title('PolyReg (d=5)')
    plt.legend()
    
    
    plt.savefig('plot3.pdf', transparent=True)
    plt.show()
    
    print "*" * 10