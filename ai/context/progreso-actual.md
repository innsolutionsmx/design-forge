# Progreso actual — design-forge

> Source of truth de "dónde quedamos" en el desarrollo del plugin. Leelo primero al
> abrir sesión, actualizalo al cerrar cada batch. Sincroniza máquinas y compañeros
> vía git (engram es local de cada máquina y no viaja).

---

## Última actualización

- **Fecha**: 2026-07-15
- **Máquina**: Mac (oficina)
- **Rama actual**: `dev`
- **Última acción**: **RELEASE v0.3.0 a `main`** (aprobada por Pepe): preview
  comparativo explícito (RF1–RF7 del handoff navbar), gotcha #10 (sync check antes
  de idear), docs/ completos, autoUpdate en settings/ejemplos, dogfood de
  inns-ai-flow. Los proyectos con autoUpdate la reciben en su próxima sesión.
  Pendiente: validar preview con CA1–CA5 en la próxima corrida real.

---

## Estado del plugin

- **Publicado en `main`**: v0.2.0 — pipeline 4 fases (init/ideate/build/review +
  doctor), doctrina, Playwright MCP bundleado, 10 gotchas de la primera corrida real
  aplicados, SETUP.md para agentes.
- **Proceso de release**: cambios en rama → merge a `dev` → promoción a `main` + bump
  de versión SOLO por decisión explícita de Pepe (main = lo que consumen los proyectos).

## Próximos pasos

- [x] **Feature "Preview comparativo explícito"** — implementada en `dev`
  (rama `feat/preview-comparativo`, handoff de landing-crb 2026-07-15). Cubre
  RF1–RF7: router diseño-concreto vs preview, sheet comparativo con formato
  explícito obligatorio, variación fresca obligatoria, contextos reales (init 7b
  los inventaría en DESIGN.md), render al ancho real, fallback Chrome headless
  (doctor 3b), disciplina de especificidad CSS + verificación visual del render.
  **Pendiente: decisión de Pepe para promover a `main` + bump a v0.3.0 (release).**
- [x] **Gotcha #10 (upstream sync)** — implementado en `dev`: ideate Step 0a se niega
  a tomar baseline con clone desactualizado (git fetch + rev-list count); doctor 8b
  reporta commits sin bajar. Cierra el cruce completo contra
  landing-crb/design/design-forge-gotchas.md (gotchas 1–11 + F1–F7 ✅).
- [ ] Validar la feature en la próxima corrida real en landing-crb (CA1–CA5 del
  handoff como checklist).
- [ ] Segunda corrida real del pipeline en landing-crb → nuevos gotchas.
