import sys

def strnum(num):
    if isinstance(num,float):
        return "%.3f"%num
    else:
        return str(num)

# NOTE: \usepackage{slashbox} IS REQUIRED FOR THIS TABLE TO WORK!
# https://www.ctan.org/pkg/slashbox

if __name__ == '__main__':
    if len(sys.argv)!=5:
        print("Usage: python %s <file> <dim1> <dim2> <dim3>"%sys.argv[0])
    else:
        vals = {}
        dim1 = set()
        dim2 = set()
        dim3 = set()
        fil = open(sys.argv[1])
        for lin in fil:
            lin = lin.strip().split(' ')
            std = lin[-1]
            mean = lin[-3]
            prob = tuple(lin[:-3])
            prob = tuple([float(x) if '.' in x else int(x) for x in prob])
            dim1.add(prob[0])
            dim2.add(prob[1])
            dim3.add(prob[2])
            mean = float(mean) if '.' in mean else int(mean)
            std = float(std) if '.' in std else int(std)
            vals[prob] = (mean,std)
        fil.close()
        dim1 = sorted(list(dim1))
        dim2 = sorted(list(dim2))
        dim3 = sorted(list(dim3))
        for di1 in dim1:
            print("Table for $%s = %s$:\n"%(sys.argv[2],di1))
            print("\\begin{tabular}{| r"+" | r"*len(dim3)+" |}")
            print("\hline \\backslashbox{$%s$}{$%s$} & "%(sys.argv[3],sys.argv[4])+" & ".join(["$%s$"%strnum(x) for x in dim3]))
            for di2 in dim2:
                line = "\\\\ \hline $%s$ "%(strnum(di2))
                for di3 in dim3:
                    if (di1,di2,di3) in vals:
                        (mean,std) = vals[(di1,di2,di3)]
                        line+=" & $%s \\pm %s$"%(strnum(mean),strnum(std))
                    else:
                        line+=" & $? \\pm ?$"
                print(line)
            print("\\\\ \hline")
            print("\\end{tabular}")
            print("")
