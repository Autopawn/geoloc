import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d, Axes3D
import numpy as np

fname = "collect/nprop_means.txt"

fil = open(fname)
xpoints = set()
ypoints = set()
points = {}
for lin in fil:
    lin = lin.strip().split(' ')
    (_,pz,nn,nprop) = lin
    pz = float(pz)
    nn = float(nn)
    nprop = float(nprop)
    xpoints.add(pz)
    ypoints.add(nn)
    points[(pz,nn)] = nprop
fil.close()

xGrid,yGrid = np.meshgrid(sorted(list(xpoints)),sorted(list(ypoints)))
zpoints = []
for i in range(xGrid.shape[0]):
    zpoints.append([])
    for j in range(xGrid.shape[1]):
        zpoints[-1].append(points[(xGrid[i,j],yGrid[i,j])])

fig = plt.figure()
ax = Axes3D(fig)
ax.set_xlabel('$PZ$')
ax.set_ylabel('$N$')
ax.set_zlabel('$E$')

ax.plot_wireframe(xGrid,yGrid,zpoints)

plt.show()
