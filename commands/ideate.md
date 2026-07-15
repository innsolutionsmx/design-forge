---
description: "Fase 1 — Ideación: preview comparativo explícito con 2-3 variaciones en worktrees paralelos"
argument-hint: "[brief corto de la sección o feature]"
---

You are running phase 1 (Ideation) of the design-forge pipeline.

## Preconditions

Read `PRODUCT.md` and `DESIGN.md` at the repo root. If they don't exist, stop and send
the user to `/design-forge:init` — ideating without brand context produces generic slop.

From DESIGN.md take the **reference viewport** (primary + mobile) and the **real
contexts** inventory (the visual environments where components live — e.g. dark hero,
light content sections). If the viewport isn't recorded, ask the user for it and save
it to DESIGN.md before continuing. If real contexts aren't recorded, detect them from
the live site (or ask) and save them too.

## Step 0a — Sync check (before anything else)

A stale clone produces a FALSE baseline — worse than no baseline (a whole ideation
round in landing-crb was built 37 commits behind upstream and had to be redone).
Before routing:

1. `git fetch origin`
2. `git rev-list --count HEAD..origin/main` (and against the project's base branch,
   e.g. `origin/dev`, if that's what the site serves).
3. If the count is 0 → continue silently (the normal case costs nothing).
4. If there are unpulled commits → STOP. Report the count and REFUSE to take a
   baseline or build mockups until the user syncs. Do not offer to "continue anyway"
   — every artifact of the session would be built on a dead base.

## Step 0b — Route the request

Determine what the user actually brought:

- **A concrete design** (a finished mockup image, an exact spec, "implementá ESTO") →
  do NOT generate variations. Hand off directly to `/design-forge:build`. Generating
  alternatives against a decided design is noise.
- **A design request without a concrete design** (an idea, a direction, "mejorá el
  navbar") → comparative preview mode. Continue below.

## Step 1 — Baseline (before any ideation)

Determine whether the brief targets an EXISTING section of the site:

- **Exists** → take a baseline screenshot of the real section at the reference viewport
  BEFORE ideating. It is the mandatory "before" in every comparison that follows.
- **Doesn't exist** → tell the user explicitly: "esto es ideación desde cero — no vas a
  poder comparar contra nada. ¿Seguimos?" and wait for their confirmation.

## Steps

1. Take the brief from $ARGUMENTS (or ask: what section/feature, for whom, what must it
   achieve). Keep it to one paragraph.

2. Propose the variations — minimum 2, ideal 3 — all honoring DESIGN.md but differing
   in layout strategy, density, and motion character:
   - One **faithful** to what was asked (the literal interpretation).
   - At least one **fresh direction of your own** — bolder, something the user didn't
     ask for but should see (e.g. a floating-island navbar à la Linear/Vercel). This is
     mandatory: the fresh option is where the comparison earns its keep.
   - For each: a name, a one-line thesis, its tradeoff, and a status chip —
     `Recomendado` / `Variación fresca` / `Riesgo`.

3. If the Stitch skills plugin is installed, offer to generate a visual concept per
   direction first so the user can react to images before code exists.

4. Font pairing: if DESIGN.md doesn't already lock typography, propose one pairing per
   direction (display + body) and record the chosen one in DESIGN.md.

5. Build each variation in its own git worktree:
   - `git worktree add ../<repo>-idea-<name> -b idea/<name>`
   - **Worktrees only carry committed files.** If PRODUCT.md or DESIGN.md are
     uncommitted, copy them into each worktree right after `git worktree add`.
   - Build each direction as a **self-contained static HTML mockup** with the real token
     values copied from DESIGN.md — high visual fidelity, zero risk to the project.
   - Reference real repo assets (logo, mascot, key photos — see the asset inventory in
     DESIGN.md) by relative path; they resolve because the whole worktree is served
     over HTTP.
   - **CSS specificity discipline**: write selectors specific enough to win against
     inherited rules (`a.nav-cta`, not `.nav-cta` — `.nav-links a` (0,2,1) beats
     `.nav-cta` (0,2,0) and leaves text invisible). A mockup that renders wrong makes
     the preview lie.
   - **Vertical budget is HARD from v1**: the design must fit the primary reference
     viewport intentionally. Never depend on an exact height — elements that cross the
     fold must look deliberate (e.g. a stats bar half above / half below). Use fluid
     spacing: `clamp()` for paddings, `min-height: 100svh` over fixed heights.

6. **Compose the comparative preview sheet** — the deliverable of this phase. One
   self-contained HTML page that presents ALL variations for decision. Per variation:
   - **Badge de caso** (A / B / C…).
   - **Título** of the option.
   - **Chip de estado**: `Recomendado` / `Variación fresca` / `Riesgo`.
   - **Descripción corta** (1–2 lines): what it is and its tradeoff.
   - **Frames**: the variation rendered in EACH real context from DESIGN.md (e.g. over
     the dark hero AND over a light content page), each frame with a caption naming the
     context and a `legible` / `ilegible` badge.
   - Frames render at the **real target width** (the reference viewport — e.g. 1440px),
     stacked vertically. NEVER narrow columns: a narrow crop produces false overflows.
     If you additionally show a comparison grid, caption it explicitly: "el recorte es
     del encuadre, no del diseño".

   A bare render with no badge/title/description is FORBIDDEN — the user must be able
   to compare with their eyes without imagining anything.

7. Serve, render, verify, show:
   - The Playwright MCP blocks `file://`. Serve the PARENT directory of the worktrees
     over HTTP: `python3 -m http.server 8899` (or `npx serve`).
   - Render the preview sheet to image with Playwright at the reference viewport. If
     the Playwright MCP is unavailable, fall back to Chrome headless:
     `chrome --headless=new --screenshot=out.png --window-size=<W>,<H> <url>` and Read
     the resulting image.
   - Before any fullPage capture, scroll through the page in steps with short delays
     so on-scroll reveals have fired.
   - **Verify the render visually before showing it** — look at the image yourself:
     invisible text, broken states, false overflows. Never trust that "the CSS looks
     right". A preview that hides a broken state sells a false decision.
   - Show the sheet AS SOON as it's ready, and the user's verdict happens on the LIVE
     URL in their own browser: always run `open <url>` for them, AND print each URL on
     its own line inside a code block — never inline in prose (terminal truncation
     corrupts copied URLs into 404s).

8. Iterate v2, v3… on the variations the user reacts to, same rules (baseline
   comparison, explicit format, real contexts, real width, live URL).

9. When the user picks the winner ("esta es"): implement it in the real project
   (phase 2, on a `feat/*` branch), and update DESIGN.md with any decisions the winning
   direction introduced. Non-winning mockups stay **parked in their worktrees as
   inventory** — do not delete them.
