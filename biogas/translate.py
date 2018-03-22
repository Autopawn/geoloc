import numpy as np



weis = []
xs = []
ys = []

fi = open("base.csv")
for lin in fi:
    lin = lin.strip().split(";")
    xs.append(int(lin[-4])/1000)
    ys.append(int(lin[-3])/1000)
    weis.append(int(lin[-2]))
fi.close()

xs = np.array(xs)
ys = np.array(ys)

minx = np.min(xs)
miny = np.min(ys)
maxx = np.max(xs)
maxy = np.max(ys)

xs -= minx
ys -= miny
sizx = int(np.ceil(np.max(xs)))
sizy = int(np.ceil(np.max(ys)))

print("x: %f %f"%(1000*minx,1000*(minx+sizx)))
print("y: %f %f"%(1000*miny,1000*(miny+sizy)))


fo = open("out_prob","w")

# Will work with dollars:

fo.write("! fcost %d\n"%1740667)
fo.write("! vgain %d\n"%754)
fo.write("! tcost %d\n"%28)
fo.write("d %d %d\n"%(sizx,sizy))

for i in range(len(xs)):
    fo.write("f %.3f %.3f\n"%(xs[i],ys[i]))

for i in range(len(xs)):
    fo.write("c %.3f %.3f\n"%(xs[i],ys[i]))

fo.close()


fw = open("out_weis","w")
for w in weis:
    fw.write("%d\n"%(w*8//10))
fw.close()
