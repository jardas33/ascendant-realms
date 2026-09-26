# Free character pipeline

1. Concept: a full-body painting with the arms held out from the body on a plain white background. The Barrosan worker concept came from the free `black-forest-labs/FLUX.1-schnell` space: `barrosan_worker_concept.png`.
2. 3D: `make_3d.py <concept.png>` calls the free `tencent/Hunyuan3D-2.1` space. Set `HF_TOKEN` to a free Hugging Face token for a larger GPU window. The script writes `<concept>_textured.glb`.
3. Rig fit (Blender 4.5, headless):
   `blender -b --factory-startup --python fit_character.py -- <textured.glb> <concept.png> <out.glb> 14000 [preview.png]`
   The script merges UV-seam duplicates, removes the ground sheets and base plate the generator adds, normalises to 1.8 m facing -Y, and decimates to about 14k faces. It then estimates the joints and builds the 22-bone Barrosan rig (same bone names), heat-skins the mesh, and bakes the arms down into the rig's A-pose rest.
4. Copy `out.glb` over `assets/characters/<id>/<id>.glb`. The GLB carries no clips, so the unit loads `<id>_animations.tres` through the humanoid bone map.
