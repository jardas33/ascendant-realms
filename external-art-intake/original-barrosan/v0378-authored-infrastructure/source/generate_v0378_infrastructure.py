import os, math, json, zipfile, shutil, textwrap, hashlib
from pathlib import Path
import numpy as np
import trimesh
from trimesh.visual.material import PBRMaterial
from PIL import Image
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

ROOT = Path(os.environ.get('V0378_PACK_ROOT', '/mnt/data/v0378_pack'))
if ROOT.exists(): shutil.rmtree(ROOT)
EXPORT = ROOT/'external-art-intake/original-barrosan/v0378-authored-infrastructure/exports'
SOURCE = ROOT/'external-art-intake/original-barrosan/v0378-authored-infrastructure/source'
DOCS = ROOT/'external-art-intake/original-barrosan/v0378-authored-infrastructure/docs'
PREV = ROOT/'external-art-intake/original-barrosan/v0378-authored-infrastructure/previews'
PROMPTS = ROOT/'prompts'
for p in [EXPORT,SOURCE,DOCS,PREV,PROMPTS]: p.mkdir(parents=True, exist_ok=True)

# ---------- Geometry helpers ----------
def river_center(y):
    return 0.28*y + 1.8*np.sin(y/7.5) + 0.55*np.sin(y/3.1)
def river_half_width(y):
    return 2.6 + 0.45*np.sin(y/6.0+0.5) + 0.25*np.sin(y/2.7)
def road_center(x):
    return 0.75*np.sin(x/10.0) - 0.18*np.sin(x/3.7)
def road_half_width(x):
    return 1.7 + 0.18*np.sin(x/5.2) + 0.12*np.sin(x/2.3)

def terrain_height(x, y):
    x=np.asarray(x); y=np.asarray(y)
    base = 0.35*np.sin(x/12.0) + 0.28*np.cos(y/9.0) + 0.12*np.sin((x+y)/4.7)
    base += 0.55*np.exp(-((x+18)**2+(y-8)**2)/180.0)
    base += 0.38*np.exp(-((x-16)**2+(y+10)**2)/130.0)
    d = x-river_center(y)
    w = river_half_width(y)
    valley = -0.78*np.exp(-(d/(w*1.45))**2)
    bank = -0.18*np.exp(-(d/(w*2.55))**4)
    # road is worn into terrain but not a visible overlay-only ribbon
    dr = y-road_center(x)
    wr = road_half_width(x)
    road_cut = -0.10*np.exp(-(dr/(wr*1.15))**6)
    micro = 0.08*np.sin(x*0.8)*np.sin(y*0.63) + 0.035*np.sin(x*1.9+y*1.3)
    return base + valley + bank + road_cut + micro

# Terrain mesh
nx, ny = 121, 91
xs=np.linspace(-36,36,nx); ys=np.linspace(-27,27,ny)
X,Y=np.meshgrid(xs,ys)
Z=terrain_height(X,Y)
verts=np.column_stack([X.ravel(),Y.ravel(),Z.ravel()])
faces=[]
for j in range(ny-1):
    for i in range(nx-1):
        a=j*nx+i; b=a+1; c=a+nx; d=c+1
        faces.append([a,c,b]); faces.append([b,c,d])
faces=np.asarray(faces)
# Terrain vertex colors
D=np.abs(X-river_center(Y)); W=river_half_width(Y)
moist=np.clip(1-D/(W*2.8),0,1)
road_prox=np.clip(1-np.abs(Y-road_center(X))/(road_half_width(X)*2.3),0,1)
noise=(np.sin(X*0.42)+np.cos(Y*0.37)+np.sin((X-Y)*0.21))/6+0.5
base=np.zeros((ny,nx,4),dtype=np.uint8)
# muted highland greens
r=112 + 18*noise - 20*moist - 8*road_prox
g=128 + 24*noise - 8*moist - 15*road_prox
b=77 + 12*noise + 5*moist - 14*road_prox
base[...,0]=np.clip(r,0,255); base[...,1]=np.clip(g,0,255); base[...,2]=np.clip(b,0,255); base[...,3]=255
terrain=trimesh.Trimesh(verts,faces,vertex_colors=base.reshape(-1,4),process=False)
terrain.metadata['name']='Terrain_Authored_Highland'

