"""Turn a character concept image into a 3D model with the free Hunyuan3D-2.1
demo on Hugging Face. Usage (from PowerShell):

    D:\\ClaudeWork\\pyenv\\Scripts\\python.exe D:\\ClaudeWork\\charpipe\\make_3d.py D:\\ClaudeWork\\charpipe\\worker_apose_7.png

The free GPU window is short, so this first asks for the textured model and,
if the free limit refuses it, falls back to the untextured shape, which is
shorter. Claude then paints the texture in Blender from the concept image.
If a free Hugging Face account token is set in HF_TOKEN, it is used for a
larger free quota. Writes <image>_textured.glb or <image>_shape.glb.
"""
import os
import shutil
import sys

os.environ["TEMP"] = r"D:\ClaudeWork\tmp"
os.environ["TMP"] = r"D:\ClaudeWork\tmp"
os.environ["HF_HOME"] = r"D:\ClaudeWork\hf"

from gradio_client import Client, handle_file  # noqa: E402


def path_of(item):
    # Newer spaces return file dicts ({"value"|"path": ...}) instead of paths.
    while isinstance(item, dict):
        item = item.get("value") or item.get("path") or item.get("name")
    return item

image = sys.argv[1]
stem = os.path.splitext(image)[0]
token = os.environ.get("HF_TOKEN") or None
if token and not token.startswith("hf_"):
    print("HF_TOKEN does not look like a real token (it should start with hf_). Running without it.")
    token = None
client = Client("tencent/Hunyuan3D-2.1", verbose=False, token=token)
common = dict(image=handle_file(image), mv_image_front=None, mv_image_back=None, mv_image_left=None,
              mv_image_right=None, guidance_scale=5.0, seed=1234, check_box_rembg=True,
              num_chunks=8000, randomize_seed=False)

try:
    print("Trying the textured model (needs the longer GPU window)...")
    r = client.predict(steps=30, octree_resolution=256, api_name="/generation_all", **common)
    shutil.copy(path_of(r[1]), stem + "_textured.glb")
    shutil.copy(path_of(r[0]), stem + "_shape.glb")
    print("Done:", stem + "_textured.glb")
    sys.exit(0)
except Exception as exc:
    print("Textured model failed:", str(exc)[:200])

for steps, octree in ((25, 256), (15, 192)):
    try:
        print("Trying the untextured shape (steps %d, detail %d)..." % (steps, octree))
        r = client.predict(steps=steps, octree_resolution=octree, api_name="/shape_generation", **common)
        shutil.copy(path_of(r[0]), stem + "_shape.glb")
        print("Done:", stem + "_shape.glb")
        sys.exit(0)
    except Exception as exc:
        print("Refused:", str(exc)[:160])

print("All attempts failed; see the messages above.")
sys.exit(1)
