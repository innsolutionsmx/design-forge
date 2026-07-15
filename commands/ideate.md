---
description: "Fase 1 — Ideación: 2-3 direcciones de diseño en worktrees paralelos"
argument-hint: "[brief corto de la pantalla o feature]"
---

You are running phase 1 (Ideation) of the design-forge pipeline.

## Preconditions

Read `PRODUCT.md` and `DESIGN.md` at the repo root. If they don't exist, stop and send
the user to `/design-forge:init` — ideating without brand context produces generic slop.

## Steps

1. Take the brief from $ARGUMENTS (or ask for it: what screen/feature, for whom, what
   must it achieve). Keep it to one paragraph.

2. Propose 2–3 distinct design directions that all honor DESIGN.md but differ in
   layout strategy, density, and motion character. For each: a name, a one-line thesis,
   and what it trades off. Ask the user which ones to build (default: all).

3. If the Stitch skills plugin is installed, offer to generate a visual concept per
   direction first (stitch-design's generate-design) so the user can react to images
   before code exists.

4. Font pairing: if DESIGN.md doesn't already lock typography, propose one pairing per
   direction (display + body), with fallback stacks, and record the chosen one in DESIGN.md.

5. Build each chosen direction in its own git worktree:
   - `git worktree add ../<repo>-idea-<name> -b idea/<name>`
   - Implement a static but styled version of the key screen in each worktree —
     enough fidelity to judge the direction, not production polish.

6. Present the variants side by side: run each (or screenshot via Playwright MCP if a
   dev server is available) and summarize how each direction interprets the brief.

7. When the user picks a winner: merge that branch's approach back, update DESIGN.md
   with any decisions the winning direction introduced, and remove the losing worktrees
   (`git worktree remove`). Next step: `/design-forge:build`.
