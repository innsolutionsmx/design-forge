---
description: "Fase 1 — Ideación: preview comparativo explícito con 2-3 variaciones in-place (sin worktrees por defecto)"
argument-hint: "[brief corto de la sección o feature]"
---

You are running phase 1 (Ideation) of the design-forge pipeline.

## Preconditions

Read `PRODUCT.md` and `DESIGN.md` at the repo root. If they don't exist, stop and send
the user to `/design-forge:init` — ideating without brand context produces generic slop.

From DESIGN.md take the **reference viewports** (desktop AND mobile — both are required)
and the **real contexts** inventory (the visual environments where components live —
e.g. dark hero, light content sections). If either viewport isn't recorded (the mobile
one is mandatory, not optional), ask the user for it and save it to DESIGN.md before
continuing. If real contexts aren't recorded, detect them from the live site (or ask)
and save them too.

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

5. Build each variation **in-place — never create a worktree automatically.** In a
   project with a mounted dev stack (Docker/Vite) a sibling worktree is invisible to the
   HMR watcher and breaks the live preview; isolation is not worth that friction for a
   throwaway mockup. The default substrate adapts to the project:

   - **Detect the substrate first.** Is a live dev stack serving the checkout (Docker/
     Vite/Next/HMR watching the working directory)? Look for a running dev server
     (`docker compose ps`, a `vite`/`next dev` process, a `dev` script in `package.json`)
     and a served preview URL.
     - **Live dev stack → temporary in-project preview routes.** Add each variation as a
       throwaway route/view inside the running app, under a single gitignored preview
       area — e.g. `/dev/<name>-preview` (a Vite/Next route, or a Blade view under a
       `dev-preview/` include) backed by a gitignored dir (`resources/dev-preview/`,
       `src/dev-preview/` — whatever the stack expects). The stack that is ALREADY up
       serves them with real HMR, real assets, and the real CSS pipeline (Tailwind/
       DaisyUI compile for real) — highest fidelity, no second server, no sibling
       folder. The whole preview area is deleted when the user picks (phase 4).
     - **No live dev stack (static site) → self-contained HTML mockups in a gitignored
       subdir.** Write each direction to `design/ideas/<name>.html` (gitignore
       `design/ideas/`) as a self-contained static mockup with the real token values
       copied from DESIGN.md. Reference real repo assets by relative path; they resolve
       because the subdir is served over HTTP (Playwright MCP blocks `file://`).
   - **Worktree is opt-in only, and born grouped.** Create a worktree ONLY when the user
     explicitly asks for real parallelism — two live states at once, a hotfix without
     stashing. Never as the automatic default. When you do, put it INSIDE the repo under a
     gitignored `.worktrees/` dir, not as a loose sibling folder: `git worktree add
     .worktrees/idea-<name> -b idea/<name>`. Add `.worktrees/` to the project's `.gitignore`
     first (once) so the nested worktree doesn't show up as untracked in the main checkout.
     Grouped and out of the projects view — the opposite of scattered `../<repo>-idea-*`
     siblings. **Worktrees only carry committed files**: copy uncommitted PRODUCT.md/
     DESIGN.md into the worktree right after `git worktree add`.
   - **Uncommitted context files (in-place):** PRODUCT.md/DESIGN.md live in the same
     working tree — nothing to copy. (Only an explicit worktree needs them copied in.)
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
     the dark hero AND over a light content page), at BOTH the desktop AND the mobile
     reference viewport — mobile is not optional. Each frame captioned with the context
     AND the viewport, and a `legible` / `ilegible` badge PER viewport. A composition can
     be legible on desktop and illegible on mobile — that is exactly the bug this catches:
     background-photo cards that read fine on desktop but, collapsed to 1 column, squash
     into strips, crop their subjects, and bury text under a busy zone.
   - Desktop frames render at the **real desktop target width** (the reference viewport —
     e.g. 1440px); mobile frames at the **real mobile width** (e.g. 390px), showing the
     ACTUAL single-column composition, not a squished desktop. Stack them vertically.
     NEVER narrow a desktop frame to fake mobile: a narrow crop produces false overflows.
     If you additionally show a comparison grid, caption it explicitly: "el recorte es
     del encuadre, no del diseño".

   A bare render with no badge/title/description is FORBIDDEN — the user must be able
   to compare with their eyes without imagining anything.

7. Serve, render, verify, show:
   - **Live dev stack substrate:** the running stack already serves the preview routes —
     use its URL (`http://localhost:<port>/dev/<name>-preview`). No extra server.
   - **Static substrate:** the Playwright MCP blocks `file://`. Serve the repo root (or
     `design/ideas/`) over HTTP: `python3 -m http.server 8899` (or `npx serve`).
   - Render the preview sheet to image with Playwright at BOTH the desktop and the mobile
     reference viewport — one capture per viewport, so the mobile composition is verified
     with the same rigor as desktop. If the Playwright MCP is unavailable, fall back to
     Chrome headless: `chrome --headless=new --screenshot=out.png --window-size=<W>,<H> <url>`
     (run it once per viewport size) and Read each resulting image.
   - Before any fullPage capture, scroll through the page in steps with short delays
     so on-scroll reveals have fired.
   - **Verify the render visually before showing it** — look at BOTH images yourself:
     invisible text, broken states, false overflows on desktop; and on mobile, collapsed
     cards, cropped photo subjects, and text buried over a busy zone. Never trust that
     "the CSS looks right". A preview that hides a broken mobile state sells a false
     decision just as much as a broken desktop one.
   - Show the sheet AS SOON as it's ready, and the user's verdict happens on the LIVE
     URL in their own browser: always run `open <url>` for them, AND print each URL on
     its own line inside a code block — never inline in prose (terminal truncation
     corrupts copied URLs into 404s).

8. Iterate v2, v3… on the variations the user reacts to, same rules (baseline
   comparison, explicit format, real contexts, real width, live URL).

9. When the user picks the winner ("esta es"): implement it in the real project
   (phase 2, on a `feat/*` branch), and update DESIGN.md with any decisions the winning
   direction introduced. The non-winning previews are **ephemeral** — they live in the
   gitignored preview area (or `design/ideas/`), not as permanent inventory. Don't delete
   them mid-decision (the user may still want to A/B), but they're meant to be torn down
   once the winner lands.

10. **Close the exploration when it's truly over.** Once the winner has landed and the
    runner-ups are no longer needed, run `/design-forge:teardown` — it archives the
    preview mockups (so untracked work isn't lost) and removes the gitignored preview
    area (or, if the user explicitly created worktrees, the `idea/*` worktrees and
    branches). Ideation opens the scaffold; teardown takes it down. Don't leave andamios
    up forever.
