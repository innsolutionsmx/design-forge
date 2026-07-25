# Progreso actual — design-forge

> Source of truth de "dónde quedamos" en el desarrollo del plugin. Leelo primero al
> abrir sesión, actualizalo al cerrar cada batch. Sincroniza máquinas y compañeros
> vía git (engram es local de cada máquina y no viaja).

---

## Última actualización

- **Fecha**: 2026-07-25
- **Máquina**: Mac (oficina)
- **Rama actual**: `main` (post-release)
- **Última acción**: **RELEASE v0.5.0 a `main`**: cierra 4 mejoras del backlog —
  (#1) preview de FIDELIDAD obligatorio en diseño concreto (ya no se implementa directo
  sin preview; el preview cumple dos funciones, decidir Y verificar fidelidad);
  (#2) hook `UserPromptSubmit` BUNDLEADO en el plugin que recuerda ofrecer el preview
  cuando el prompt huele a decisión visual (sobrevive la compactación);
  (#4) hook `UserPromptSubmit` LOCAL al repo que recuerda invocar `design-forge-mejora`
  al capturar una mejora del plugin; (#3) preview de encuadre para assets en
  `object-cover` (abanico de `object-position`, screenshot del contenedor NO del `<img>`,
  desktop Y mobile). Backlog de mejoras VACÍO. Los proyectos con `autoUpdate` reciben
  0.5.0 en su próxima sesión.
  **Pendiente: VALIDAR en corrida real** — los hooks solo se probaron con payloads
  simulados; los previews no se corrieron en un ideate real todavía.

---

## Estado del plugin

- **Publicado en `main`**: v0.5.0 — pipeline 4 fases (init/ideate/build/review) +
  teardown, mobile first-class (hard rule 11), preview de fidelidad + preview de encuadre,
  2 hooks `UserPromptSubmit` (uno bundleado en el plugin, uno local al repo), doctrina de
  11 hard rules, Playwright MCP bundleado.
- **Proceso de release**: cambios en rama → merge a `dev` → promoción a `main` + bump
  de versión SOLO por decisión explícita del owner (main = lo que consumen los proyectos).

## Próximos pasos

- [ ] **Validar v0.5.0 en corrida real** — los 4 features nuevos se consideran cerrados
  recién tras validarse en un proyecto real (regla del doc de releases):
  - Hook #2 (bundleado): confirmar que el recordatorio de preview se inyecta en un
    proyecto CONSUMIDOR al mencionar trabajo visual (hasta ahora solo payloads simulados).
  - Hook #4 (local): confirmar que dispara en ESTE repo al asomar una mejora del plugin.
  - Preview de fidelidad (#1) y de encuadre (#3): validar en una corrida de `ideate` real
    (referencia concreta → fidelidad; foto en `object-cover` → abanico de encuadre).
- [ ] Segunda corrida real del pipeline en landing-crb → nuevos gotchas al backlog vía
  la skill `design-forge-mejora` (ahora amarrada por el hook #4).
