import sys
import numpy as np

if __name__ == '__main__':
    argis = []
    for arg in sys.argv:
        if arg[0]!='-': argis.append(arg)
    if len(argis)!=4:
        print("Usage: python %s <maxname> [-n] [-i] <infile> <outfile>"%sys.argv[0])
    else:
        maxname = argis[1]
        infile = argis[2]
        outfile = argis[3]
        ignoremax = "-i" in sys.argv
        negated = "-n" in sys.argv
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
            dim = ['k' if i=='k' else float(i) if '.' in i else int(i) for i in li[2:-2]]
            key = tuple([name,pname]+dim+[xx])
            if key in results:
                raise ValueError("%s already present."%str(key))
            results[key]= yy
        #
        fil.close()
        #
        filo = open(outfile,'w')
        for key in results:
            maxkey = [maxname]+list(key[1:])
            maxkey0 = maxkey[:-1]+['c']
            maxkey2 = maxkey[:2]+['k','k']+maxkey[-1:]
            maxkey3 = maxkey[:3]+['k']+maxkey[-1:]
            maxkey3 = maxkey[:2]+['k']+maxkey[-2:]
            maxkey4 = maxkey[:2]+['k']+maxkey[-1:]
            maxkey5 = maxkey[:2]+['k','k']+['c']
            maxkey6 = maxkey[:3]+['k']+['c']
            maxkey7 = maxkey[:2]+['k']+[maxkey[-2]]+['c']
            maxkey8 = maxkey[:2]+['k']+['c']
            for maxkey in (maxkey,maxkey0,maxkey2,maxkey3,maxkey3,maxkey4,maxkey5,maxkey6,maxkey7,maxkey8):
                maxkey = tuple(maxkey)
                if maxkey in results: break
            assert(maxkey in results)

            if results[maxkey]==0.0:
                assert(results[key]==0.0)
                portion = 1.0
            else:
                portion = results[key]/results[maxkey]
            #
            name = key[0]
            if not (name!=maxname or portion==1.0):
                raise ValueError("maxname %s doesn't has portion 1.0"%str(maxname))
            if negated: portion = 1-portion
            if not (name==maxname and ignoremax):
                filo.write("%s "%key[0])
                filo.write("%s "%str(key[-1]))
                [filo.write("%s "%str(v)) for v in key[2:-1]]
                filo.write("%f "%portion)
                filo.write("%s\n"%key[1])
        #
        filo.close()
