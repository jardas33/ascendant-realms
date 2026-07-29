#!/usr/bin/env python3
"""Downscale textures embedded inside GLB files so the web export stays small.
Godot's importer does not cap textures embedded in .glb scenes, so Tripo's
large textures ship raw into the pck. This rewrites each GLB's embedded images
to a max dimension, re-packing the binary buffer and fixing all bufferView
offsets. Safe to re-run: images already at/under the cap are left untouched.
"""
import io, sys, struct, glob, os
from PIL import Image
import pygltflib

def process(path, cap):
    try:
        gltf = pygltflib.GLTF2().load(path)
    except Exception as e:
        print(f"  SKIP {path}: load failed {e}")
        return False
    if not gltf.images:
        return False
    blob = gltf.binary_blob()
    if blob is None:
        return False
    # map bufferView index -> (image_index) for image-backed views
    img_view = {}
    for i, img in enumerate(gltf.images):
        if img.bufferView is not None:
            img_view[img.bufferView] = i

    changed = False
    # Pre-extract new bytes for image bufferViews
    new_bytes = {}   # bufferView index -> replacement bytes
    for bv_idx, img_i in img_view.items():
        bv = gltf.bufferViews[bv_idx]
        start = bv.byteOffset or 0
        data = bytes(blob[start:start + bv.byteLength])
        try:
            im = Image.open(io.BytesIO(data))
            im.load()
        except Exception:
            continue
        w, h = im.size
        m = max(w, h)
        if m <= cap:
            continue
        scale = cap / float(m)
        nw, nh = max(1, int(w * scale)), max(1, int(h * scale))
        im2 = im.resize((nw, nh), Image.LANCZOS)
        out = io.BytesIO()
        has_alpha = im2.mode in ("RGBA", "LA") or (im2.mode == "P" and "transparency" in im2.info)
        if has_alpha:
            im2 = im2.convert("RGBA")
            im2.save(out, format="PNG", optimize=True)
            mime = "image/png"
        else:
            im2 = im2.convert("RGB")
            im2.save(out, format="JPEG", quality=85, optimize=True)
            mime = "image/jpeg"
        new_bytes[bv_idx] = out.getvalue()
        if gltf.images[img_i].mimeType:
            gltf.images[img_i].mimeType = mime
        changed = True

    if not changed:
        return False

    # Rebuild the single binary buffer, re-packing every bufferView in index order.
    new_blob = bytearray()
    for idx, bv in enumerate(gltf.bufferViews):
        if idx in new_bytes:
            data = new_bytes[idx]
        else:
            start = bv.byteOffset or 0
            data = bytes(blob[start:start + bv.byteLength])
        # 4-byte align
        while len(new_blob) % 4 != 0:
            new_blob.append(0)
        bv.byteOffset = len(new_blob)
        bv.byteLength = len(data)
        bv.byteStride = bv.byteStride  # unchanged
        new_blob.extend(data)
    while len(new_blob) % 4 != 0:
        new_blob.append(0)

    gltf.buffers[0].byteLength = len(new_blob)
    gltf.buffers[0].uri = None
    gltf.set_binary_blob(bytes(new_blob))
    gltf.save(path)
    return True

def main():
    targets = []
    for pat, cap in [("assets/characters/*/*.glb", 512),
                     ("assets/environment/vegetation/*.glb", 1024),
                     ("assets/environment/rocks/*.glb", 1024),
                     ("assets/environment/structures/*.glb", 1024),
                     ("assets/environment/buildings/*.glb", 1024)]:
        for p in glob.glob(pat):
            targets.append((p, cap))
    n = 0
    for p, cap in sorted(targets):
        before = os.path.getsize(p)
        if process(p, cap):
            after = os.path.getsize(p)
            print(f"  shrunk {p}: {before//1024}KB -> {after//1024}KB")
            n += 1
    print(f"Done. Rewrote {n} GLB(s).")

if __name__ == "__main__":
    main()
