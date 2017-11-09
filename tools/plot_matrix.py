import sys
import matplotlib
import itertools

# v So that doens't trow error through ssh.
matplotlib.use('Agg')

import matplotlib.pyplot as plt
import numpy as np

def colori(kk,nn):
    if kk==0: return (0,0,0)
    if kk==nn-1: return (1.0,0,0)
    if kk==1 and nn==3: return (0,0,1.0)
    flt = (kk-1.0)/(nn-3.0)
    return (0,1-flt,flt)



if __name__ == '__main__':
    argis = []
    for arg in sys.argv:
        if arg[0]!='-': argis.append(arg)
    if len(argis)<3:
        print("Usage: %s [-lx] [-ly] <summary_file> <output>"%argis[0])
    else:
        logx = "-lx" in sys.argv
        logy = "-ly" in sys.argv

        points = {}
        #
        inputf = open(argis[1])
        for li in inputf:
            li = li.strip()
            if li=="": continue
            name,nn,alpha,density,yvalue,_ = li.split()
            key = (name,int(nn),float(alpha),float(density))
            if key not in points:
                points[key] = []
            points[key].append(float(yvalue))
        inputf.close()
        # Find the alpha values:
        alphavals = sorted(list(set([a for (_,_,a,_) in points.keys()])))
        denvals = sorted(list(set([d for (_,_,_,d) in points.keys()])))
        nnvals = sorted(list(set([nn for (_,nn,_,_) in points.keys()])))
        namevals = sorted(list(set([nam for (nam,_,_,_) in points.keys()])))[::-1]

        fig, axarr = plt.subplots(len(denvals),len(alphavals),sharex=True,sharey=True,figsize=(12,10))

        for i in range(len(denvals)):
            den = denvals[i]
            for j in range(len(alphavals)):
                alpha = alphavals[j]
                #
                if i==0 and j==0: lins = []
                for k in range(len(namevals)):
                    name = namevals[k]
                    mynnvals = [nn for nn in nnvals if (name,nn,alpha,den) in points.keys()]
                    data = [(nn,points[(name,nn,alpha,den)]) for nn in mynnvals]

                    mean = [(x[0],np.mean(x[1])) for x in data if len(x[1])>0]
                    dots = [[(x[0],y) for y in x[1]] for x in data]
                    dots = list(itertools.chain.from_iterable(dots))

                    meanx = [dot[0] for dot in mean]
                    meany = [dot[1] for dot in mean]
                    dotsx = [dot[0] for dot in dots]
                    dotsy = [dot[1] for dot in dots]

                    axarr[i,j].set_xlim(min(nnvals),max(nnvals))

                    axarr[i,j].set_title("$P=%.3f$  $C=%.3f$"%(alpha,den))
                    if logx: axarr[i,j].set_xscale('log')
                    if logy: axarr[i,j].set_yscale('log')
                    axarr[i,j].plot(dotsx,dotsy,"o",color=colori(k,len(namevals)),alpha=0.1)
                    lin = axarr[i,j].plot(meanx,meany,'-',color=colori(k,len(namevals)))
                    if i==0 and j==0: lins.append(lin[0])
                if i==0 and j==0:
                    siz = 90.0/(len(namevals)+1)
                    fig.legend(lins,namevals,loc='lower center',ncol=len(namevals),prop={'size':siz})

        fig.savefig(argis[2])
