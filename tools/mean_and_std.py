import sys
import numpy as np

if __name__ == '__main__':
    if len(sys.argv)!=2:
        print("Usage: python %s <file>"%sys.argv[0])
    else:
        fil = open(sys.argv[1])
        vals = []
        for lin in fil:
            val = float(lin.strip())
            vals.append(val)
        #
        name = " ".join([x for x in sys.argv[1].split("/")[0].split("_")])
        if len(vals)>0:
            vals = np.array(vals)
            mean = np.mean(vals)
            std = np.std(vals)
            print("%s %f \pm %f"%(name,mean,std))
        else:
            print("%s ? \pm ?"%(name))
        fil.close()
