import numpy as np

from sys import argv

"""
Saves the position of the facilities and clients on a file.
"""
def save_pos(pos_fname,fcs_x,fcs_y,cls_x,cls_y,dim_x,dim_y):
    fp = open(pos_fname,"w")
    fp.write("d %d %d\n"%(dim_x,dim_y))
    n_facilities = fcs_x.size
    n_clients = cls_x.size
    assert fcs_x.size == fcs_y.size
    assert cls_x.size == cls_y.size
    for i in range(n_facilities):
        fp.write("f %d %d\n"%(fcs_x[i],fcs_y[i]))
    for i in range(n_clients):
        fp.write("c %d %d\n"%(cls_x[i],cls_y[i]))
    fp.close()

"""
SEESU Problem:
clients on the Same locations than facilities
        on the Euclidian plane (with euclidean distances).
    places are Equiprobably distributed
          on a Square
 with constant Unitary weights for each client
"""
"""
DEESU Problem:
clients on the Different locations than facilities
        on the Euclidian plane (with euclidean distances).
    places are Equiprobably distributed
          on a Square
 with constant Unitary weights for each client
"""

def problem(fname,n=100,m=100,board_size=10000,
        fcost=800,vgain=300,tcost=1,pos_fname=None,same=False):
    n_facilities = n
    n_clients = m
    # Create positions x and y and write them to pos_fname
    xpos = np.random.randint(0,board_size,n_facilities+n_clients)
    ypos = np.random.randint(0,board_size,n_facilities+n_clients)
    if same:
        xposfac = xpos[:n_facilities]
        yposfac = ypos[:n_facilities]
        xposcli = xpos[:n_clients]
        yposcli = ypos[:n_clients]
    else:
        xposfac = xpos[:n_facilities]
        yposfac = ypos[:n_facilities]
        xposcli = xpos[n_facilities:]
        yposcli = ypos[n_facilities:]
    if pos_fname != None:
        save_pos(pos_fname,xposfac,yposfac,xposcli,yposcli,
            board_size,board_size)
    # Create file with the problem description
    fi = open(fname,"w")
    fi.write("%d\n"%fcost)
    fi.write("%d\n"%vgain)
    fi.write("%d\n"%tcost)
    fi.write("%d\n"%n_facilities)
    fi.write("%d\n"%n_clients)
    # facility-facility distance matrix
    fi.write("\n")
    for i in range(n_facilities):
        for j in range(n_facilities):
            dist = ((xposfac[i]-xposfac[j])**2+(yposfac[i]-yposfac[j])**2)**0.5
            fi.write("%d "%int(round(dist)))
        fi.write("\n")
    # client weights
    fi.write("\n")
    for i in range(n_clients):
        fi.write("%d "%1)
    fi.write("\n")
    # facility-client distance matrix
    fi.write("\n")
    for i in range(n_facilities):
        for j in range(n_clients):
            dist = ((xposfac[i]-xposcli[j])**2+(yposfac[i]-yposcli[j])**2)**0.5
            fi.write("%d "%int(round(dist)))
        fi.write("\n")
    fi.close()

# MAIN
if __name__ == '__main__':
    right = False
    if (len(argv)==9 and argv[1]=="seesu") or (len(argv)==10 and argv[1]=="deesu"):
        right = True
    if not right:
        print("Usage:")
        print("%s seesu <n> <size> <fcost> <vgain> <tcost> <fname> <pos_fname>"%argv[0])
        print("%s deesu <n> <m> <size> <fcost> <vgain> <tcost> <fname> <pos_fname>"%argv[0])
    else:
        if argv[1] == "seesu":
            problem(argv[7],pos_fname=argv[8],
                n=int(argv[2]),m=int(argv[2]),
                board_size=int(argv[3]),
                fcost=int(argv[4]),
                vgain=int(argv[5]),
                tcost=int(argv[6]))
        elif argv[1] == "deesu":
            problem(argv[8],pos_fname=argv[9],
                n=int(argv[2]),m=int(argv[3]),
                board_size=int(argv[4]),
                fcost=int(argv[5]),
                vgain=int(argv[6]),
                tcost=int(argv[7]))
