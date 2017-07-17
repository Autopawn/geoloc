size(4cm);

int SIZ = 10;

path unibox = box((-1,-1),(1,1));

path larrow(pair ini, pair end, bool pre=false){
    real signx = ini.x==end.x ? 0 : ini.x<end.x? 1 : -1;
    real signy = ini.y==end.y ? 0 : ini.y<end.y? 1 : -1;
    return (ini.x*SIZ+(pre?signx:0),ini.y*SIZ+(pre?signy:0))
        --(end.x*SIZ-signx,end.y*SIZ-signy);
}

draw(larrow((0,0),(1,1)),arrow=Arrow(TeXHead),red);
filldraw(shift(0SIZ,0SIZ)*unitcircle,red);
draw(larrow((3,0),(1,1)),arrow=Arrow(TeXHead),red);
filldraw(shift(3SIZ,0SIZ)*unitcircle,red);
draw(larrow((0,1),(1,1)),arrow=Arrow(TeXHead),red);
filldraw(shift(0SIZ,1SIZ)*unitcircle,red);
draw(larrow((2,1),(1,1)),arrow=Arrow(TeXHead),red);
filldraw(shift(2SIZ,1SIZ)*unitcircle,red);
draw(larrow((0,3),(1,1)),arrow=Arrow(TeXHead),red);
filldraw(shift(0SIZ,3SIZ)*unitcircle,red);
draw(larrow((1,4),(3,3)),arrow=Arrow(TeXHead),red);
filldraw(shift(1SIZ,4SIZ)*unitcircle,red);
draw(larrow((4,4),(3,3)),arrow=Arrow(TeXHead),red);
filldraw(shift(4SIZ,4SIZ)*unitcircle,red);

filldraw(shift(0SIZ,5SIZ)*unitcircle,red);
draw(larrow((3,5),(3,3)),arrow=Arrow(TeXHead),red);
filldraw(shift(3SIZ,5SIZ)*unitcircle,red);

filldraw(shift(3SIZ,3SIZ)*unibox,blue);
filldraw(shift(1SIZ,1SIZ)*unibox,blue);
draw(shift(2SIZ,5SIZ)*unibox);
draw(shift(4SIZ,1SIZ)*unibox);
