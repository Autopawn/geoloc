import sys
import matplotlib.pyplot as plt
import numpy as np

if __name__ == '__main__':
    if len(sys.argv)!=4:
        print("Usage: python %s <title> <summary_file> <output>"%sys.argv[0])
    else:
        points = {}

        inputf = open(sys.argv[2])
        for li in inputf:
            li = li.strip()
            if li=="": continue
            name,sx,sy = li.split()
            sx = int(sx)
            sy = float(sy)
            if name not in points:
                points[name] = []
            points[name].append((sx,sy))
        inputf.close()

        color = plt.cm.rainbow(np.linspace(0,1,len(points)))

        fig = plt.figure()
        fig.suptitle(sys.argv[1].replace('\\n','\n'))

        ax = plt.subplot(111)

        i = 0
        for name in sorted(points.keys()):
            col = color[i]
            i += 1
            tpoints = np.array(points[name])
            ptsx = tpoints[:,0]
            ptsy = tpoints[:,1]
            ax.plot(ptsx,ptsy,'r-',label=name.upper(),c=col)

        box = ax.get_position()
        ax.set_position([box.x0, box.y0 + box.height * 0.1,
            box.width, box.height * 0.9])

        if len(points)>1:
            ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.05),
                ncol=len(points))

        fig.savefig(sys.argv[3])