# Water mesh following river
yv=np.linspace(-30,30,180)
rows=[]
for y in yv:
    c=river_center(y); w=river_half_width(y)*0.80
    z=-0.58 + 0.002*y
    rows.append([(c-w,y,z),(c+w,y,z)])
wv=np.array([p for row in rows for p in row])
wf=[]
for i in range(len(yv)-1):
    a=2*i; wf += [[a,a+2,a+1],[a+1,a+2,a+3]]
water_mat=PBRMaterial(name='Water_BlueGreen',baseColorFactor=[0.16,0.42,0.43,0.95],metallicFactor=0.0,roughnessFactor=0.32,alphaMode='BLEND',doubleSided=True)
water=trimesh.Trimesh(wv,np.array(wf),process=False); water.visual.material=water_mat

# Road shoulder and core meshes, split around river corridor
# The authored crossing is elevated; keep road surfaces above the sampled
# terrain and blend the final approach into the bridge deck instead of leaving
# an abrupt, intersecting strip at each landing.
BRIDGE_Z=0.48

def make_road_segment(x0,x1,kind='core'):
    xv=np.linspace(x0,x1,120)
    pts=[]
    for x in xv:
        yc=road_center(x)
        hw=road_half_width(x)*(1.0 if kind=='core' else 1.28)
        # irregular edges
        irr=0.06*np.sin(x*1.17)+0.03*np.sin(x*2.41)
        for s in (-1,1):
            y=yc+s*(hw+irr*s*0.25)
            z=float(terrain_height(x,y)) + (0.045 if kind=='core' else 0.032)
            landing_blend=np.clip((abs(x)-5.7)/0.8,0.0,1.0)
            z=(1.0-landing_blend)*z + landing_blend*BRIDGE_Z
            pts.append((x,y,z))
    fs=[]
    for i in range(len(xv)-1):
        a=2*i; fs += [[a,a+2,a+1],[a+1,a+2,a+3]]
    m=trimesh.Trimesh(np.array(pts),np.array(fs),process=False)
    if kind=='core':
        m.visual.material=PBRMaterial(name='Road_Compacted_Earth',baseColorFactor=[0.38,0.23,0.12,1],roughnessFactor=0.95)
    else:
        m.visual.material=PBRMaterial(name='Road_Worn_Shoulder',baseColorFactor=[0.47,0.34,0.18,1],roughnessFactor=1.0)
    return m
road_meshes=[]
for seg in [(-36,-6.5),(6.5,36)]:
    road_meshes.append(make_road_segment(*seg,'shoulder'))
    road_meshes.append(make_road_segment(*seg,'core'))

# Bridge components
stone_mat=PBRMaterial(name='Granite_Block',baseColorFactor=[0.35,0.36,0.34,1],roughnessFactor=0.9)
wood_mat=PBRMaterial(name='Weathered_Timber',baseColorFactor=[0.34,0.17,0.08,1],roughnessFactor=0.9)
wood_light=PBRMaterial(name='Worn_Deck_Timber',baseColorFactor=[0.49,0.28,0.12,1],roughnessFactor=0.86)
scene=trimesh.Scene()
scene.add_geometry(terrain,node_name='Terrain')
scene.add_geometry(water,node_name='Water')
for idx,m in enumerate(road_meshes): scene.add_geometry(m,node_name=f'Road_{idx}')

# Bridge elevation and dimensions
bridge_z=BRIDGE_Z
# abutments
for x in (-6.2,6.2):
    box=trimesh.creation.box(extents=[1.8,4.0,0.84])
    box.apply_translation([x,0,bridge_z-0.42]); box.visual.material=stone_mat
    scene.add_geometry(box,node_name=f'Abutment_{x}')
# under beams
for y in (-1.25,0,1.25):
    beam=trimesh.creation.box(extents=[12.2,0.28,0.32]); beam.apply_translation([0,y,bridge_z-0.22]); beam.visual.material=wood_mat
    scene.add_geometry(beam,node_name=f'UnderBeam_{y}')
