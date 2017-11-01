import sys
import matplotlib
import matplotlib.pyplot as plt
import numpy as np

colors = ["red","black","green","blue"]
figures = ["s","^","o","r"]

if __name__ == '__main__':
    if len(sys.argv)<3:
        print("Usage: %s <summary_file> <output>"%sys.argv[0])
    else:
        logx = "-lx" in sys.argv
        logy = "-ly" in sys.argv

        points = {}
        #
        inputf = open(sys.argv[1])
        for li in inputf:
            li = li.strip()
            if li=="": continue
            name,nn,alpha,density,yvalue = li.split()
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

        # v So that doens't trow error through ssh.
        matplotlib.use('Agg')
        fig, axarr = plt.subplots(len(denvals),len(alphavals),sharex=True,sharey=True)

        for i in range(len(denvals)):
            den = denvals[i]
            for j in range(len(alphavals)):
                alpha = alphavals[j]
                #
                for k in range(len(namevals)):
                    name = namevals[k]
                    mynnvals = [nn for nn in nnvals if (name,nn,alpha,den) in points.keys()]
                    data = [points[(name,nn,alpha,den)] for nn in mynnvals]
                    data = np.array(data).T
                    dots = data+np.array(mynnvals)*1j
                    dots = np.array([(int(np.imag(x)),float(np.real(x))) for x in dots.flatten()])
                    mean = np.mean(data,axis=0)
                    axarr[i,j].set_title("$D=%d$  $\\alpha=%d$"%(den,alpha))
                    if logx: axarr[i,j].set_xscale('log')
                    if logy: axarr[i,j].set_yscale('log')
                    axarr[i,j].plot(dots[:,0],dots[:,1],figures[k],color=colors[k])
                    axarr[i,j].plot(mynnvals,mean,'-',color=colors[k])

        fig.savefig(sys.argv[2])
