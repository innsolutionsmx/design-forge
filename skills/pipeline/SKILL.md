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
| 0. Context | Establish brand truth before any pixel | `impeccable init`, SkillUI (`skillui --url`), existing internal docs, awesome-design-md | `PRODUCT.md`, `DESIGN.md` (committed) with asset inventory + reference viewport |
| 1. Ideation | Explore 2–3 directions cheaply | in-place preview routes (live dev stack) or self-contained HTML mockups in a gitignored subdir, Stitch skills, font pairing — no worktrees by default | chosen direction, updated `DESIGN.md`, ephemeral preview area |
| 2. Build | Implement against DESIGN.md | code, 21st.dev components, webgpu-claude-skill | working UI |
| 3. Critique loop | Evidence-based pass/iterate decision | impeccable `/critique` + `/audit`, Playwright MCP screenshots | verdict + fix list, or ship after `/polish` + `/harden` |
| 4. Teardown | Close the exploration without leaving residue | `/design-forge:teardown` — archive mockups, `git worktree remove` + `branch -D` + `prune` | idea worktrees archived and removed, tree clean |

## Canonical workflow (section-level changes)

The pipeline's default operating mode is **surgical, per-section iteration** — not
full-site redesigns:

1. The user brings an idea about a concrete section.
2. Baseline screenshot of the real section (the "before"). Ideating something that has
   no baseline requires telling the user there will be nothing to compare against.
3. Variants built **in-place, never in an auto-created worktree** — as temporary preview
   routes inside the running dev stack when one is mounted (Docker/Vite/HMR), or as
   self-contained HTML mockups in a gitignored subdir (`design/ideas/`) referencing real
   repo assets by relative path when there's no live stack. Always include one fresh
   direction beyond the literal ask. Worktrees only on explicit user request.
4. Compose the comparative preview sheet (explicit format per hard rule 9, each
   variant in its real contexts, frames at real target width), show it as soon as
   it's ready + open the live URL in the user's browser (`open <url>`; URLs also
   printed on their own line in a code block — never inline, terminal truncation
   corrupts them).
5. Iterate v2, v3… on user feedback.
6. Only on "esta es": implement in the real project (Blade/CSS/components, `feat/*`
   branch). Non-winning previews are ephemeral — they live in the gitignored preview
   area, not as permanent inventory.
7. When the exploration is over (winner landed, runner-ups no longer needed), run
   `/design-forge:teardown` to archive the mockups and remove the gitignored preview
   area (or any worktrees the user explicitly created). Ideation opens the scaffold;
   teardown takes it down.

## Hard rules

1. **DESIGN.md is law.** Never invent colors, fonts, spacing, or radii inline. If DESIGN.md
   doesn't exist yet, you are in phase 0 — go create it before writing UI code.
2. **One design brain.** Impeccable is the only critique/taste authority in this pipeline.
   Do not load or follow UI/UX Pro Max, Taste, or frontend-design guidance in parallel.
3. **Evidence over opinion — on the user's screen.** A design is never "done" because
   the code looks right. Screenshots are taken at the reference viewport recorded in
   DESIGN.md (never generic defaults) and are reference material; the user's verdict
   happens on the live URL in their own browser. Agent screen ≠ user screen.
4. **The loop is bounded.** review → fix → review, maximum 3 iterations. If it still
   fails after 3, stop and report to the user what is structurally wrong — don't churn.
5. **Effects earn their place.** WebGPU/shaders/heavy motion only for hero moments,
   ambient backgrounds, or explicit user requests — never as default decoration.
   Always with a reduced-motion and no-WebGPU fallback.
6. **Components before custom.** Prefer pulling a production component (21st.dev,
   shadcn) and restyling it to DESIGN.md over hand-building from scratch.
7. **The repo is not the brand truth.** Real brand assets (mascot, logos, photography)
   may live outside the repo. Trust DESIGN.md's asset inventory and its "asset
   pendiente" list — never assume a placeholder found in code is the real identity.
8. **Vertical budget from v1.** Designs fit the primary reference viewport
   intentionally and never depend on an exact height — fold-crossing elements must
   look deliberate; use fluid spacing (`clamp()`, `100svh`).
9. **Never a bare render.** Any design options shown to the user use the explicit
   comparative format: case badge (A/B/C) + title + status chip (`Recomendado` /
   `Variación fresca` / `Riesgo`) + 1–2 line description with the tradeoff + frames
   with context captions and a legible/ilegible badge. And always include at least
   one fresh direction of your own beyond the literal ask — if the user brought a
   CONCRETE design to implement, skip variations entirely and build it.
10. **The preview must not lie.** Verify every render visually before showing it —
   CSS specificity can leave text invisible while the CSS "looks right" (`.nav-links a`
   at (0,2,1) beats `.nav-cta` at (0,2,0); write `a.nav-cta`). Render frames at the
   real target width, never narrow columns (narrow crops fake overflows).

## Proven practices (keep doing these)

- Self-contained mockups with real token values copied from DESIGN.md — high fidelity,
  zero risk to the project.
- Real repo assets referenced by relative path. With a live dev stack the running
  server already resolves them; with the static substrate serve the subdir over HTTP
  (Playwright MCP blocks `file://`, e.g. `python3 -m http.server 8899`).
- 3 directions with name + thesis + tradeoff — fast user decisions.
- Progressive screenshots: show each variant the moment it's ready, don't batch.
- Scroll through the page (stepped, with delays) before any fullPage screenshot so
  on-scroll reveals have fired.

## Anti-patterns

- Writing UI code before PRODUCT.md/DESIGN.md exist (or leaving them uncommitted —
  worktrees only carry committed files).
- Screenshotting only desktop and declaring responsive victory.
- Running critique on code instead of on the rendered page.
- "Fixing" a critique finding by lowering the bar (removing the rule) instead of the UI.
- Auto-creating a git worktree to isolate ideation — in a project with a mounted dev
  stack (Docker/Vite) the worktree is invisible to HMR and breaks the live preview.
  Variants live in-place (separate routes/files); worktrees only on explicit request.
- Deleting non-winning previews mid-decision — they're ephemeral but the user may still
  be A/B-ing; tear them down via `/design-forge:teardown` once the winner lands.