# planks across length x
plank_positions=np.linspace(-5.7,5.7,18)
for i,x in enumerate(plank_positions):
    p=trimesh.creation.box(extents=[0.58,3.6,0.20]); p.apply_translation([x,0,bridge_z]); p.visual.material=wood_light
    scene.add_geometry(p,node_name=f'DeckPlank_{i:02d}')
# rail posts and rails
for side in (-1.62,1.62):
    for i,x in enumerate(np.linspace(-5.6,5.6,7)):
        post=trimesh.creation.cylinder(radius=0.10,height=1.55,sections=8)
        post.apply_translation([x,side,bridge_z+0.72]); post.visual.material=wood_mat
        scene.add_geometry(post,node_name=f'RailPost_{side}_{i}')
    for zoff in (0.65,1.25):
        rail=trimesh.creation.box(extents=[11.5,0.16,0.16]); rail.apply_translation([0,side,bridge_z+zoff]); rail.visual.material=wood_mat
        scene.add_geometry(rail,node_name=f'Rail_{side}_{zoff}')
# central stone pier hints under bridge
for x in (-2.0,2.0):
    pier=trimesh.creation.box(extents=[0.9,2.4,1.0]); pier.apply_translation([x,0,bridge_z-0.65]); pier.visual.material=stone_mat
    scene.add_geometry(pier,node_name=f'Pier_{x}')

# Rocks
rock_mats=[PBRMaterial(name='Rock_Grey',baseColorFactor=[0.33,0.34,0.31,1],roughnessFactor=1.0),
           PBRMaterial(name='Rock_Light',baseColorFactor=[0.46,0.45,0.39,1],roughnessFactor=1.0)]
rng=np.random.default_rng(42)
for i in range(38):
    y=float(rng.uniform(-25,25)); c=float(river_center(y)); w=float(river_half_width(y))
    if rng.random()<0.6:
        x=c+rng.choice([-1,1])*rng.uniform(w*1.2,w*2.8)
    else: x=float(rng.uniform(-33,33))
    if abs(y-road_center(x))<3.2 or abs(x)<7 and abs(y)<4: continue
    z=float(terrain_height(x,y))
    rock=trimesh.creation.icosphere(subdivisions=1,radius=1.0)
    rock.apply_scale([rng.uniform(.35,1.2),rng.uniform(.35,.95),rng.uniform(.25,.8)])
    rock.apply_translation([x,y,z+rng.uniform(.15,.35)])
    rock.visual.material=rock_mats[i%2]
    scene.add_geometry(rock,node_name=f'Rock_{i:02d}')

# Reeds: simple low-poly stalk clusters near banks
reed_mat=PBRMaterial(name='Reeds_DarkGreen',baseColorFactor=[0.18,0.28,0.11,1],roughnessFactor=1.0)
for i,y in enumerate(np.linspace(-22,22,18)):
    c=float(river_center(y)); w=float(river_half_width(y))
    side=-1 if i%2==0 else 1
    x=c+side*w*1.05
    z=float(terrain_height(x,y))
    for k in range(4):
        stalk=trimesh.creation.cylinder(radius=0.035,height=0.8+0.18*k,sections=6)
        stalk.apply_translation([x+0.10*k*side,y+0.11*k,z+0.4+0.09*k]); stalk.visual.material=reed_mat
        scene.add_geometry(stalk,node_name=f'Reed_{i}_{k}')

# export
GLB = EXPORT/'barrosan_infrastructure_v0378.glb'
GLB.write_bytes(scene.export(file_type='glb'))

# ---------- Preview rendering ----------
from matplotlib.patches import Polygon, Rectangle, Circle
from matplotlib.collections import PatchCollection

def terrain_rgb():
    return base[...,:3]

