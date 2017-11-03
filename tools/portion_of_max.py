import sys
import numpy as np

if __name__ == '__main__':
    if len(sys.argv)!=4:
        print("Usage: python %s <maxname> <infile> <outfile>"%sys.argv[0])
    else:
        maxname = sys.argv[1]
        infile = sys.argv[2]
        outfile = sys.argv[3]
        #
        fil = open(infile)
        results = {}
        for lin in fil:
            lin = lin.strip()
            if lin=="": continue
            strp = lin.split(' ')
            #
            key = ' '.join(strp[1:-1])
            #
            if key not in results:
                results[key] = []
            results[key].append((strp[0],float(strp[-1])))
        #
        fil.close()
        #
        for key in results:
            liste = results[key][:]
            means = []
            while len(liste)>0:
                name = liste[0][0]
                mean = np.mean([x[1] for x in liste if x[0]==name])
                liste = [x for x in liste if x[0]!=name]
                means.append((name,mean))
            #
            results[key] = means
        #
        filo = open(outfile,'w')
        for key in results:
            ndic = dict(results[key])
            if maxname in ndic:
                maxval = ndic[maxname]
                for name in ndic:
                    filo.write("%s %s %.8f\n"%(name,key,ndic[name]/maxval))
        #
        filo.close()
