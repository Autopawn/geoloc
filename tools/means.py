import sys

if __name__ == '__main__':
    if len(sys.argv)!=2:
        print("Usage: python %s <file>"%sys.argv[0])
    else:
        fil = open(sys.argv[1])
        sums = {}
        amount = {}
        for lin in fil:
            lin = lin.strip()
            if len(lin)==0: continue
            lin = lin.split(' ')
            key = ' '.join(lin[:-2])
            val = float(lin[-2])
            if key not in sums:
                sums[key] = 0
                amount[key] = 0
            sums[key] += val
            amount[key] += 1
        fil.close()
        #
        for key in sums:
            sums[key] /= float(amount[key])
        #
        for key in sums:
            print("%s %0.8f"%(key,sums[key]))
