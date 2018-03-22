import numpy as np

from sys import argv

def generate_svg(pos_file,geoloc_sol,lpsolve_sol,svg_file,size=1024,labels=False):
    # Read positions:
    dims = None
    pfile = open(pos_file,"r")
    facxpos = []
    facypos = []
    clixpos = []
    cliypos = []
    scale = (1.0,1.0)
    tread = False
    for lin in pfile:
        lin = lin.strip()
        if lin == "": continue
        if lin[0] == "#": continue
        if lin[0] == "!":
            lin = lin.split()
            if lin[1] == "tread":
                tread=True
            elif lin[1] == "vgain":
                vgain=float(lin[2])
            elif lin[1] == "tcost":
                tcost=float(lin[2])
            continue
        kind,x,y = lin.split()
        x = int(float(x))
        y = int(float(y))
        if kind=="f":
            facxpos.append(x)
            facypos.append(y)
        elif kind=="c":
            clixpos.append(x)
            cliypos.append(y)
        elif kind=="d":
            if x < y:
                dims = (int(size*x/y),size)
                scale = (float(size)/y,float(size)/y)
            else:
                dims = (size,int(size*y/x))
                scale = (float(size)/x,float(size)/x)
        else:
            raise ValueError('Invalid key on position file')
    pfile.close()
    facxpos = np.array(facxpos)
    facypos = np.array(facypos)
    clixpos = np.array(clixpos)
    cliypos = np.array(cliypos)
    # Read solutions:
    best_sol = None
    if geoloc_sol!=None:
        sfile = open(geoloc_sol,"r")
        for lin in sfile:
            lin = lin.strip()
            if lin[0]=='#': continue
            if lin.split()[0] == "SOLUTION:":
                if best_sol != None:
                    break
                best_sol = {}
            else:
                lin = lin.lstrip().split(":")
                if lin[0]=="Value":
                    continue
                elif lin[0]=="Facilities":
                    continue
                else:
                    f_index = int(lin[0])
                    o_indexes = [int(x) for x in lin[1].split()]
                    best_sol[f_index] = o_indexes
        sfile.close()
    elif lpsolve_sol!=None:
        best_sol = {}
        sfile = open(lpsolve_sol,"r")
        for lin in sfile:
            lin = lin.strip()
            if len(lin)==0: continue
            if lin[0]=="X":
                val = int(lin.split()[1])
                lin = lin.split()[0]
                fac = int(lin[1:])
                if val>0: best_sol[fac] = []
            elif lin[0]=="Y":
                val = int(lin.split()[1])
                lin = lin.split()[0]
                lin = lin[1:].split("c")
                cli = int(lin[0])
                fac = int(lin[1])
                if val>0: best_sol[fac].append(cli)
            elif lin[0]=="Z":
                val = int(lin.split()[1])
                lin = lin.split()[0]
                cli = int(lin[1:])
                if val==1:
                    # Find nearest fac:
                    nearest_dist = None
                    nearest_fac = None
                    for fa in best_sol:
                        dist = ((facxpos[fa]-clixpos[cli])**2+(facypos[fa]-cliypos[cli])**2)**0.5
                        if nearest_dist==None or dist<nearest_dist:
                            nearest_dist = dist
                            nearest_fac = fa
                    assert(nearest_fac!=None)
                    best_sol[nearest_fac].append(cli)
        sfile.close()

    # Write SVG file:
    svgfile = open(svg_file,"w")
    svgfile.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    head = "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\""
    if dims!=None: head+= " width=\"%d\" height=\"%d\""%dims
    head += ">\n"
    svgfile.write(head)
    if dims!=None:
        svgfile.write("<rect x=\"0\" y=\"0\" width=\"%d\" height=\"%d\" stroke-width=\"2\" stroke=\"black\" fill-opacity=\"0\" />\n"%dims)
    for i in range(clixpos.size):
        svgfile.write("<circle cx=\"%.2f\" cy=\"%.2f\" r=\"4\" fill=\"red\"/>\n"%(
        clixpos[i]*scale[0],cliypos[i]*scale[1]))
    for i in range(facxpos.size):
        if best_sol!=None and i in best_sol.keys():
            svgfile.write("<rect x=\"%.2f\" y=\"%.2f\" width=\"7\" height=\"7\" fill=\"blue\" stroke-width=\"2\" stroke=\"black\" fill-opacity=\"0.75\" />\n"%(            facxpos[i]*scale[0]-3.5,facypos[i]*scale[1]-3.5))
        else:
            svgfile.write("<rect x=\"%.2f\" y=\"%.2f\" width=\"7\" height=\"7\" stroke-width=\"2\" stroke=\"black\" fill-opacity=\"0\"/>\n"%(facxpos[i]*scale[0]-3.5,facypos[i]*scale[1]-3.5))
    if best_sol!=None:
        for i in best_sol:
            for k in best_sol[i]:
                if tread:
                    color = "green"
                else:
                    dist = ((facxpos[i]-clixpos[k])**2+(facypos[i]-cliypos[k])**2)**0.5
                    grad = int(205.0*dist*tcost/vgain)
                    color = "rgb(%d,%d,255)"%(grad,grad)
                svgfile.write("<line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"2\"/>\n"%(
                facxpos[i]*scale[0],facypos[i]*scale[1],
                clixpos[k]*scale[0],cliypos[k]*scale[1],color))
    # Labels
    if labels:
        for i in range(facxpos.size):
            textx = facxpos[i]*scale[0]-20
            texty = facypos[i]*scale[1]-10
            textx = max(textx,10)
            texty = max(texty,10)
            svgfile.write("<text x=\"%.2f\" y=\"%.2f\" font-size=\"10\">%d</text>\n"%(textx+3.5,texty+3.5,i))
    svgfile.write("</svg>\n")
    svgfile.close()

# MAIN
if __name__ == '__main__':
    nargs = []
    flags = []
    geolocsolfile = None
    lpsolfile = None
    i = 0
    while i<len(argv):
        a = argv[i]
        if a[0]=='-':
            if a=="-g" or a=="-p":
                if i+1>=len(argv) or geolocsolfile or lpsolfile:
                    nargs = []
                    break
                if a=="-g":
                    geolocsolfile = argv[i+1]
                elif a=="-p":
                    lpsolfile = argv[i+1]
                i+=1
            else:
                flags.append(a)
        else:
            nargs.append(a)
        i+=1
    if len(nargs)!=3:
        print("Usage:")
        print("%s <probfname> [-l] [-g <geolocsolfile> | -p <lpsolfile>] <outfile>"%argv[0])
    else:
        generate_svg(nargs[1],geolocsolfile,lpsolfile,nargs[2],labels='-l' in flags)
