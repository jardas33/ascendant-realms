# v0.111 Clean-Profile Benchmark Spec

The clean-profile lane spawns a temporary Chromium profile, disables extensions only inside that temporary profile, runs production-preview controls first, redacts the temporary profile path from artifacts, and deletes or ignores only that temporary directory after the run.

Required comparison rows: blank-page rAF, Phaser empty scene, campaign map, and Tier M representative battle. User browser profiles are never touched.
