# v0.376 Black-Frame / Blank-Frame Rejection Report

Status: rejected evidence only.

The first v0.376 capture attempt rendered four uniform environment-background frames. Godot reported:

`No loader found for resource: res://assets/v0376/original_barrosan/barrosan_original_kit_v0376.glb`

The cause was an incomplete first import of the newly generated GLB, not a visual pass result. The frames were not used for scoring, comparison, or a review pack. The Godot editor import pass was then run, the GLB import completed, and iteration 01 was captured again. The four valid iteration-01 frames and the subsequent iteration-02 through iteration-04 frames were opened and inspected.
