# v0.111 Host Snapshot Spec

Captures safe, private QA metadata for host pressure and browser reproducibility. It records platform, OS release, architecture, uptime, CPU model/core count, memory, Node/process memory, load average when supported, git commit/cleanliness, viewport, Chromium version, user agent, headless/headed mode, server mode, visibility, profiler capabilities, clean-profile posture, extension-disable posture, hardware-acceleration flag posture, and recording status when detectable.

Privacy boundary: no browser history, open tabs, profile contents, personal filenames, private process command lines, OS setting changes, process killing, rebooting, user profile mutation, save writes, gameplay changes, art generation/import, desktop work, or v0.112 work.
