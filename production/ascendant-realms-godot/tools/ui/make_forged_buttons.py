"""Generate the forged-bronze 9-patch button skins used by assets/ui/theme.tres.

Run with any Python that has Pillow:
    python tools/ui/make_forged_buttons.py
Writes assets/ui/buttons/forged_{normal,hover,pressed,disabled}.png (96x48,
9-patch margins 14 px). Drawn at 4x and downsampled for clean edges.
"""
import os
import random
from PIL import Image, ImageDraw, ImageFilter

S = 4
W, H = 96, 48
CUT = 7
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "ui", "buttons")


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def chamfer(x0, y0, x1, y1, c):
    return [(x0 + c, y0), (x1 - c, y0), (x1, y0 + c), (x1, y1 - c), (x1 - c, y1), (x0 + c, y1), (x0, y1 - c), (x0, y0 + c)]


def make(name, face_top, face_bottom, rim_top, rim_bottom, glow=None):
    w, h = W * S, H * S
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    # Outer dark keyline.
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).polygon(chamfer(0, 0, w - 1, h - 1, CUT * S), fill=255)
    keyline = Image.new("RGBA", (w, h), (8, 6, 4, 245))
    img.paste(keyline, (0, 0), mask)
    # Bronze rim: vertical gradient.
    rim = Image.new("RGBA", (w, h))
    rd = ImageDraw.Draw(rim)
    for y in range(h):
        rd.line([(0, y), (w, y)], fill=lerp(rim_top, rim_bottom, y / (h - 1)) + (255,))
    rmask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(rmask).polygon(chamfer(S, S, w - 1 - S, h - 1 - S, (CUT - 1) * S), fill=255)
    img.paste(rim, (0, 0), rmask)
    # Inner dark line, then the face.
    inner = 3 * S
    imask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(imask).polygon(chamfer(inner, inner, w - 1 - inner, h - 1 - inner, (CUT - 2) * S), fill=255)
    img.paste(Image.new("RGBA", (w, h), (10, 8, 6, 255)), (0, 0), imask)
    face_in = inner + S
    face = Image.new("RGBA", (w, h))
    fd = ImageDraw.Draw(face)
    rnd = random.Random(7)
    for y in range(h):
        base = lerp(face_top, face_bottom, y / (h - 1))
        fd.line([(0, y), (w, y)], fill=base + (255,))
    # Fine grain so the face reads as worn leather/iron, not flat colour.
    grain = Image.new("L", (w, h), 128)
    gp = grain.load()
    for y in range(h):
        for x in range(w):
            gp[x, y] = 128 + rnd.randint(-10, 10)
    grain = grain.filter(ImageFilter.GaussianBlur(1.2 * S / 2))
    fp = face.load()
    gp = grain.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = fp[x, y]
            d = (gp[x, y] - 128) * 0.6
            fp[x, y] = (max(0, min(255, int(r + d))), max(0, min(255, int(g + d))), max(0, min(255, int(b + d))), a)
    fmask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(fmask).polygon(chamfer(face_in, face_in, w - 1 - face_in, h - 1 - face_in, (CUT - 3) * S), fill=255)
    img.paste(face, (0, 0), fmask)
    d = ImageDraw.Draw(img)
    # Top bevel highlight and bottom shade inside the face.
    d.line([(face_in + (CUT - 3) * S, face_in + S), (w - 1 - face_in - (CUT - 3) * S, face_in + S)], fill=(255, 226, 160, 70), width=S)
    d.line([(face_in + (CUT - 3) * S, h - 1 - face_in - S), (w - 1 - face_in - (CUT - 3) * S, h - 1 - face_in - S)], fill=(0, 0, 0, 90), width=S)
    if glow:
        g = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        ImageDraw.Draw(g).rectangle([face_in + 6 * S, face_in + 4 * S, w - face_in - 6 * S, h - face_in - 4 * S], fill=glow)
        g = g.filter(ImageFilter.GaussianBlur(6 * S))
        gm = Image.new("L", (w, h), 0)
        gm.paste(fmask)
        glow_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        glow_layer.paste(g, (0, 0), gm)
        img = Image.alpha_composite(img, glow_layer)
    img = img.resize((W, H), Image.LANCZOS)
    os.makedirs(OUT, exist_ok=True)
    img.save(os.path.join(OUT, "forged_%s.png" % name))


make("normal", (34, 28, 22), (16, 13, 10), (214, 176, 108), (104, 74, 38))
make("hover", (58, 44, 26), (26, 20, 13), (246, 212, 140), (150, 108, 52), glow=(255, 190, 90, 70))
make("pressed", (14, 11, 8), (26, 21, 15), (140, 104, 56), (200, 160, 96))
make("disabled", (28, 28, 28), (18, 18, 18), (104, 98, 88), (60, 56, 50))
print("ok")
