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
   - Otherwise ask: "¿Partimos de una marca existente (URL) o definimos el diseño desde cero?"

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

6. Close by printing a compact summary of the design system (palette, fonts, spacing,
   voice) and the next step: `/design-forge:ideate`.

If Impeccable is not installed at all, stop and direct the user to `/design-forge:doctor`.
