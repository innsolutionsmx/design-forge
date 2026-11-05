---
description: "Réplica 1:1 de una referencia (captura o URL) con los assets del proyecto, preview de fidelidad verificado y review opcional"
argument-hint: "[captura adjunta y/o URL de referencia + dónde va en el proyecto]"
---

**design-forge 1.0.0 · replicate.** State this line, verbatim, in your first message to
the user — it proves which version of this command is actually loaded.

You are running the main flow of the design-forge pipeline: the user brings a design they
found (a screenshot, optionally its URL) and wants it in their project **identical, 1:1,
but with the project's own assets**. The user never has to say "1:1", "don't use the
example's assets" or "show me a preview" — this command does all three by default.

## Preconditions

- Read `PRODUCT.md` and `DESIGN.md` at the repo root. Missing → `/design-forge:init`.
  Take the reference viewports (desktop AND mobile, mobile at BOTH heights: `alto útil /
  fold` and `alto del dispositivo`) and the brand asset inventory. A missing mobile
  viewport → ask for it and record it before continuing.
- **Sync check.** `git fetch origin` then `git rev-list --count HEAD..origin/<base>` (the
  branch the site serves). Count 0 → continue silently. Unpulled commits → STOP and report
  the count: a stale clone makes the "before" and the build land on a dead base.

## 1. Intake

From the message (and $ARGUMENTS) establish, asking only for what's missing:
- **The reference**: the attached screenshot(s) — the source of truth for the design.
  Optionally the **URL** where the user found it.
- **The target**: where it goes in the project (a new section, or replacing an existing
  one — which file/route).

If it replaces an existing section, capture the **baseline** (the "before") at desktop and
mobile now.

**What "1:1" copies — the default.** Layout, composition, proportions, spacing rhythm,
type scale and hierarchy, component shapes, and effects/animations come from the
reference. **Color and font families come from `DESIGN.md`** (DESIGN.md is law), unless
the user says to copy those too ("con sus colores"). State this default in one line of the
intake summary so the user can override it — don't ask.

## 2. Read the reference

- Inventory the reference section by section: each block, its layout, its decisive
  elements (headline, CTA, carousel, cards), and every visible effect.
- **With a URL:** open it with the Playwright MCP to observe what a screenshot can't show —
  hover states, scroll reveals, carousel motion, transitions — and measure exact values
  (`getComputedStyle`). If SkillUI is installed (`which skillui`), offer
  `skillui --url <URL> --format design-md` to extract exact spacing, type scale and motion
  values. Use them for proportions and motion; never let them override DESIGN.md colors or
  fonts unless the user asked.
- **Without a URL, an effect the screenshot implies but doesn't show** (a carousel, an
  animated background): don't guess silently. Propose a concrete one with its source —
  "encontré este carrusel en <url>, con este efecto" — and let the user pick. Component
  libraries (21st.dev, shadcn) are inspiration here, never a dependency the design needs.

## 3. Asset map (before any code)

**Never use the reference's assets.** The screenshot is someone else's site: its photos,
logos, illustrations, icons and mockups are not the user's. Never crop, copy, trace,
hotlink or embed anything from the screenshot or the reference URL.

Print a table: `asset de la referencia` → `asset del proyecto` (path) or `pendiente`. Fill
it from DESIGN.md's asset inventory and the repo (`public/`, `assets/`, `resources/`,
`static/`). For each `pendiente`, use a neutral placeholder of the same size and aspect
ratio (a token-colored box with a label like "foto: equipo") — never the reference image.
If any asset is `pendiente`, ask once whether to continue with placeholders or wait; with
no `pendiente`, continue without asking.

## 4. Build 1:1

Build directly in the real project, matching its stack and conventions (on a `feat/*`
branch when the repo works that way) — the direction is decided, so there are no
variations and no throwaway mockups.
- Tokens only from DESIGN.md; a value the design needs that doesn't exist → add it to
  DESIGN.md first and tell the user.
- Mobile ships WITH the component: build the mobile composition the reference implies (or
  shows), against the mobile viewport and breakpoints in DESIGN.md.
- **Photos in `object-cover`:** the project's photos are framed differently from the
  reference's, so the crop is a decision. Render a fan of `object-position` (`top`,
  `center 25%`, `center`, `center 75%`, `bottom`) on the REAL container at desktop and
  mobile, screenshot the container (never the `<img>`), and let the user pick.
- CSS specificity: write selectors that win against inherited rules (`a.nav-cta`, not
  `.nav-cta` — `.nav-links a` at (0,2,1) beats it and leaves the text invisible).

## 5. Preview sheet

Create the gitignored preview area once, before the first capture:
`mkdir -p design/preview/captures` and add `design/preview/` and `.playwright-mcp/` to
`.gitignore`. Every Playwright `filename` gets the full path under
`design/preview/captures/` — the MCP writes into existing subdirs but does not create them,
and relative names land in the repo root.

