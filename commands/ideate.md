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
  do NOT generate variations — the direction is already decided, so alternatives are
  noise. But you STILL owe a **fidelity preview**: hand off to `/design-forge:build`,
  then BEFORE finalizing render the built result at BOTH reference viewports (desktop
  AND mobile) and show ONE frame side-by-side against the reference — the mockup/spec
  as the "before", the built result as the "after" — and confirm the match with the
  user. Never "implement directly" with no preview: the concrete case is exactly where
  the build silently diverges from what was asked, and the fidelity preview is the only
  net that catches it.
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
   - **Mobile renders TWICE — the viewport is a range, not a number.** Take both heights
     from DESIGN.md (`alto útil / fold` and `alto del dispositivo`) and give EVERY variation
     two mobile frames, always — never only one, and never "this one doesn't touch the fold"
     (that judgement call is exactly what this replaces):
     - **`estado fold`** — iframe at the useful height (e.g. 390×745). This is what the user
       sees when they land, with the URL bar expanded. The frame edge IS the fold.
     - **`estado dispositivo`** — iframe at the device height (e.g. 390×852), with a **marked
       line at the fold height** and a legend ("fold con barra desplegada — 745px"). Below
       that line is content the user does not see until they scroll.
     Caption each frame with its state AND its number. **Size the iframe to the height being
     rendered** — do not render at one height and compensate: inside an iframe `100svh`
     resolves to the IFRAME, so an iframe at the true height makes `svh` layouts draw exactly
     as they do on the phone, with no patching. Additionally expose the fold as `--fold` on
     the iframe document, so a layout can anchor to it explicitly; it is a convenience, not
     the mechanism — the mechanism is the iframe height being real.
     Why both, always: a hero variation "fit" a 852 frame and landed 48px below the fold on
     the real phone; and a carousel whose slides differed 4px at 745 differed **107px** at
     852, with the controls jumping between slides. Each state hides bugs the other doesn't.

   A bare render with no badge/title/description is FORBIDDEN — the user must be able
   to compare with their eyes without imagining anything.

7. Serve, then **delegate** the render + visual verification, then show. The visual pass
   is INTERNAL QA — the human decides on the LIVE URL, never on a screenshot the agent
   read — so the pixels belong in a throwaway subagent context, not in the orchestrator's.

   **a) Serve (orchestrator).**
   - **Live dev stack substrate:** the running stack already serves the preview routes —
     use its URL (`http://localhost:<port>/dev/<name>-preview`). No extra server.
   - **Static substrate:** the Playwright MCP blocks `file://`. Serve the repo root (or
     `design/ideas/`) over HTTP: `python3 -m http.server 8899` (or `npx serve`).

   **b) Delegate the visual verification to a subagent (Task/Agent tool) — do NOT read the
   screenshots yourself.** Each fullPage capture is image tokens (one per viewport, more as
   real contexts multiply); reading them inline balloons the orchestrator context with
   pixels it does not need. A read-only / verification agent type is ideal — it only
   inspects, never edits the mockup. Launch ONE subagent per preview sheet with this
   contract:
   - **Give it:** the served preview URL, the desktop reference viewport (W×H), the mobile
     reference viewport at BOTH heights (`alto útil / fold` and `alto del dispositivo` from
     DESIGN.md), the real contexts from DESIGN.md, the list of decisive elements to measure
     (selectors for CTA, nav, end of the hero content — whatever the decision hangs on), and
     the broken-state checklist below.
   - **It must, PER viewport, in this order:**
     1. **Deterministic overflow gate FIRST — trust it OVER your eyes.** Evaluate in the
        page `document.documentElement.scrollWidth > document.documentElement.clientWidth`
        (and the same on any container that must not scroll). This is the ground truth for
        horizontal overflow — a passive eye both MISSES real clipping AND invents clipping
        that isn't there. If the gate is `true` → the layout overflows → `ilegible` with the
        offending element. If the gate is `false` but a screenshot *looks* clipped, the
        overflow is NOT real — suspect the render harness (next point), not the CSS. Golden
        rule: **when the gate and the eye disagree, the gate wins.**
     2. **Render at the REAL viewport — the mobile harness lies by default.** Prefer the
        Playwright MCP: it renders mobile at the TRUE width (device emulation /
        `browser_resize`). Chrome headless `--window-size=<W>,<H>` is UNRELIABLE for mobile —
        it clamps `window.innerWidth` to ~500px yet crops the screenshot to the requested
        width, manufacturing fake "clipped content" on the right edge (this exact artifact
        sent two hardened verifiers, and a human ground-truth, chasing a CSS bug that did not
        exist). So when you fall back to headless, FIRST assert `window.innerWidth === <target
        W>`; if it does not match, the capture is INVALID for that viewport — render mobile
        inside a `<W>px` iframe (which forces the true width) and screenshot that instead.
        Only once the viewport is real: scroll in steps with short delays so on-scroll
        reveals have fired, then LOOK at every image.
     3. **Measure the fold in BOTH mobile states — the eye cannot see 12px.** Mobile is
        measured at the useful height AND the device height (both from DESIGN.md), never at
        one. Per state, evaluate in the page `getBoundingClientRect().bottom` for each
        decisive element and report it against the fold height: how many px of air are left,
        or how many px it falls below. Then report the **DIFF of those positions between the
        two states** — an element that moves when the URL bar collapses is a FINDING, not
        noise. Report the numbers even when everything passes: "entra" is not a measurement,
        and a decision taken on "entra" is a decision taken on nothing. Two real bugs came
        from skipping this: a hero 48px below a fold that "fit" the frame, and a carousel
        whose slides differed 4px at 745 and 107px at 852 — approved on the numbers of one
        state, broken on the phone in the other.
   - **Broken-state checklist:** invisible text; broken states; **any element or text
     clipped at, or overflowing, the viewport edge — on BOTH desktop AND mobile** (not a
     desktop-only concern); collapsed cards, cropped photo subjects, and text buried over a
     busy zone on mobile. For a photo in `object-cover`, verify the CONTAINER at its real
     aspect ratio, never the `<img>` (capturing the `<img>` shows the full photo and hides
     the CSS crop = false OK); the crop itself is a decision resolved in step 8.
   - **It returns TEXT ONLY — never the images.** A structured verdict: per variation, per
     real context, per viewport → `legible` / `ilegible`, and for each `ilegible` the
     specific issue and where it is (selector / area) so a fix needs no pixels. Plus the
     **fold table**: per variation, per decisive element, its bottom edge in `estado fold`
     and in `estado dispositivo`, the air (or overflow) against the fold, and the diff
     between states. Text and numbers travel; pixels don't. A header line reporting how many
     captures it inspected ("cuarentené N capturas") — that count is the visible proof the
     image tokens stayed OUT of the orchestrator. And a final `go` / `no-go`.
   - **Adversarial second pass on every `go` — a `go` is the dangerous verdict.** A single
     passive verifier defaults to `go` and rubber-stamps. When the first subagent returns
     `go`, launch a SECOND, independent subagent that starts from the OPPOSITE prior:
     "assume something IS broken; your job is to REFUTE the go — find the clipped text, the
     illegible frame, the decapitated crop." Only a `go` that SURVIVES the refute pass
     counts. (When the first returns `no-go`, skip the refute — you already have fixes.)
   - **On `no-go` (from either pass):** fix the reported issue in the mockup (orchestrator
     inline, or delegate the fix), then re-launch verification. Loop until a refute-surviving
     `go` — every round's pixels stay quarantined in a fresh subagent context.

   **c) Show (orchestrator), only once the verdict is `go`.** Never show the user a sheet
   that failed internal QA — a preview that hides a broken mobile state sells a false
   decision as much as a broken desktop one. Show the sheet AS SOON as it passes: the
   user's verdict happens on the LIVE URL in their own browser. Always run `open <url>` for
   them, AND print each URL on its own line inside a code block — never inline in prose
   (terminal truncation corrupts copied URLs into 404s).