def draw_plan(path, detail=False):
    fig,ax=plt.subplots(figsize=(16,9),dpi=120)
    ax.imshow(terrain_rgb(),extent=[xs.min(),xs.max(),ys.min(),ys.max()],origin='lower',interpolation='bilinear')
    # subtle elevation contours
    ax.contour(X,Y,Z,levels=np.linspace(Z.min(),Z.max(),10),colors=[(0.18,0.22,0.14,0.18)],linewidths=0.45)
    # river polygon
    yr=np.linspace(-30,30,240); c=river_center(yr); w=river_half_width(yr)*0.80
    river_poly=np.vstack([np.column_stack([c-w,yr]),np.column_stack([c[::-1]+w[::-1],yr[::-1]])])
    ax.add_patch(Polygon(river_poly,closed=True,facecolor='#2f7778',edgecolor='#234e50',linewidth=1.4,zorder=5))
    # bank wet strips
    for fac,col in [(1.15,'#4d5741'),(1.38,'#6f7051')]:
        ww=river_half_width(yr)*fac
        poly=np.vstack([np.column_stack([c-ww,yr]),np.column_stack([c[::-1]+ww[::-1],yr[::-1]])])
        ax.add_patch(Polygon(poly,closed=True,facecolor=col,edgecolor='none',alpha=0.85,zorder=3))
    # redraw river on top
    ax.add_patch(Polygon(river_poly,closed=True,facecolor='#2f7778',edgecolor='#234e50',linewidth=1.0,zorder=6))
    # roads
    for x0,x1 in [(-36,-6.5),(6.5,36)]:
        xr=np.linspace(x0,x1,160); yc=road_center(xr); hw=road_half_width(xr)
        sh=hw*1.28
        shoulder=np.vstack([np.column_stack([xr,yc-sh]),np.column_stack([xr[::-1],(yc+sh)[::-1]])])
        core=np.vstack([np.column_stack([xr,yc-hw]),np.column_stack([xr[::-1],(yc+hw)[::-1]])])
        ax.add_patch(Polygon(shoulder,closed=True,facecolor='#81603a',edgecolor='none',alpha=.75,zorder=7))
        ax.add_patch(Polygon(core,closed=True,facecolor='#5f3b1f',edgecolor='#4b2c18',linewidth=.6,zorder=8))
    # bridge abutments and planks
    ax.add_patch(Rectangle((-7.25,-2.2),2.1,4.4,facecolor='#686a64',edgecolor='#3e403d',zorder=10))
    ax.add_patch(Rectangle((5.15,-2.2),2.1,4.4,facecolor='#686a64',edgecolor='#3e403d',zorder=10))
    for x in plank_positions:
        ax.add_patch(Rectangle((x-.29,-1.8),.58,3.6,facecolor='#85502a',edgecolor='#4c2b16',linewidth=.6,zorder=11))
    # rails/posts plan read
    for side in (-1.62,1.62):
        ax.plot([-5.8,5.8],[side,side],color='#4f2b18',linewidth=2.0,zorder=12)
        for x in np.linspace(-5.6,5.6,7): ax.add_patch(Circle((x,side),.11,facecolor='#4f2b18',edgecolor='none',zorder=13))
    # rocks and reeds approximated from deterministic RNG
    rng2=np.random.default_rng(42)
    for i in range(38):
        y=float(rng2.uniform(-25,25)); cc=float(river_center(y)); ww=float(river_half_width(y))
        if rng2.random()<0.6: x=cc+rng2.choice([-1,1])*rng2.uniform(ww*1.2,ww*2.8)
        else: x=float(rng2.uniform(-33,33))
        if abs(y-road_center(x))<3.2 or abs(x)<7 and abs(y)<4: continue
        r=float(rng2.uniform(.25,.75))
        ax.add_patch(Circle((x,y),r,facecolor='#77766c',edgecolor='#4c4d48',linewidth=.4,zorder=9))
    for i,y in enumerate(np.linspace(-22,22,18)):
        cc=float(river_center(y)); ww=float(river_half_width(y)); side=-1 if i%2==0 else 1; x=cc+side*ww*1.05
        ax.plot([x-.15,x,x+.12],[y-.2,y+.35,y-.1],color='#344d27',linewidth=1.0,zorder=14)
    ax.set_aspect('equal'); ax.axis('off'); fig.patch.set_facecolor('#c8cec7'); ax.set_facecolor('#c8cec7')
    if detail: ax.set_xlim(-15,15); ax.set_ylim(-10,10)
    else: ax.set_xlim(-34,34); ax.set_ylim(-23,23)
    plt.tight_layout(pad=0)
    fig.savefig(path,bbox_inches='tight',pad_inches=0)
    plt.close(fig)

