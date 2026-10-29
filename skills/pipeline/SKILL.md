---
name: design-pipeline
description: Doctrine for the design-forge frontend pipeline. Use when working on any frontend design or UI task in a project that has design-forge installed — replicating a reference design, building components, styling, reviewing UI, or deciding which design tool to use at which phase.
---

# design-forge pipeline doctrine (1.0.0)

## Phase map

| Phase | Command | Goal | Tools | Output |
|-------|---------|------|-------|--------|
| 0. Context | `/design-forge:init` | Brand truth before any pixel | Impeccable init, SkillUI, internal docs | `PRODUCT.md`, `DESIGN.md` (committed): tokens, assets, viewports |
| 1. Replicate (main flow) | `/design-forge:replicate` | A reference design, 1:1, with the project's assets | Playwright MCP, SkillUI (with a URL), one verifier subagent | the section built in the project + verified fidelity preview |
| 1b. Build | `/design-forge:build` | UI with no reference to copy | code in the project's stack | working UI |
| 2. Review (on request) | `/design-forge:review` | Evidence-based pass/iterate by the design brain | Impeccable critique/audit/polish/harden, Playwright MCP | verdict + fixes |

## Canonical workflow

1. The user shares a screenshot (and maybe the URL) of a design they found.
2. `replicate`: asset map → build 1:1 in the project → preview sheet (reference next to
   result, desktop + both mobile heights + transition frame) → one adversarial verifier →
   show on the live URL → iterate.
3. On approval, ASK whether to run `review`. Then update DESIGN.md and delete the preview
   area.

## Hard rules

1. **DESIGN.md is law.** Never invent colors, fonts, spacing, or radii inline. No
   DESIGN.md yet → you are in phase 0.
2. **Never use the reference's assets.** A reference screenshot or URL is someone else's
   site: never crop, copy, trace, hotlink or embed its photos, logos, icons, illustrations
   or mockups. Map each one to a project asset (DESIGN.md inventory, repo) or a neutral
   placeholder marked `pendiente`.
3. **1:1 means 1:1.** Layout, proportions, spacing rhythm, type scale, hierarchy and effects
   come from the reference; colors and font families from DESIGN.md unless the user asks to
   copy them. Divergences are reported, never silent.
4. **One design brain.** Impeccable is the only critique/taste authority. Do not load UI/UX
   Pro Max, Taste, or frontend-design guidance in parallel.
5. **No implementation without a preview.** Every visual change ends in a preview the user
   judges on the live URL in their own browser (`open <url>`, URL alone in a code block).
   With a reference, the preview is reference vs result; screenshots are the agent's
   reference material, not the user's verdict.
6. **The preview must not lie.** Before showing it, ONE read-only subagent verifies it with
   an adversarial prior ("assume it's broken"): true viewport (device emulation;
   `clientWidth` equals the target width), header in its rest state, overflow gate
   (`scrollWidth > clientWidth` — the gate beats the eye), fold measured in numbers,
   fidelity and hierarchy vs the reference, assets from the project. It returns text only;
   the screenshots never enter the orchestrator. Every round is logged in
   `design/verificaciones.md`.
7. **Mobile is first-class, and a range.** DESIGN.md records desktop and mobile, mobile at
   both heights: `alto útil / fold` (URL bar expanded) and `alto del dispositivo`
   (collapsed). Every visual check renders desktop AND both mobile states; the vertical
   budget is the `alto útil`, never the device height. No mobile evidence, or evidence at a
   single height → not done.
8. **Review runs only on a yes.** `replicate` and `build` ask before `/design-forge:review`.
   Once running, it's bounded: max 3 iterations, then report what's structurally wrong.
9. **Captures have a home.** `mkdir -p design/preview/captures` before the first capture,
   full path in every Playwright `filename`; `design/preview/` and `.playwright-mcp/` are
   gitignored. Runs leave no residue: the preview area is deleted at the end, no archives.
10. **Libraries are inspiration, not dependencies.** Build in the project's stack; show
    sources for borrowed patterns ("encontré este carrusel en <url>"). Reuse a component
    library only if the project already depends on it.
11. **The repo is not the brand truth, and effects earn their place.** Trust DESIGN.md's
    asset inventory over placeholders found in code. WebGPU/shaders/heavy motion only for
    hero moments or explicit requests, always with reduced-motion and fallback.

## Proven practices

- CSS specificity: `a.nav-cta`, not `.nav-cta` — `.nav-links a` (0,2,1) beats (0,2,0) and
  leaves text invisible.
- Photos in `object-cover`: render a fan of `object-position` on the real container,
  desktop and mobile, and let the user pick.
- Scroll in steps with short delays before any fullPage capture so reveals have fired.
- With HMR running, `navigate` → `wait_for` → `evaluate` without an internal delay; a
  reload mid-`evaluate` destroys the execution context.
- An intermittent element: rule out the instrument before blaming the site.

## Anti-patterns

- Writing UI code before PRODUCT.md/DESIGN.md exist.
- Using, cropping or hotlinking the reference's images "for now".
- Screenshotting only desktop and declaring responsive victory.
- Showing a preview that hasn't passed verification.
- Running review without asking, or "fixing" a finding by relaxing the rule that caught it.
- Archiving run artifacts in the repo; learnings go to memory.
