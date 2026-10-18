# Plan 363: bakes stone copies of the two ridge rock textures for cliffs.
# The originals carry flat bright moss blobs over a third of the surface;
# on a ridge of fifty copies they read as the same dark cap on every rock.
# Moss becomes stone with the rock's own grain, keeping a faint lichen tint.
# Run from production/ascendant-realms-godot/assets/environment/rocks.
from PIL import Image, ImageFilter
for n in ['highland_rock_cluster', 'mossy_boulder']:
    im = Image.open(n + '_tripo_model_basecolor.jpg').convert('RGB')
    W, H = im.size
    px = list(im.get_flattened_data())
    L = [0.3*r + 0.59*g + 0.11*b for r, g, b in px]
    m = [max(0.0, min(1.0, ((g - (r + b) / 2) - 8) / 20)) for r, g, b in px]
    mimg = Image.new('L', (W, H)); mimg.putdata([int(v * 255) for v in m])
    m = [v / 255 for v in mimg.filter(ImageFilter.GaussianBlur(1.5)).get_flattened_data()]
    rock = [(p, l) for p, l, v in zip(px, L, m) if v < 0.1]
    rm = sum(l for _, l in rock) / len(rock)
    mr = [sum(p[i] for p, _ in rock) / len(rock) for i in range(3)]
    moss = [l for l, v in zip(L, m) if v > 0.9]
    mm = sum(moss) / len(moss) if moss else rm
    limg = Image.new('L', (W, H)); limg.putdata([int(l) for l in L])
    bl = list(limg.filter(ImageFilter.GaussianBlur(6)).get_flattened_data())
    # The moss was painted flat: lend it the grain of bare rock elsewhere
    # on the sheet (rock detail taken from an offset, where it is not moss).
    hp = [l - b for l, b in zip(L, bl)]
    lend = []
    for y in range(H):
        for x in range(W):
            j = ((y + 211) % H) * W + (x + 317) % W
            lend.append(hp[j] * (1.0 - m[j]))
    out = []
    for p, l, v, b, d in zip(px, L, m, bl, lend):
        x = l + v * (rm - mm) + v * (l - b) * 0.3 + v * d * 1.1
        if v < 0.01:
            c = p
        else:
            k = x / rm
            stone = [mr[i] * k for i in range(3)]
            # A faint lichen: a quarter of the moss, mostly greyed.
            g = (p[0] + p[1] + p[2]) / 3
            lich = [stone[i] * 0.8 + (p[i] * 0.4 + g * 0.6) * k * 0.2 for i in range(3)]
            c = [stone[i] * (1 - v) + (stone[i] * 0.78 + lich[i] * 0.22) * v for i in range(3)]
        out.append(tuple(max(0, min(255, int(c[i]))) for i in range(3)))
    o = Image.new('RGB', (W, H)); o.putdata(out); o.save('crag_' + n + '.png')
    print(n, round(rm, 1), round(mm, 1), [round(x) for x in mr])
