# Progreso actual — design-forge

> Source of truth de "dónde quedamos" en el desarrollo del plugin. Leelo primero al
> abrir sesión, actualizalo al cerrar cada batch. Sincroniza máquinas y compañeros
> vía git (engram es local de cada máquina y no viaja).

---

## Última actualización

- **Fecha**: 2026-07-15
- **Máquina**: Mac (oficina)
- **Rama actual**: `dev`
- **Última acción**: Documentación completa (`docs/`: qué-es-y-por-qué, casos de uso,
  referencia, actualización, desarrollo-y-releases) + `autoUpdate: true` en settings
  propios y ejemplos del SETUP + fallback de instalación documentado. En `dev` junto
  con la feature de preview comparativo, pendiente de release.

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
- [ ] Validar la feature en la próxima corrida real en landing-crb (CA1–CA5 del
  handoff como checklist).
- [ ] Segunda corrida real del pipeline en landing-crb → nuevos gotchas.