8. **Encuadre de assets en `object-cover`.** Whenever a variation places a photo in an
   `object-cover` container, the crop is a DECISION, not a guess — a single guessed
   `object-position` decapitates people and splits horizons, and screenshotting the
   `<img>` hides it. Resolve it with a framing preview that reuses the same in-place
   substrate, parametrized over the crop:
   - **Abanico de `object-position` on the REAL container.** Render the same photo in the
     same box at a fan of positions — `top`, `center 25%`, `center`, `center 75%`,
     `bottom` (a sensible default; adjust to the subject). One frame per position.
   - **Screenshot the CONTAINER, never the `<img>`.** Capture the container `<div>` at its
     REAL aspect ratio, so what you verify is exactly the crop the user will see — not the
     full uncropped photo.
   - **Desktop AND mobile.** The crop breaks DIFFERENTLY per viewport: the container's
     aspect ratio changes, so a face that fits the desktop cover gets decapitated in the
     mobile one. Fan BOTH viewports (hard rule 11); the encuadre may need a different
     `object-position` on mobile via `@media`.
   - **El dev elige**; fix the chosen `object-position` in the component (and record it in
     DESIGN.md when the container is reusable). No face-detection — comparing beats
     guessing, and the fan is cheap.

9. Iterate v2, v3… on the variations the user reacts to, same rules (baseline
   comparison, explicit format, real contexts, real width, live URL).

10. When the user picks the winner ("esta es"): implement it in the real project
   (phase 2, on a `feat/*` branch), and update DESIGN.md with any decisions the winning
   direction introduced. The non-winning previews are **ephemeral** — they live in the
   gitignored preview area (or `design/ideas/`), not as permanent inventory. Don't delete
   them mid-decision (the user may still want to A/B), but they're meant to be torn down
   once the winner lands.

11. **Close the exploration when it's truly over.** Once the winner has landed and the
    runner-ups are no longer needed, run `/design-forge:teardown` — it archives the
    preview mockups (so untracked work isn't lost) and removes the gitignored preview
    area (or, if the user explicitly created worktrees, the `idea/*` worktrees and
    branches). Ideation opens the scaffold; teardown takes it down. Don't leave andamios
    up forever.