draw_plan(PREV/'overview.png',False)
draw_plan(PREV/'bridge_detail.png',True)

# Source script copy
shutil.copy2(os.environ.get('V0378_SOURCE_FILE', '/mnt/data/generate_v0378_pack.py'), SOURCE/'generate_v0378_infrastructure.py')

# Docs
readme=f'''# v0.378 Authored Barrosan Infrastructure Kit

This delivery contains an original, locally generated Stage 1 infrastructure kit. It is intended to replace Codex's failed procedural v0.377 geometry, not merely serve as another reference.

## Included

- `exports/barrosan_infrastructure_v0378.glb`
- `source/generate_v0378_infrastructure.py`
- `previews/overview.png`
- `previews/bridge_detail.png`

## Design intent

- one continuous authored highland terrain mesh;
- a recessed curved river with terrain-carved banks;
- irregular road geometry split around the crossing;
- a timber bridge with granite abutments, under-beams, piers, deck and rails;
- authored rock and reed dressing;
- muted Barrosan palette;
- no buildings, units, gameplay, HUD or production integration.

## Important

Codex must import this exact GLB and evaluate it. It must not regenerate the terrain, road, river or bridge from scratch during v0.378. It may make bounded camera, lighting, material and placement adjustments in Godot, but source geometry changes must be made by editing the included Python source and regenerating the GLB.
'''
(DOCS/'README.md').write_text(readme,encoding='utf-8')

# hashes
hashes={}
for p in [GLB,SOURCE/'generate_v0378_infrastructure.py',PREV/'overview.png',PREV/'bridge_detail.png']:
    hashes[str(p.relative_to(ROOT))]=hashlib.sha256(p.read_bytes()).hexdigest()
(DOCS/'SHA256.json').write_text(json.dumps(hashes,indent=2),encoding='utf-8')

