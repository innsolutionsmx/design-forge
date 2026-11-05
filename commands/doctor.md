---
description: "Verifica los prerequisitos del pipeline design-forge y dice qué falta"
---

**design-forge 1.0.0 · doctor.** State this line, verbatim, in your first message to the
user — it proves which version of this command is actually loaded.

Check every design-forge prerequisite and report a status table. Do not install
anything without asking — diagnose first.

## Checks

1. **Impeccable** (required): look for the `impeccable` npm package
   (`npm ls -g impeccable` / `npx impeccable --version`), a `.impeccable/` directory,
   or its commands in `.claude/`. Fix: `npx impeccable install`.
2. **Playwright MCP** (bundled with this plugin): verify the `playwright` MCP server
   is connected (`claude mcp list` output or attempt a ToolSearch for playwright tools).
   Fix: reinstall/re-enable the design-forge plugin.
3. **Static HTTP server** (needed when there's no live dev stack): the Playwright MCP
   blocks `file://`, so `replicate` serves the repo over HTTP to render its preview sheet.
   With a live dev stack the running server renders previews itself — this becomes
   optional. Check `python3 --version` or that `npx serve` is
   available. Fix: install Python 3 or Node (either works). The bundled preview hook needs
   one of `jq`, `python3` or `node` to read prompts — with none of them it stays silent.
3b. **Render fallback (Chrome headless)**: when the Playwright MCP is unavailable,
   previews render via `chrome --headless=new --screenshot=out.png --window-size=W,H <url>`.
   Check a Chrome/Chromium binary exists (macOS:
   `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`; Linux:
   `which google-chrome chromium`). Warn-only if missing while Playwright MCP is
   connected; error if BOTH are missing (no preview can render at all).
4. **SkillUI** (optional — extracts exact tokens and motion from a brand URL in `init` or
   a reference URL in `replicate`): `which skillui`.
   Fix: `npm i -g skillui` (+ `npx playwright install chromium` for ultra mode).
5. **webgpu-claude-skill** (optional — shaders): check `.claude/skills/` for
   `webgpu-threejs-tsl`. Fix: copy the skill from https://github.com/dgreenheck/webgpu-claude-skill.
6. **Project context**: do `PRODUCT.md` and `DESIGN.md` exist at repo root, committed,
   and does DESIGN.md record the reference viewports (desktop AND mobile — mobile is
   mandatory) and brand asset inventory? If the mobile viewport is missing, ⚠️ and send
   the user to re-run `/design-forge:init`. If PRODUCT/DESIGN don't exist at all, first
   step is `/design-forge:init`.
6b. **Mobile viewport recorded as a RANGE**: DESIGN.md must record BOTH mobile heights —
   `alto útil / fold` (URL bar expanded) and `alto del dispositivo` (collapsed). Only one
   height → ⚠️ with the consequence spelled out: every later phase will render at one end
   and call it mobile, which lets content that "fits" the device fall below the real fold.
   Fix: re-run `/design-forge:init` (step 7a), measuring `window.innerHeight` on the real
   phone. If the useful height is recorded as `estimado` (derived from the ~87.5% default
   instead of measured), ⚠️ softly — usable, but the number was never confirmed.
6c. **Clone up to date**: `git fetch origin` then
   `git rev-list --count HEAD..origin/main`. If there are unpulled commits, ⚠️ with
   the count — a stale clone produces false baselines in `replicate` (especially on
   multi-machine setups). Fix: sync before replicating.
7. **Conflict check** (important): detect competing design brains — UI/UX Pro Max
   (`design-system/MASTER.md` or `uipro` CLI), taste-skill, or Anthropic's
   frontend-design skill active in this project. If found, WARN: design-forge assumes
   Impeccable as the single design authority; running two brains produces
   contradictory guidance. Recommend disabling the extras for this project.
8. **Preview hygiene**: `design/preview/` and `.playwright-mcp/` listed in `.gitignore`,
   and no loose `*.png` captures in the repo root (`git status --porcelain`). Leftovers
   mean a run didn't clean up — ⚠️ with the paths. Warning only, never an error.

## Output

A table: herramienta | estado (✅/⚠️/❌) | rol | cómo arreglarlo. End with the single
most important next action.
