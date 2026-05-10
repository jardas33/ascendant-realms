# v0.9.1 Style-Frame Intake Protocol

Date: 2026-05-10  
Status: controlled non-runtime intake protocol. This document does not generate, import, download, approve, or wire image assets.

## Purpose

v0.9 defined what Cinderfen should look like before art generation or replacement work begins. v0.9.1 defines how future Cinderfen style-frame candidates may safely enter the repository for review without becoming runtime assets.

This protocol exists to keep Ascendant Realms original, source/license safe, and gameplay-readable while future visual work begins. A style-frame candidate is evidence for discussion, comparison, and review. It is not production art, runtime art, or approval to replace any current asset.

## What Counts As A Style-Frame Candidate

A style-frame candidate is a non-runtime visual reference intended to evaluate future Cinderfen direction. Examples include:

- a terrain mood/material frame for ash-glass wetland ground, causeways, water, reeds, fog, or cinder scorch;
- a Cinder Shrine landmark sheet or ownership-state exploration;
- an Ashen outpost architecture sheet;
- a prop/material sheet for ruined stone edging, dead reeds, barricades, or road markers;
- a minimap/readability reference;
- a UI/background mood frame if it supports Cinderfen visual identity without replacing runtime UI.

Style-frame candidates are allowed only in review locations. They must not be placed in runtime asset folders, imported by TypeScript, preloaded by Phaser, referenced by runtime manifest entries, or treated as production-approved files.

## Allowed Sources

Future candidates may come from:

- manually generated images from user-provided tools, with the full generation prompt and tool details recorded;
- hand-made mockups created by Emmanuel or a collaborator;
- licensed original art with written usage permission;
- user-owned concept images;
- commissioned art where ownership, license, usage permission, and commercial rights are documented;
- internal text-only examples, schemas, and templates used to explain the intake process.

Allowed does not mean automatically accepted. Every candidate still needs source/license metadata, original-IP review, Cinderfen pillar review, readability review, and a later screenshot comparison before runtime use can even be considered.

## Forbidden Sources And Uses

The following are forbidden for this intake:

- scraped web images;
- copyrighted franchise references used as assets;
- screenshots, crops, paintovers, or edits of Warcraft, Warlords Battlecry, or other protected games;
- copied factions, units, buildings, maps, UI, symbols, lore, music, sound, or protected art styles;
- unknown-source images marked safe;
- direct runtime replacement;
- placement in `public/assets/final/` or other runtime-loaded paths;
- production approval without proof;
- generated images created by Codex during this goal;
- image API calls, downloads, scraping, or external asset import during this goal;
- large binary commits unless Emmanuel explicitly confirms they are intended for review and source/license metadata is ready.

## Required Metadata Before Commit

Before any candidate image is committed, a matching metadata record must exist and be reviewable. Required fields:

- candidate id;
- title;
- file name and review file path;
- submitted by;
- creator, artist, or tool;
- source type;
- creation date and submission date;
- license or ownership status;
- allowed usage;
- commercial use permission;
- derivative use permission;
- attribution requirement;
- full generation prompt if generated;
- negative prompt if generated;
- post-processing notes;
- reference sources;
- protected-IP risk;
- originality notes;
- intended use;
- related v0.9 prompt/spec section;
- replacement target, if any;
- scale and readability notes;
- reviewer;
- review date;
- review status;
- production approval status;
- rejection reason when rejected;
- freeform notes.

If any source/license field is unknown, the candidate can be kept only as `reference-only` or rejected. Unknown source means not production-safe.

## Review Stages

Use these stages for future non-runtime candidates:

### Inbox

The file has been received or listed, but metadata may be incomplete. It is not approved, not runtime-safe, and not production-safe.

Allowed next step: fill metadata or reject.

### Metadata Complete

The metadata form is complete enough to review source, license, tool, prompt, intended use, and protected-IP risk.

Allowed next step: source/license review and visual review.

### Reference-Only

The candidate may be used as a non-runtime discussion/reference item but is not eligible for runtime testing. This is the safest stage for incomplete rights, uncertain derivative status, broad mood references, or concept-only images.

Allowed next step: keep as reference or replace with safer original work.

### Candidate

The candidate has enough source/license evidence and visual fit to compare against v0.9 Cinderfen pillars, but it is still non-runtime.

Allowed next step: screenshot comparison planning and human review.

### Approved-For-Prototype

The candidate is acceptable as a non-runtime prototype reference. It may inform future art direction or manual mockups, but it still cannot be loaded by the game.

Allowed next step: prepare a future runtime-test proposal only if source/license proof is strong.

### Approved-For-Runtime-Test

The candidate has complete source/license metadata, low protected-IP risk, strong visual/readability review, and a documented screenshot QA target list. This still does not add runtime wiring by itself.

Allowed next step: a separately scoped runtime-test goal for one tiny replacement candidate.

### Approved-For-Production

Reserved for a later production process after source/license proof, human approval, manifest validation, screenshot QA, runtime verification, and production rights review. v0.9.1 should not use this stage for any current unknown-source or newly received candidate.

Allowed next step: none in v0.9.1.

## Core Rules

- Unknown source means not production-safe.
- A style frame is not runtime art.
- A style frame is not a runtime manifest entry.
- No image goes runtime without manifest metadata, validation, screenshot QA, and human review.
- No candidate should be copied into runtime folders until a later goal explicitly scopes that action.
- Review metadata must be more conservative than visual enthusiasm.
- Protected-IP concern blocks runtime testing until resolved.
- A candidate can be visually strong and still rejected for source/license or originality risk.
- Screenshot QA remains human-reviewed and non-pixel-perfect.

## Human Review Checklist

Before a candidate advances beyond inbox, answer:

- Does the source clearly identify who made it or what tool created it?
- Does the license allow the intended use?
- Is commercial use allowed if future production needs it?
- Are derivative rights clear?
- Is attribution required?
- Is the generation prompt recorded when relevant?
- Does the image avoid protected franchise shapes, symbols, faction reads, UI language, or copied art direction?
- Does it match the v0.9 Cinderfen visual pillars?
- Are roads, shrines, units, buildings, and fog likely to remain readable?
- Does it support current browser prototype constraints?
- Would it still work under future desktop-quality expectations?
- Is the candidate review-only, prototype-only, runtime-test, or production-ready?
- What evidence supports that stage?

## Codex Responsibilities

Codex may:

- create non-runtime folder structures, README files, templates, validation scripts, and documentation;
- inspect already-present candidate files without moving or copying them;
- catalog files only when they are clearly user-provided or already present;
- validate metadata;
- flag missing source/license fields;
- flag protected-IP risk;
- recommend rejection when metadata is incomplete or unsafe;
- map candidates to screenshot QA targets;
- keep runtime code untouched unless a later goal explicitly scopes a tiny runtime test.

Codex must not:

- generate images;
- call image APIs;
- download or scrape images;
- import unlicensed art;
- move, rename, delete, replace, or wire runtime art files;
- mark unknown-source assets production-safe;
- add gameplay, maps, units, factions, rewards, save changes, or broad systems;
- hide source/license uncertainty;
- treat a visual mockup as permission to ship.

## v0.9.1 Decision

This protocol authorizes only controlled non-runtime intake work. It prepares the repository for future candidate images, but no candidate is currently approved for runtime or production use because of this document alone.
