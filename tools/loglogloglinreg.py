import sys
import numpy as np

from sklearn.linear_model import LinearRegression

if __name__ == '__main__':
    if len(sys.argv)!=2:
        print("Usage: python %s <file>"%sys.argv[0])
    else:
        fil = open(sys.argv[1])
        pointsx = []
        pointsy = []
        for lin in fil:
            lin = lin.strip().split(' ')
            yval = float(lin[-1])
            if yval>=0.0005:
                pointsy.append(yval)
                pointsx.append((float(lin[-3]),float(lin[-2])))
        pointsx = np.log(np.array(pointsx))
        pointsy = np.log(np.array(pointsy))
        linreg = LinearRegression()
        linreg.fit(pointsx,pointsy)
        print("log(C) = %f log(A) + %f log(B) + %f"%(
            linreg.coef_[0],linreg.coef_[1],linreg.intercept_))
        print(linreg.get_params())
