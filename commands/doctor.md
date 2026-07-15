---
description: "Verifica los prerequisitos del pipeline design-forge y dice qué falta"
---

Check every design-forge prerequisite and report a status table. Do not install
anything without asking — diagnose first.

## Checks

1. **Impeccable** (required): look for the `impeccable` npm package
   (`npm ls -g impeccable` / `npx impeccable --version`), a `.impeccable/` directory,
   or its commands in `.claude/`. Fix: `npx impeccable install`.
2. **Playwright MCP** (bundled with this plugin): verify the `playwright` MCP server
   is connected (`claude mcp list` output or attempt a ToolSearch for playwright tools).
   Fix: reinstall/re-enable the design-forge plugin.
3. **Static HTTP server** (required for mockups): the Playwright MCP blocks `file://`,
   so phase 1 serves mockup worktrees over HTTP. Check `python3 --version` or that
   `npx serve` is available. Fix: install Python 3 or Node (either works).
4. **SkillUI** (optional — client branding extraction): `which skillui`.
   Fix: `npm i -g skillui` (+ `npx playwright install chromium` for ultra mode).
5. **Stitch skills** (optional — ideation concepts): check for the stitch-design
   plugin/skills. Fix: `npx plugins add google-labs-code/stitch-skills --scope project --target claude-code`.
6. **21st.dev Magic MCP** (optional — production components): check for a 21st.dev MCP
   entry. Fix: `npx @21st-dev/cli@latest install claude --api-key <KEY>` (key from 21st.dev console).
7. **webgpu-claude-skill** (optional — shaders): check `.claude/skills/` for
   `webgpu-threejs-tsl`. Fix: copy the skill from https://github.com/dgreenheck/webgpu-claude-skill.
8. **Project context**: do `PRODUCT.md` and `DESIGN.md` exist at repo root, committed,
   and does DESIGN.md record the reference viewport and brand asset inventory?
   If not, first step is `/design-forge:init`.
9. **Conflict check** (important): detect competing design brains — UI/UX Pro Max
   (`design-system/MASTER.md` or `uipro` CLI), taste-skill, or Anthropic's
   frontend-design skill active in this project. If found, WARN: design-forge assumes
   Impeccable as the single design authority; running two brains produces
   contradictory guidance. Recommend disabling the extras for this project.

## Output

A table: herramienta | estado (✅/⚠️/❌) | rol | cómo arreglarlo. End with the single
most important next action.
