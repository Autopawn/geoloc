import matplotlib.pyplot as plt

# geoloc100vr200 para biogas

geoloc100vr200 = [
    441,37328,39716,37717,35149,31722,27048,21754,17002,12480,8621,5272,2804,1567,983,603,188,0]
geoloc200vr400 = [
    441,64701,79487,75343,70217,64374,55812,45491,33338,22776,15612,9324,5627,3388,2397,1991,
    1768,1085,453,0]
geoloc300vr600 =[
    441,82091,119124,113029,105608,95433,82482,67367,51292,36776,24423,14592,8944,5211,3047,2017,
    1233,670,0]
geoloc400vr800 =[
    441,89847,158432,151066,141052,128319,111761,92593,72495,51865,34964,21868,13026,7925,5060,
    3275,1688,397,0]

plt.title("$|B_i|$ para problema de biogás (N=572)",fontsize=18)
plt.ylim(ymin=0,ymax=max(geoloc400vr800))
plt.xlabel("$i$")
plt.ylabel("$|B_i|$")
plt.plot([str(x) for x in
    range(1,len(geoloc400vr800)+1)],geoloc400vr800,'o-',label='geoloc400vr800')
plt.plot([str(x) for x in
    range(1,len(geoloc300vr600)+1)],geoloc300vr600,'o-',label='geoloc300vr600')
plt.plot([str(x) for x in
    range(1,len(geoloc200vr400)+1)],geoloc200vr400,'o-',label='geoloc200vr400')
plt.plot([str(x) for x in
    range(1,len(geoloc100vr200)+1)],geoloc100vr200,'o-',label='geoloc100vr200')
plt.legend()
plt.show()
