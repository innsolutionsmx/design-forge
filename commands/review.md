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
- With the Playwright MCP, screenshot the target page at three viewports:
  375×812 (mobile), 768×1024 (tablet), 1440×900 (desktop).
- Exercise the key interactions with Playwright (hover, focus, open menus, submit
  forms) and screenshot any state that looks off. Check the console for errors.

### 2. Judge
Look at the screenshots yourself — do not rely on scores alone. Evaluate against
DESIGN.md and PRODUCT.md: hierarchy, spacing rhythm, token fidelity, responsive
integrity, interaction states, accessibility findings from the audit.

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
