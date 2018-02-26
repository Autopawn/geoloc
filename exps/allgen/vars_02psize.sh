nntests="050 100 150 200"
pptests="0.15"
cctests="0.50"

ntiers=10
ncases=10

poolsizes="001 010 020 030 040 050 060 070 080 090 100 110 120 130 140 150 160 170 180 190 200"

parameters='($P='"$pptests"', C='"$cctests"'$)'
colors='-colors={"gl":(1,0,0),"lp":(0,0,0)}'

memlimit=$((2*1024*1024))
