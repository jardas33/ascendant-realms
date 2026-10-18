# Plan 352: bakes moss-free basalt copies of the rock textures.
import sys
from PIL import Image, ImageFilter
for n in ['highland_rock_cluster','mossy_boulder']:
    im = Image.open(n+'.png').convert('RGB')
    W,H = im.size
    px = list(im.getdata())
    L = [0.3*r+0.59*g+0.11*b for r,g,b in px]
    m = [max(0.0,min(1.0,((g-(r+b)/2)-8)/20)) for r,g,b in px]
    mimg = Image.new('L',(W,H)); mimg.putdata([int(v*255) for v in m]); mimg = mimg.filter(ImageFilter.GaussianBlur(1.2))
    m = [v/255 for v in mimg.getdata()]
    rock = [l for l,v in zip(L,m) if v<0.1]; moss = [l for l,v in zip(L,m) if v>0.9]
    rm = sum(rock)/len(rock); mm = sum(moss)/len(moss) if moss else rm
    limg = Image.new('L',(W,H)); limg.putdata([int(l) for l in L])
    bl = list(limg.filter(ImageFilter.GaussianBlur(6)).getdata())
    out = []
    for l,v,b in zip(L,m,bl):
        x = l + v*(rm-mm) + v*(l-b)*0.6
        y = (x-rm)*1.35 + 107
        out.append((max(0,min(255,int(y*1.02))), max(0,min(255,int(y*0.98))), max(0,min(255,int(y*0.96)))))
    o = Image.new('RGB',(W,H)); o.putdata(out); o.save('basalt_'+n+'.png')
    print(n, round(rm,1), round(mm,1))
Image.open('basalt_highland_rock_cluster.png').resize((512,512)).save('basalt_s.png')