prompt=r'''/goal v0.378 — IMPORT THE PROVIDED AUTHORED INFRASTRUCTURE KIT AND RUN A STRICT VISUAL GATE

BASE

Branch:
codex/v0215-v0226-recovery

Expected HEAD:
9d9ef05a72068565683ac35296226a416a524904

Before work:
- verify branch and exact HEAD;
- verify tracked tree state;
- preserve existing/generated untracked files;
- preserve v0.377 and all earlier routes;
- stop honestly if the expected base differs.

HUMAN DECISION

v0.377 is rejected visually. Its checkerboard terrain, torn road spikes, overly broad diagrammatic shoulders and smooth sparse banks must not be reused.

A new authored Stage 1 kit has been supplied locally at:

external-art-intake/original-barrosan/v0378-authored-infrastructure/

Read first:

external-art-intake/original-barrosan/v0378-authored-infrastructure/docs/README.md
external-art-intake/original-barrosan/v0378-authored-infrastructure/docs/SHA256.json

Inspect these preview images:

external-art-intake/original-barrosan/v0378-authored-infrastructure/previews/overview.png
external-art-intake/original-barrosan/v0378-authored-infrastructure/previews/bridge_detail.png

PRIMARY OBJECTIVE

Import and evaluate the supplied exact GLB:

external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378.glb

Do not regenerate the terrain, road, river or bridge from scratch.
Do not reinterpret the concept sheet procedurally.
Do not reuse the v0.377 checkerboard or torn-road geometry.
Do not add buildings, units, gameplay, HUD, mine or hostile camp.

Create an isolated opt-in v0.378 Godot scene that presents the supplied authored kit with:
- a stable orthographic-oblique RTS camera;
- soft directional daylight;
- restrained ambient fill;
- clean contact shadows;
- terrain edges outside the approved primary frame;
- no debug overlays.

ALLOWED ADJUSTMENTS

You may:
- normalize metric scale and orientation;
- fix import materials if they do not resolve correctly;
- adjust camera, world environment, shadows and fog;
- make bounded non-destructive Godot material overrides;
- reposition the entire kit as one unit;
- add a small number of existing non-primitive scale-reference markers only in DEBUG captures, not PLAYER captures.

You may not:
- replace supplied geometry with new procedural geometry;
- create broad ribbon roads or riverbanks;
- create checkerboard terrain variation;
- add torn triangular path fragments;
- change the default runtime;
- connect gameplay.

VISUAL REVIEW LOOP

Perform up to four iterations. For each:
1. render a 1920x1080 primary RTS view;
2. render a road/terrain detail;
3. render a riverbank detail;
4. render a bridge/landing detail;
5. open and inspect the actual renders;
6. record the three largest visible defects;
7. correct only defects possible through the supplied source or bounded presentation changes.

If source geometry genuinely requires repair, edit only:

external-art-intake/original-barrosan/v0378-authored-infrastructure/source/generate_v0378_infrastructure.py

Regenerate the GLB reproducibly and record the changed hash. Do not invent a parallel implementation.

PASS GATE

Pass only if:
- no checkerboard pattern is visible;
- no torn triangular road geometry is visible;
- terrain reads as continuous authored land;
- river is visibly recessed;
- banks read as shaped terrain rather than parallel painted ribbons;
- road reads as worn earth and joins the bridge logically;
- bridge deck, abutments, rails and supports read cleanly;
- no floating/intersecting critical geometry;
- primary frame hides map boundaries;
- overall visual score is at least 70/100;
- terrain credibility, road integration, riverbank credibility and bridge credibility are each at least 65/100.

FAIL CLOSED

If the supplied kit cannot meet the gate after four serious iterations:
- do not create a success review pack;
- preserve the best rejected renders;
- create an honest blocker report stating the exact remaining geometry or presentation defects;
- do not begin v0.379.

Use exactly:
BLOCKED — V0378 PROVIDED INFRASTRUCTURE KIT VISUAL GATE NOT MET

SUCCESS PACK

Only if passed, create exactly:
- 00_READ_ME_FIRST.md
- 01_PRIMARY_RTS_VIEW.png
- 02_ROAD_AND_TERRAIN_DETAIL.png
- 03_RIVERBANK_DETAIL.png
- 04_BRIDGE_AND_LANDINGS.png
- 05_GRAYSCALE_PRIMARY.png
- 06_SOURCE_HASH_AND_IMPORT_REPORT.md
- 07_SCORECARD.md
- 08_VALIDATION.json

VALIDATION

After visual pass only:
- focused v0.378 validator;
- source/hash verification;
- Godot missing-resource and smoke checks;
- npm test;
- npm run build;
- npm run validate:content;
- npm run validate:art-intake;
- npm run validate:runtime-art-slots;
- npm run godot:all;
- git diff --check;
- exact-SHA CI.

DELIVERY

If passed, use exactly:
READY FOR HUMAN V0378 PROVIDED INFRASTRUCTURE KIT REVIEW

If blocked, use exactly:
BLOCKED — V0378 PROVIDED INFRASTRUCTURE KIT VISUAL GATE NOT MET

HARD STOP

Do not add buildings.
Do not add units.
Do not connect gameplay.
Do not modify default runtime.
Do not begin v0.379.
'''
(PROMPTS/'V0378_IMPORT_PROVIDED_INFRASTRUCTURE_KIT.txt').write_text(prompt,encoding='utf-8')

# root instructions
(ROOT/'DO_THIS_NEXT.txt').write_text('''1. Extract this ZIP directly into the Ascendant Realms repository root.\n2. Confirm this file exists:\n   external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378.glb\n3. Open prompts/V0378_IMPORT_PROVIDED_INFRASTRUCTURE_KIT.txt\n4. Copy the entire prompt into Codex.\n5. Return Codex\'s final message and final renders to ChatGPT.\n''',encoding='utf-8')

# zip
zip_path=Path('/mnt/data/Ascendant_Realms_v0378_Authored_Infrastructure_Kit.zip')
if zip_path.exists(): zip_path.unlink()
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as z:
    for p in ROOT.rglob('*'):
        if p.is_file(): z.write(p,p.relative_to(ROOT))
print(zip_path)
print('GLB bytes',GLB.stat().st_size)
