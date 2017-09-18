from sys import argv

"""
Reads a problem file and creates an lp problem file from it.
"""
def create_fp_problem(input_fname,output_fname):
    fi = open(input_fname,"r")
    line_n = 0
    fafa_dists = []
    facli_dists = []
    for li in fi:
        if li.strip()=="": continue
        line_n += 1
        if line_n == 1:
            facility_cost = int(li)
        elif line_n == 2:
            variant_gain = int(li)
        elif line_n == 3:
            transport_cost = int(li)
        elif line_n == 4:
            n_facilities = int(li)
        elif line_n == 5:
            n_clients = int(li)
        elif line_n <= 5+n_facilities:
            fafa_dists.append([int(x) for x in li.strip().split(" ")])
            assert(len(fafa_dists[-1])==n_facilities)
        elif line_n == 6+n_facilities:
            cli_weights = [int(x) for x in li.strip().split(" ")]
        elif line_n <= 6+n_facilities*2:
            facli_dists.append([int(x) for x in li.strip().split(" ")])
            assert(len(facli_dists[-1])==n_clients)
    assert(line_n==6+n_facilities*2)
    fi.close()
    #
    fo = open(output_fname,"w")
    # Objective function:
    fo.write("max:")
    for j in range(n_facilities):
        fo.write(" -%d X%d"%(facility_cost,j))
    for i in range(n_clients):
        for j in range(n_facilities):
            fo.write(" %+d Y%dc%d"%(
                cli_weights[i]*(variant_gain-transport_cost*facli_dists[j][i]),
                i,j))
    fo.write(";\n")
    fo.write("\n")
    # Plant location restriction:
    for i in range(n_clients):
        for j in range(n_facilities):
            fo.write("Y%dc%d <= X%d;\n"%(i,j,j))
    # Client reach restiction
    fo.write("\n")
    for i in range(n_clients):
        for j in range(n_facilities):
            fo.write("+Y%dc%d "%(i,j))
        fo.write("<= 1;\n")
    fo.write("\n")
    # Binary var restrictions:
    fo.write("bin "+",".join(["X%d"%x for x in range(n_facilities)])+";\n")
    for i in range(n_clients):
        fo.write("bin "+",".join(["Y%dc%d"%(i,x) for x in range(n_facilities)])+";\n")
    fo.close()

# MAIN
if __name__ == '__main__':
    right = False
    if len(argv)==3:
        right = True
    if not right:
        print("Usage:")
        print("%s <problem_fname> <output_fname>"%argv[0])
    else:
        create_fp_problem(argv[1],argv[2])
