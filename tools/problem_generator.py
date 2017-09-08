import numpy as np

from sys import argv

"""
Saves the position of the facilities and clients on a file.
"""
def save_pos(pos_fname,fcs_x,fcs_y,cls_x,cls_y):
    fp = open(pos_fname,"w")
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

def seesu_problem(fname,n=100,board_size=10000,
        fcost=800,vgain=300,tcost=1,pos_fname=None):
    n_facilities = n
    n_clients = n
    # Create positions x and y and write them to pos_fname
    xpos = np.random.randint(0,board_size,n_facilities)
    ypos = np.random.randint(0,board_size,n_facilities)
    if pos_fname != None:
        save_pos(pos_fname,xpos,ypos,xpos,ypos)
    # Create file with the problem description
    fi = open(fname,"w")
    fi.write("%d\n"%fcost)
    fi.write("%d\n"%vgain)
    fi.write("%d\n"%tcost)
    fi.write("%d\n"%n_facilities)
    fi.write("%d\n"%n_clients)
    # facility-facility distance matrix
    for i in range(n_facilities):
        for j in range(n_facilities):
            dist = ((xpos[i]-xpos[j])**2+(ypos[i]-ypos[j])**2)**0.5
            fi.write("%d "%int(round(dist)))
        fi.write("\n")
    # client weights
    for i in range(n_clients):
        fi.write("%d "%1)
    fi.write("\n")
    # facility-client distance matrix
    for i in range(n_facilities):
        for j in range(n_clients):
            dist = ((xpos[i]-xpos[j])**2+(ypos[i]-ypos[j])**2)**0.5
            fi.write("%d "%int(round(dist)))
        fi.write("\n")
    fi.close()

# MAIN
if __name__ == '__main__':
    right = False
    if len(argv)==9 and argv[1]=="seesu":
        right = True
    if not right:
        print("Usage:")
        print("%s seesu <n> <size> <fcost> <vgain> <tcost> <fname> <pos_fname>"%argv[0])
    else:
        seesu_problem(argv[7],pos_fname=argv[8],
            n=int(argv[2]),
            board_size=int(argv[3]),
            fcost=int(argv[4]),
            vgain=int(argv[5]),
            tcost=int(argv[6]))
