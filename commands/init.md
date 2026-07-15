---
description: "Fase 0 — Contexto: establece PRODUCT.md y DESIGN.md antes de tocar un pixel"
argument-hint: "[url-de-marca-del-cliente]"
---

You are running phase 0 (Context) of the design-forge pipeline. Goal: produce
`PRODUCT.md` and `DESIGN.md` at the repo root. Every later phase reads these files.

## Steps

1. If `PRODUCT.md` and `DESIGN.md` already exist, show a short summary of each and ask
   the user whether to keep, regenerate, or refine them. Do not silently overwrite.

2. Determine the brand source:
   - If the user passed a URL as argument ($ARGUMENTS), that's the client's existing brand.
   - Before asking anything, scan the repo for existing internal design docs:
     `design-system*.md`, `DESIGN*.md`, `ia/context/design-system.md`, `docs/design*`,
     tailwind config with custom tokens, CSS custom properties files. If found, offer
     the **existing docs path** first.
   - Otherwise ask: "¿Partimos de una marca existente (URL), de docs internos del repo,
     o definimos el diseño desde cero?"

2b. **Existing internal docs path:**
   - Read the found docs and token sources. Consolidate them into `DESIGN.md` at repo
     root in the pipeline's format (tokens, type scale, spacing, radii, shadows, motion,
     voice, anti-references). Reference the original files as the source of truth and
     note any gaps the docs don't cover (ask the user only about those).
   - Do NOT invent tokens that contradict the existing system — this path is
     consolidation, not redesign.

3. **Existing brand (URL path):**
   - Check SkillUI is installed (`which skillui`). If missing, tell the user to run
     `npm i -g skillui` (and for ultra mode: `npm i playwright && npx playwright install chromium`).
   - Run `skillui --url <URL> --mode ultra` (fall back to default mode if ultra fails).
   - Review the extracted output (tokens, typography, spacing, screenshots). Merge it into
     a `DESIGN.md` at repo root: exact color tokens, type scale, spacing grid, radii,
     shadows, motion notes, and anti-references (what the brand must NOT look like).

4. **From scratch path:**
   - Run Impeccable's init (`/impeccable:init` if installed as plugin, otherwise the
     `impeccable` skill's init flow). It interviews for audience, brand voice, colors,
     typography and writes PRODUCT.md and DESIGN.md.
   - Optionally offer the user a starting point from awesome-design-md
     (https://github.com/VoltAgent/awesome-design-md) if they name a reference brand
     ("estilo Linear", "estilo Stripe") — fetch that DESIGN.md as base, then adapt it.

5. Ensure `PRODUCT.md` exists too (audience, jobs-to-be-done, tone). If Impeccable
   didn't create it (URL path), write it from a short interview with the user.

6. **Brand asset inventory** (the repo is NOT the source of truth for the brand):
   scan for logo, mascot, and key photography, list each in DESIGN.md with its path —
   and then ASK the user whether that inventory is complete. Real brand assets often
   live outside the repo (other machines, unpushed branches, Downloads). Anything the
   user names but can't provide yet goes into DESIGN.md as **"asset pendiente"**, so
   no later phase assumes what's in the code is the full identity.

7. **Reference viewport**: ask the user for their real working viewport (screen minus
   browser chrome — e.g. 1440×820 on a MacBook 13"), plus a mobile size and an optional
   spot-check size. Record them in DESIGN.md. Every screenshot in later phases uses
   these — not generic defaults.

8. Close by committing `PRODUCT.md` and `DESIGN.md` (git worktrees only carry committed
   files, and phase 1 depends on that), then print a compact summary of the design
   system (palette, fonts, spacing, voice, assets, viewport) and the next step:
   `/design-forge:ideate`.

If Impeccable is not installed at all, stop and direct the user to `/design-forge:doctor`.
