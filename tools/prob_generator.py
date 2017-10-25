import numpy as np

from sys import argv

"""
This program creates a problem with the given variables and creates random positions for instalations and clients.

n: number of clients.
m: number of facilities places.
size: of the space where the points are located.

fcost: facility cost.
vgain: gain for reaching a client.
tcost: transport cost for distance for each reached client.

-s: Flag so that the clients and places are at the same position.
-t: Flag so that the distances smaller than the critical radious (vgain/tcost)
    are taken as 0 (nullifing the transpor costs), resulting in a "discriminant
    set covering".

"""

def random_pos(fname,n,m,board_size,fcost,vgain,tcost,same=False,tread=False):
    if same and n!=m:
        raise Exception("When using \"-s\", it should be that n == m")
    # Create positions x and y and write them to pos_fname
    xpos = np.random.randint(0,board_size,m+n)
    ypos = np.random.randint(0,board_size,m+n)
    if same:
        xposcli = xpos[:max(n,m)]
        yposcli = ypos[:max(n,m)]
        xposfac = xpos[:max(n,m)]
        yposfac = ypos[:max(n,m)]
    else:
        xposfac = xpos[n:]
        yposfac = ypos[n:]
        xposcli = xpos[:n]
        yposcli = ypos[:n]
    #
    fp = open(fname,"w")
    if tread: fp.write("! tread\n")
    fp.write("! fcost %d\n"%fcost)
    fp.write("! vgain %d\n"%vgain)
    fp.write("! tcost %d\n"%tcost)
    fp.write("d %d %d\n"%(board_size,board_size))
    for i in range(m):
        fp.write("f %d %d\n"%(xposfac[i],yposfac[i]))
    for i in range(n):
        fp.write("c %d %d\n"%(xposcli[i],yposcli[i]))
    fp.close()

if __name__ == '__main__':
    nargs = []
    flags = []
    for a in argv:
        if a[0]=='-':
            flags.append(a)
        else:
            nargs.append(a)
    #
    if len(nargs)!=8:
        print("Usage: python %s [-s] [-t] <n> <m> <size> <fcost> <vgain> <tcost> <outfile> "%argv[0])
    else:
        random_pos(nargs[7],int(nargs[1]),int(nargs[2]),int(nargs[3]),
            int(nargs[4]),int(nargs[5]),int(nargs[6]),
            same='-s' in flags,tread='-t' in flags)
