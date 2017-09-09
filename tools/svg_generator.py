import numpy as np

from sys import argv

def generate_svg(pos_file,sols_file,svg_file,scale=0.5):
    # Read positions:
    dims = None
    pfile = open(pos_file,"r")
    facxpos = []
    facypos = []
    clixpos = []
    cliypos = []
    for lin in pfile:
        lin = lin.strip()
        if lin == "": continue
        kind,x,y = lin.split()
        x = int(x)
        y = int(y)
        if kind=="f":
            facxpos.append(x)
            facypos.append(y)
        elif kind=="c":
            clixpos.append(x)
            cliypos.append(y)
        elif kind=="d":
            dims = (int(x*scale),int(y*scale))
        else:
            raise ValueError('Invalid key on position file')
    pfile.close()
    facxpos = np.array(facxpos)
    facypos = np.array(facypos)
    clixpos = np.array(clixpos)
    cliypos = np.array(cliypos)
    # Read solutions:
    best_sol = None
    if sols_file!=None:
        sfile = open(sols_file,"r")
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
        clixpos[i]*scale,cliypos[i]*scale))
    for i in range(facxpos.size):
        if best_sol!=None and i in best_sol.keys():
            svgfile.write("<rect x=\"%.2f\" y=\"%.2f\" width=\"9\" height=\"9\" fill=\"blue\" stroke-width=\"2\" stroke=\"black\" fill-opacity=\"0.75\" />\n"%(            facxpos[i]*scale-4.5,facypos[i]*scale-4.5))
        else:
            svgfile.write("<rect x=\"%.2f\" y=\"%.2f\" width=\"9\" height=\"9\" stroke-width=\"2\" stroke=\"black\" fill-opacity=\"0\"/>\n"%(facxpos[i]*scale-4.5,facypos[i]*scale-4.5))
    if best_sol!=None:
        for i in best_sol:
            for k in best_sol[i]:
                svgfile.write("<line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"blue\" stroke-width=\"2\"/>\n"%(
                facxpos[i]*scale,facypos[i]*scale,
                clixpos[k]*scale,cliypos[k]*scale))
    svgfile.write("</svg>\n")
    svgfile.close()

# MAIN
if __name__ == '__main__':
    right = False
    if len(argv)==3 or len(argv)==4:
        right = True
    if not right:
        print("Usage:")
        print("%s <pos_fname> <output_svg_fname>"%argv[0])
        print("%s <pos_fname> <sol_fname> <output_svg_fname>"%argv[0])
    else:
        if len(argv)==3:
            generate_svg(argv[1],None,argv[2])
        elif len(argv)==4:
            generate_svg(argv[1],argv[2],argv[3])
