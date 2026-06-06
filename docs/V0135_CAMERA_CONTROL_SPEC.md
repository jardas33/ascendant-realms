# v0.135 Camera Control Spec

Status: `PASS_V0135_CAMERA_CONTROL` after the headed RTS ergonomics proof.

Camera improvements are bounded to player comfort and readability:

- Mouse-wheel zoom is accepted from the packaged slice and clamped to safe bounds.
- WASD and arrow-key panning move the fixed orthographic camera within authored bounds.
- Space returns focus to Aster without changing objective state.
- The Worker objective can focus the Worker so the next step is easier to find.
- The minimap viewport indicator remains present.
- The camera avoids sudden disorienting jumps and giant unused margins.

This does not add edge-pan, new maps, new camera modes, new rendering systems, or editor-authored scene work.
