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
        for li in fil:
            li = li.strip()
            if li=="": continue
            li = li.split(' ')
            #
            name = li[0]
            pname = li[-1]
            xx = 'c' if li[1]=='c' else float(li[1])
            yy = float(li[-2])
            dim = [float(i) if '.' in i else int(i) for i in li[2:-2]]
            key = tuple([name,pname]+dim+[xx])
            assert(key not in results)
            results[key]= yy
        #
        fil.close()
        #
        filo = open(outfile,'w')
        for key in results:
            maxkey = tuple([maxname]+list(key[1:]))
            if maxkey not in results:
                maxkey = tuple(list(maxkey[:-1])+['c'])
            assert(maxkey in results)
            if results[maxkey]==0.0:
                assert(results[key]==0.0)
                portion = 1.0
            else:
                portion = results[key]/results[maxkey]
            assert(name!=maxname or portion==1.0)
            filo.write("%s "%key[0])
            filo.write("%s "%str(key[-1]))
            [filo.write("%s "%str(v)) for v in key[2:-1]]
            filo.write("%f "%portion)
            filo.write("%s\n"%key[1])
        #
        filo.close()
