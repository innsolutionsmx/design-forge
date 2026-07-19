---
description: "Fase 3 — Loop de crítica: impeccable critique/audit + screenshots Playwright, decide pasa o itera"
argument-hint: "[url-local ej. http://localhost:3000]"
---

You are running phase 3 (Critique loop) of the design-forge pipeline. This is the heart
of the harness: an evidence-based pass/iterate decision, bounded at 3 iterations.

## Preconditions

- `DESIGN.md` exists (it's the rubric everything is judged against).
- A dev server is running or startable. Target URL from $ARGUMENTS, or detect it
  (package.json scripts) and start it yourself.
- Impeccable installed (if not → `/design-forge:doctor`).

## The loop (max 3 iterations)

### 1. Gather evidence
- Run Impeccable's critique (`/impeccable:critique`) and audit (`/impeccable:audit`)
  against the running page. Capture scores and findings.
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
a phase-0 or phase-1 problem: wrong direction, incoherent DESIGN.md) and recommend
which phase to revisit. Churning past 3 loops burns tokens without converging.

### 4. Ship gate
On PASA, run Impeccable's `/impeccable:polish` and `/impeccable:harden` as the final
gate, then summarize for the user: verdict, iterations used, final screenshots, and
anything deferred.
