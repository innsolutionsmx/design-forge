---
description: "Fase 1 — Ideación: 2-3 direcciones de diseño en worktrees paralelos"
argument-hint: "[brief corto de la sección o feature]"
---

You are running phase 1 (Ideation) of the design-forge pipeline.

## Preconditions

Read `PRODUCT.md` and `DESIGN.md` at the repo root. If they don't exist, stop and send
the user to `/design-forge:init` — ideating without brand context produces generic slop.

From DESIGN.md take the **reference viewport** (primary + mobile). If it isn't recorded,
ask the user for it (their real screen minus browser chrome) and save it to DESIGN.md
before continuing. Every screenshot in this phase uses that viewport — an agent-side
1440×900 capture that doesn't match the user's screen produces false verdicts about
the fold and proportions.

## Step 0 — Baseline (before any ideation)

Determine whether the brief targets an EXISTING section of the site:

- **Exists** → take a baseline screenshot of the real section at the reference viewport
  BEFORE ideating. It is the mandatory "before" in every comparison that follows.
- **Doesn't exist** → tell the user explicitly: "esto es ideación desde cero — no vas a
  poder comparar contra nada. ¿Seguimos?" and wait for their confirmation.

## Steps

1. Take the brief from $ARGUMENTS (or ask: what section/feature, for whom, what must it
   achieve). Keep it to one paragraph.

2. Propose 2–3 distinct design directions that all honor DESIGN.md but differ in layout
   strategy, density, and motion character. For each: a name, a one-line thesis, and what
   it trades off. This format is proven — it lets the user decide fast. Ask which ones to
   build (default: all).

3. If the Stitch skills plugin is installed, offer to generate a visual concept per
   direction first so the user can react to images before code exists.

4. Font pairing: if DESIGN.md doesn't already lock typography, propose one pairing per
   direction (display + body) and record the chosen one in DESIGN.md.

5. Build each chosen direction in its own git worktree:
   - `git worktree add ../<repo>-idea-<name> -b idea/<name>`
   - **Worktrees only carry committed files.** If PRODUCT.md or DESIGN.md are
     uncommitted, copy them into each worktree right after `git worktree add`.
   - Build each direction as a **self-contained static HTML mockup** with the real token
     values copied from DESIGN.md — high visual fidelity, zero risk to the project.
   - Reference real repo assets (logo, mascot, key photos — see the asset inventory in
     DESIGN.md) by relative path; they resolve because the whole worktree is served
     over HTTP.
   - **Vertical budget is HARD from v1**: the design must fit the primary reference
     viewport intentionally. Never depend on an exact height — elements that cross the
     fold must look deliberate (e.g. a stats bar half above / half below). Use fluid
     spacing: `clamp()` for paddings, `min-height: 100svh` over fixed heights.

6. Serve and show:
   - The Playwright MCP blocks `file://`. Serve the PARENT directory of the worktrees
     over HTTP before anything else: `python3 -m http.server 8899` (or `npx serve`).
   - Before any fullPage screenshot, scroll through the page in steps with short delays
     so on-scroll reveals (IntersectionObserver entrances) have fired — otherwise
     revealed content captures at opacity 0 and the mockup looks broken. Then capture.
   - Screenshot each variant at the reference viewport **as soon as it's ready** —
     progressive review, the user follows along instead of waiting for all variants.
   - Screenshots are reference only. The user's verdict happens on the LIVE URL in
     their own browser: always run `open <url>` for them, AND print each URL on its
     own line inside a code block — never inline in prose, because terminal truncation
     (`…`) corrupts copied URLs into 404s.

7. Iterate v2, v3… on the directions the user reacts to, same rules (baseline
   comparison, reference viewport, live URL).

8. When the user picks the winner ("esta es"): implement it in the real project
   (phase 2, on a `feat/*` branch), and update DESIGN.md with any decisions the winning
   direction introduced. Non-winning mockups stay **parked in their worktrees as
   inventory** — do not delete them.
