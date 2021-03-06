# -*- coding: utf-8 -*-

import sys
import matplotlib
import itertools
from scipy.stats import linregress

import matplotlib.patches as mpatches

# v So that doens't trow error through ssh.
matplotlib.use('Agg')

import matplotlib.pyplot as plt
import numpy as np

def colori(kk,nn):
    kk = nn-1-kk
    if kk==0: return (1.0,0,0)
    if kk==nn-1: return (0,0,0)
    if kk==1 and nn==3: return (0,0,1.0)
    flt = (kk-1.0)/(nn-3.0)
    return (0,1-flt,flt)

if __name__ == '__main__':
    argis = []
    for arg in sys.argv:
        if arg[0]!='-': argis.append(arg)
    if len(argis)<4 or len(argis)>6:
        print("Usage: %s [-lx] [-ly] [-sx] [-sy] [-colors=<colordict>] <summary_file> <output> <title> [<var_1>] [<var_2>]"%argis[0])
    else:
        dims = len(argis)-4
        linewidth = 1.0+len(['meh' for x in sys.argv if x=="-w"])
        logx = "-lx" in sys.argv
        logy = "-ly" in sys.argv
        sharex = "-sx" in sys.argv
        sharey = "-sy" in sys.argv
        histogram = "-hg" in sys.argv
        nullpoints = "-np" in sys.argv
        colored = any(["-colors" in x for x in sys.argv])
        if colored:
            dictval = [x.split("=")[1] for x in sys.argv if "-colors" in x][0]
            colordict = eval(dictval)
        linreg = "-r" in sys.argv
        assert(not nullpoints or not linreg)
        assert(not nullpoints or (logx and logy) or (not logx and not logy))

        points = {}
        #
        inputf = open(argis[1])
        for li in inputf:
            li = li.strip()
            if li=="": continue
            li = li.split()

            if len(li)!=dims+4:
                raise ValueError("Invalid line: "+str(li))
            name = li[0]
            xx = 'c' if li[1]=='c' else float(li[1])
            yy = float(li[-2])
            dim = ['k' if i=='k' else float(i) if '.' in i else int(i) for i in li[2:-2]]
            key = tuple([name,xx]+dim)
            if key not in points:
                points[key] = []
            points[key].append(yy)
        inputf.close()
        # Find the values for each dimension:
        namevals = sorted(list(set([k[0] for k in points])))
        xxvals = sorted(list(set([k[1] for k in points if k[1]!='c'])))
        dimvals = [sorted(list(set([k[2+i] for k in points if k[2+i]!='k']))) for i in range(dims)]
        if histogram: namevals = namevals[::-1]

        for name in namevals:
            for xx in xxvals+['c']:
                if dims==1:
                    if tuple([name,xx,'k']) in points:
                        for di in dimvals[0]:
                            points[tuple([name,xx,di])] = points[tuple([name,xx,'k'])]
                elif dims==2:
                    if tuple([name,xx,'k','k']) in points:
                        for di2 in dimvals[2]:
                            for di1 in dimvals[0]:
                                points[tuple([name,xx,di1,di2])]=points[tuple([name,xx,'k','k'])]
                    else:
                        for di1 in dimvals[0]:
                            if tuple([name,xx,di1,'k']) in points:
                                for di2 in dimvals[1]:
                                    points[tuple([name,xx,di1,di2])]=points[tuple([name,xx,di1,'k'])]
                        for di2 in dimvals[1]:
                            if tuple([name,xx,'k',di2]) in points:
                                for di1 in dimvals[0]:
                                    points[tuple([name,xx,di1,di2])]=points[tuple([name,xx,'k',di2])]


        yplots = 1 if dims<1 else len(dimvals[0])
        xplots = 1 if dims<2 else len(dimvals[1])

        fig, axarr = plt.subplots(yplots,xplots,sharex=sharex,sharey=sharey,figsize=(8+(dims>=2)*6,10))
        fig.suptitle(argis[3], fontsize=18)

        dimnames = argis[4:]
        assert(len(dimnames)==dims)
        truefinalnames = []

        for i in range(yplots):
            if dims==2:
                for j in range(xplots):
                    if logx: axarr[i,j].set_xscale('log')
                    if logy: axarr[i,j].set_yscale('log')
            else:
                if logx: axarr[i].set_xscale('log')
                if logy: axarr[i].set_yscale('log')

        for i in range(yplots):
            if dims>=1: yaxisval = dimvals[0][i]
            #
            for j in range(xplots):
                if dims>=2: xaxisval = dimvals[1][j]
                #
                if dims==2: keypart = [yaxisval,xaxisval]
                elif dims==1: keypart = [yaxisval]
                else: keypart = []

                #
                xxmin = min(xxvals)
                xxmax = max(xxvals)
                if dims==2: subaxxarr = axarr[i,j]
                elif dims==1: subaxxarr = axarr[i]
                else: subaxxarr = axarr[0]

                #
                subaxxarr.set_xlim((xxmin,xxmax))
                title = ""
                if dims>=1: title+= "%s = $%s$"%(dimnames[0],str(yaxisval))
                if dims>=2: title+= ", %s = $%s$"%(dimnames[1],str(xaxisval))
                if title!= "": subaxxarr.set_title(title)

                if i==0 and j==0: lins = []
                for k in range(len(namevals)):
                    name = namevals[k]

                    keytup = lambda xxxx : tuple([name,xxxx]+keypart)
                    myxxvals = [xx for xx in xxvals+['c'] if keytup(xx) in points]
                    assert(all([xx=='c' for xx in myxxvals]) or 'c' not in myxxvals)

                    col = colori(k,len(namevals)) if (not colored or name not in colordict) else colordict[name]
                    if 'c' in myxxvals:
                        pointsyy = points[keytup('c')]
                        try:
                            if not nullpoints:
                                for yy in pointsyy:
                                    subaxxarr.plot([xxmin,xxmax],[yy,yy],"-",color=col,alpha=0.1)
                            yymean = np.mean(pointsyy)
                            lin = subaxxarr.plot([xxmin,xxmax],[yymean,yymean],'-',color=col,
                                linewidth=linewidth)
                        except ValueError: pass
                    else:
                        data = [(xx,points[keytup(xx)]) for xx in myxxvals]
                        #
                        mean = [(p[0],np.mean(p[1])) for p in data if len(p[1])>0]
                        dots = [[(p[0],y) for y in p[1]] for p in data]
                        dots = list(itertools.chain.from_iterable(dots))
                        #
                        meanx = [dot[0] for dot in mean]
                        meany = [dot[1] for dot in mean]
                        dotsx = [dot[0] for dot in dots]
                        dotsy = [dot[1] for dot in dots]

                        if histogram:
                            _,_,patchs = subaxxarr.hist(dotsx,range=(xxmin,xxmax),bins=40,color=col)
                            lins.append(patchs[0])
                        else:
                            try:
                                if not nullpoints:
                                    subaxxarr.plot(dotsx,dotsy,"o",color=col,alpha=0.1)
                                lin = subaxxarr.plot(meanx,meany,'-',color=col,linewidth=linewidth)
                            except ValueError: pass

                            if linreg:
                                if logx:
                                    (slope,inter,rcoef,pcoef,stderr) = linregress(np.log10(meanx),np.log10(meany))
                                    yini = (xxmin**slope)*(10**inter)
                                    yend = (xxmax**slope)*(10**inter)
                                    subaxxarr.text(1.4,0.15,'$\\log_{10}y= %.4f \\log_{10}x %+.4f$'%(slope,inter), fontsize=12)
                                else:
                                    (slope,inter,rcoef,pcoef,stderr) = linregress(meanx,meany)
                                    yini = xxmin*slope+inter
                                    yend = xxmax*slope+inter
                                    subaxxarr.text(1.4,0.15,'$y= %.4f x %+.4f$'%(slope,inter), fontsize=12)

                                coldark = (col[0]*0.6,col[1]*0.6,col[2]*0.6)
                                loglin = subaxxarr.plot([xxmin,xxmax],[yini,yend],'--',color=coldark,linewidth=linewidth)
                                truefinalnames.append("reg. "+name)
                                lins.append(loglin[0])
                    if name not in truefinalnames:
                        try:
                            if not histogram:
                                lins.append(lin[0])
                            truefinalnames.append(name)
                        except:
                            pass
                if i==0 and j==0:
                    siz = 14.0
                    print(lins)
                    print(truefinalnames)
                    if not histogram or colored:
                        fig.legend(lins,truefinalnames,loc='lower center',ncol=len(namevals),prop={'size':siz})
                    # if not histogram:
                    # if colored:
                    #     patches = [mpatches.Patch(color=colordict[pname], label=pname)
                    #         for pname in truefinalnames]
                    #     plt.legend(handles=patches,loc='lower center',
                    #         ncol=len(namevals),prop={'size':siz},bbox_to_anchor=(0.5, -0.05))
        #
        for i in range(yplots):
            if dims==2:
                for j in range(xplots):
                    axarr[i,j].grid()
            else:
                axarr[i].grid()

        fig.savefig(argis[2])
