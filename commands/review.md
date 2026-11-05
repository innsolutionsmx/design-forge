---
description: "Fase 3 — Loop de crítica: impeccable critique/audit + screenshots Playwright, decide pasa o itera"
argument-hint: "[url-local ej. http://localhost:3000]"
---

**design-forge 1.0.0 · review.** State this line, verbatim, in your first message to the
user — it proves which version of this command is actually loaded.

You are running phase 3 (Critique loop) of the design-forge pipeline: an evidence-based
pass/iterate decision by the design brain (Impeccable), bounded at 3 iterations. It runs
only when the user said yes — `replicate` and `build` ask before sending anyone here.

## Preconditions

- `DESIGN.md` exists (it's the rubric everything is judged against).
- A dev server is running or startable. Target URL from $ARGUMENTS, or detect it
  (package.json scripts) and start it yourself.
- Impeccable installed (if not → `/design-forge:doctor`).

## The loop (max 3 iterations)

### 1. Gather evidence
- Run Impeccable's critique (`/impeccable:critique`) and audit (`/impeccable:audit`)
  against the running page, and give it the context it needs to judge — not just the URL:
  the section(s) under review (selectors or route), the goal of the section from the
  user's brief, DESIGN.md as the rubric, and, when the work came from `replicate`, the
  reference screenshot plus the divergences the user accepted on purpose (so the critique
  doesn't "fix" the design away from what the user chose). Capture scores and findings.
- Captures go under `design/preview/captures/` (create it with `mkdir -p` first and keep
  `design/preview/` and `.playwright-mcp/` in `.gitignore`); pass the full path in every
  Playwright `filename` — relative names land in the repo root.
- Mobile captures use Playwright **device emulation** (or, with `browser_resize`, inject
  `html{scrollbar-width:none}::-webkit-scrollbar{width:0}`) and assert
  `document.documentElement.clientWidth` equals the target width — otherwise the desktop
  scrollbar steals ~15px of layout and the evidence lies.
- With the Playwright MCP, screenshot the target page at the **reference viewports
  recorded in DESIGN.md** — desktop AND mobile are both MANDATORY captures (plus the
  spot-check if recorded). Only if DESIGN.md doesn't record them, fall back to 390×844 /
  768×1024 / 1440×900 — and flag that init should be re-run to capture the user's real
  viewports. Never skip the mobile capture: no mobile screenshot means the loop cannot
  reach a PASA verdict (see the mobile gate below).
- Before any fullPage screenshot, scroll through the page in steps with short delays
  so on-scroll reveals (IntersectionObserver entrances) have fired — otherwise revealed
  content captures at opacity 0 and looks broken without being broken.
- Exercise the key interactions with Playwright (hover, focus, open menus, submit
  forms) and screenshot any state that looks off. Check the console for errors.

### 2. Judge
Look at the screenshots yourself — do not rely on scores alone. Evaluate against
DESIGN.md and PRODUCT.md: hierarchy, spacing rhythm, token fidelity, responsive
integrity, interaction states, accessibility findings from the audit.

**Mobile gate (blocking).** Judge the mobile capture with the same rigor as desktop:
single-column composition holds, background-photo cards keep their subject in frame,
text legible over every zone, no horizontal scroll, tap targets ≥44px. If there is no
mobile evidence, or the mobile composition is broken, the verdict is **ITERA — never
PASA**. "Se ve bien en desktop" is not a pass: a design is responsive-complete across
desktop AND mobile, or it iterates. This is the barrier that would have caught the
landing-crb cards collapsing to strips before the user did.

**One viewport height is not mobile evidence (blocking).** The mobile viewport is a range:
capture and judge at BOTH heights recorded in DESIGN.md — `alto útil / fold` (URL bar
expanded, what the user sees on landing) and `alto del dispositivo` (bar collapsed). For
each, measure the decisive elements against the fold with `getBoundingClientRect().bottom`
and report the numbers, plus the diff between the two states. An element that shifts when
the bar collapses is a finding. Evidence at a single height → **ITERA**, same as no mobile
evidence at all: a carousel approved on the numbers of one state shipped with its controls
jumping 107px in the other, and the user found it on their phone after the agent had
declared the verification good.

When presenting to the user, screenshots are reference only — their verdict happens on
the live URL in their own browser: run `open <url>` for them and print the URL on its
own line in a code block (never inline; terminal truncation corrupts copied URLs).

Verdict per iteration, reported to the user with the screenshots:
- **PASA** → go to step 4.
- **ITERA** → step 3.

### 3. Fix and re-enter
Write a concrete, prioritized fix list (finding → file → change). Apply the fixes.
Re-enter step 1. Never "fix" a finding by relaxing the rule that caught it.

If after 3 iterations it still fails: STOP. Report what is structurally wrong (usually
a phase-0 problem or the wrong direction: incoherent DESIGN.md, a reference that fights the brand) and recommend
which phase to revisit. Churning past 3 loops burns tokens without converging.

### 4. Ship gate
On PASA, run Impeccable's `/impeccable:polish` and `/impeccable:harden` as the final
gate, then summarize for the user: verdict, iterations used, final screenshots, and
anything deferred.