Write `design/preview/index.html`: per section, the **reference** (the screenshot) next to
the **result** (an iframe of the live page at that section). Frames:
- **desktop** at the real desktop width;
- **mobile · estado fold** — iframe at `alto útil` (e.g. 390×745): the frame edge is the
  fold;
- **mobile · estado dispositivo** — iframe at `alto del dispositivo` (e.g. 390×852) with a
  marked line at the fold height;
- **transición** — the section with its PREVIOUS neighbor visible (the scroll where it
  enters the screen), the only frame that shows whether it competes with what's above.

Caption every frame with viewport and state. Size each iframe to the height it renders
(`100svh` inside an iframe resolves to the iframe). With no dev stack running, serve the
repo over HTTP (`python3 -m http.server 8899`) — the Playwright MCP blocks `file://`.

## 6. Verify — one adversarial subagent

The visual check is internal QA; the user's verdict happens on the live URL. Delegate it
to ONE read-only subagent so the screenshots never enter your context. Its prior is
adversarial: **"assume something is broken and find it — the result must match the
reference, and a `go` is the dangerous verdict."**

Give it: the preview URL, the reference screenshot path(s), the viewports (desktop + both
mobile heights), the decisive elements (selectors), the asset map, and this contract.

Per viewport, in order:
1. **True viewport first.** Mobile via Playwright **device emulation** (overlay scrollbar,
   like the phone). If only `browser_resize` is available, inject
   `html{scrollbar-width:none}::-webkit-scrollbar{width:0}`. Assert
   `document.documentElement.clientWidth === <target width>` — `innerWidth` reports 390
   even when layout renders at 375. A failed assert means the capture is invalid, not the
   design.
2. **Rest state.** Force any auto-hiding header/navbar to its resting state with CSS
   (`transform: translateY(-100%) !important` on its real selector), not JS; pause
   autoplay. Report the header's height anyway — it covers content while the user scrolls.
   Before blaming the site for an intermittent element, rule out the instrument.
3. **Overflow gate.** `scrollWidth > clientWidth` on the document and every container that
   must not scroll. The gate beats the eye: gate `false` + image looks clipped → suspect the
   harness.
4. **Fold, both mobile states.** `getBoundingClientRect().bottom` of each decisive element
   against the fold height, in `estado fold` and `estado dispositivo`, plus the diff
   between them. An element that moves is a finding. Report the numbers even when it passes.
5. **Fidelity vs reference, section by section.** Scroll in steps (so reveals fire), then
   compare against the screenshot: layout, proportions, spacing, hierarchy, effects. List
   every divergence with its selector.
6. **Hierarchy.** Elements of comparable visual weight (same accent, similar size)
   co-visible in one viewport, checked against the section's goal — two equal CTAs
   competing is a finding even if both are legible.
7. **Assets.** Every `src`/`background-image` in the section resolves to a project path
   from the asset map — none from the reference.
8. **Broken states.** Invisible text, clipped text, collapsed cards, cropped subjects, text
   over a busy zone, console errors.

**It returns TEXT only:** a header "cuarentené N capturas"; per section × viewport
`fiel`/`diverge` and `legible`/`ilegible` with selector-level issues; the fold table; the
asset check; a `hallazgos` list; and `go` / `no-go`.

**On `no-go`:** fix and relaunch a FRESH subagent. Maximum 3 verification rounds; still
`no-go` after 3 → stop and report what's structurally wrong.

**Log every round** in `design/verificaciones.md` (committed, outside the preview area):
`<fecha> · <sección> · ronda N · <hallazgos, o "sin hallazgos">`. This record decides, with
data, whether the verifier needs a separate refuter again: a defect the user finds after a
`go` gets logged too, as `escapó: <qué>`.

## 7. Show

Only after a `go`. Run `open <url>` for the user and print each URL on its own line in a
code block (never inline — terminal truncation corrupts copied URLs). Summarize the
verifier's numbers and the divergences you accepted on purpose. Iterate on feedback with
the same build → verify → show cycle.

## 8. Close

When the user approves ("esta es", "así queda"):
1. **Ask before reviewing:** "¿Corro el review con Impeccable (`/design-forge:review`)? Gasta
   tokens; para un cambio chico o un 1:1 que ya quedó fiel quizás no valga la pena." Never
   run it without a yes.
2. Update DESIGN.md with any token or pattern the design introduced.
3. **Clean up without archiving** (after the review, if it ran): delete `design/preview/` (captures included) — the result
   lives in the project and the reference is the user's screenshot. Keep
   `design/verificaciones.md` and the `.gitignore` entries: they're infrastructure, not run
   residue. Learnings go to memory, not to files in the repo.
