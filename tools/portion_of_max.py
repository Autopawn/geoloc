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
            key = ' '.join(strp[1:-2])
            #
            if key not in results:
                results[key] = []
            results[key].append(((strp[0],strp[-1]),float(strp[-2])))
        #
        fil.close()
        #
        finals = []
        for key in results:
            liste = dict(results[key][:])
            for (name,prob) in liste:
                if (maxname,prob) in liste:
                    if liste[(maxname,prob)]==0.0:
                        portion = 1.0
                    else:
                        portion = liste[(name,prob)]/liste[(maxname,prob)]
                    assert(name!=maxname or portion==1.0)
                    if name!=maxname: finals.append((name,key,portion,prob))
        #
        filo = open(outfile,'w')
        for vals in finals:
            filo.write("%s %s %.8f %s\n"%vals)
        #
        filo.close()
