import numpy as np

from sys import argv

def problem_translate(inputfname,fname,kind="geoloc"):
    # Create file with the problem description
    tread = False
    facs = []
    clis = []
    fi = open(inputfname)
    for lin in fi:
        lin = lin.strip()
        if lin=="": continue
        if lin[0]=='#': continue
        lin = lin.split()
        if lin[0]=='!':
            if lin[1]=="fcost":
                fcost = int(lin[2])
            if lin[1]=="vgain":
                vgain = int(lin[2])
            if lin[1]=="tcost":
                tcost = int(lin[2])
            if lin[1]=="tread":
                tread = True
        elif lin[0]=='f':
            facs.append((int(lin[1]),int(lin[2])))
        elif lin[0]=='c':
            clis.append((int(lin[1]),int(lin[2])))
    fi.close()

    facs = np.array(facs)
    clis = np.array(clis)

    if kind=="geoloc":
        geoloc_problem(fname,facs,clis,fcost,vgain,tcost,tread)
    elif kind=="lpsolve":
        lpsolve_problem(fname,facs,clis,fcost,vgain,tcost,tread)


def geoloc_problem(fname,facs,clis,fcost,vgain,tcost,tread):
    fo = open(fname,"w")

    fo.write("%d\n"%fcost)
    fo.write("%d\n"%vgain)
    fo.write("%d\n"%tcost)
    fo.write("%d\n"%facs.shape[0])
    fo.write("%d\n"%clis.shape[0])
    # facility-facility distance matrix
    fo.write("\n")
    for i in range(facs.shape[0]):
        for j in range(facs.shape[0]):
            dist = ((facs[i,0]-facs[j,0])**2+(facs[i,1]-facs[j,1])**2)**0.5
            fo.write("%d "%int(round(dist)))
        fo.write("\n")
    # client weights
    fo.write("\n")
    for i in range(clis.shape[0]):
        fo.write("%d "%1)
    fo.write("\n")
    # facility-client distance matrix
    fo.write("\n")
    for j in range(facs.shape[0]):
        for i in range(clis.shape[0]):
            dist = ((facs[j,0]-clis[i,0])**2+(facs[j,1]-clis[i,1])**2)**0.5
            if tread:
                if dist*tcost<vgain: dist = 0
                else: dist = dist+1 # So we will never have to reach it.
            fo.write("%d "%int(round(dist)))
        fo.write("\n")
    fo.close()

def lpsolve_problem(fname,facs,clis,fcost,vgain,tcost,tread):
    # TODO: Make it more efficient when treas is false!

    fo = open(fname,"w")
    # Objective function:
    fo.write("max:")
    if tread:
        for j in range(facs.shape[0]):
            fo.write(" -%d X%d"%(fcost,j))
        for i in range(clis.shape[0]):
            fo.write(" +%d Z%d"%(vgain,i))
        fo.write(";\n")
        fo.write("\n")
        # Gain restriction:
        one_near = False
        for i in range(clis.shape[0]):
            fo.write("Z%d <= "%i)
            for j in range(facs.shape[0]):
                dist = ((facs[j,0]-clis[i,0])**2+(facs[j,1]-clis[i,1])**2)**0.5
                if dist*tcost<vgain:
                    fo.write("+X%d "%j)
                    one_near = True
            if not one_near:
                fo.write("0 ")
            fo.write(";\n")
        fo.write("\n")
        # Binary var restrictions:
        fo.write("bin "+",".join(["X%d"%x for x in range(facs.shape[0])])+";\n")
        fo.write("bin "+",".join(["Z%d"%x for x in range(clis.shape[0])])+";\n")
    else:
        for j in range(facs.shape[0]):
            fo.write(" -%d X%d"%(fcost,j))
        for i in range(clis.shape[0]):
            for j in range(facs.shape[0]):
                dist = ((facs[j,0]-clis[i,0])**2+(facs[j,1]-clis[i,1])**2)**0.5
                fo.write(" %+d Y%dc%d"%(1*(vgain-tcost*int(round(dist))),i,j))
        fo.write(";\n")
        fo.write("\n")
        # Plant location restriction:
        for i in range(clis.shape[0]):
            for j in range(facs.shape[0]):
                fo.write("Y%dc%d <= X%d;\n"%(i,j,j))
        # Client reach restiction
        fo.write("\n")
        for i in range(clis.shape[0]):
            for j in range(facs.shape[0]):
                fo.write("+Y%dc%d "%(i,j))
            fo.write("<= 1;\n")
        fo.write("\n")
        # Binary var restrictions:
        fo.write("bin "+",".join(["X%d"%x for x in range(facs.shape[0])])+";\n")
        for i in range(clis.shape[0]):
            fo.write("bin "+",".join(["Y%dc%d"%(i,x) for x in range(facs.shape[0])])+";\n")
        #
    fo.close()

# MAIN
if __name__ == '__main__':
    if len(argv)!=4 or (argv[2] not in ("geoloc","lpsolve")):
        print("Usage: python %s <probfile> {geoloc|lpsolve} <outfile> "%argv[0])
    else:
        problem_translate(argv[1],argv[3],argv[2])
