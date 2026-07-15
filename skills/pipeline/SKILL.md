---
name: design-pipeline
description: Doctrine for the design-forge frontend pipeline. Use when working on any frontend design or UI task in a project that has design-forge installed — building components, styling, reviewing UI, or deciding which design tool to use at which phase.
---

# design-forge pipeline doctrine

design-forge structures frontend work into 4 phases. Know which phase you are in and
use only the tools that belong to it.

## Phase map

| Phase | Goal | Tools | Output |
|-------|------|-------|--------|
| 0. Context | Establish brand truth before any pixel | `impeccable init`, SkillUI (`skillui --url`), awesome-design-md | `PRODUCT.md`, `DESIGN.md` at repo root |
| 1. Ideation | Explore 2–3 directions cheaply | Stitch skills, font pairing, git worktrees | chosen direction, updated `DESIGN.md` |
| 2. Build | Implement against DESIGN.md | code, 21st.dev components, webgpu-claude-skill | working UI |
| 3. Critique loop | Evidence-based pass/iterate decision | impeccable `/critique` + `/audit`, Playwright MCP screenshots | verdict + fix list, or ship after `/polish` + `/harden` |

## Hard rules

1. **DESIGN.md is law.** Never invent colors, fonts, spacing, or radii inline. If DESIGN.md
   doesn't exist yet, you are in phase 0 — go create it before writing UI code.
2. **One design brain.** Impeccable is the only critique/taste authority in this pipeline.
   Do not load or follow UI/UX Pro Max, Taste, or frontend-design guidance in parallel.
3. **Evidence over opinion.** A design is never "done" because the code looks right.
   It passes when impeccable critique/audit scores it AND real Playwright screenshots
   (mobile 375px, tablet 768px, desktop 1440px) confirm it.
4. **The loop is bounded.** review → fix → review, maximum 3 iterations. If it still
   fails after 3, stop and report to the user what is structurally wrong — don't churn.
5. **Effects earn their place.** WebGPU/shaders/heavy motion only for hero moments,
   ambient backgrounds, or explicit user requests — never as default decoration.
   Always with a reduced-motion and no-WebGPU fallback.
6. **Components before custom.** Prefer pulling a production component (21st.dev,
   shadcn) and restyling it to DESIGN.md over hand-building from scratch.

## Anti-patterns

- Writing UI code before PRODUCT.md/DESIGN.md exist.
- Screenshotting only desktop and declaring responsive victory.
- Running critique on code instead of on the rendered page.
- "Fixing" a critique finding by lowering the bar (removing the rule) instead of the UI.
- Adding a second variant inside the same branch — variants live in worktrees.
