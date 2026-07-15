# Progreso actual — design-forge

> Source of truth de "dónde quedamos" en el desarrollo del plugin. Leelo primero al
> abrir sesión, actualizalo al cerrar cada batch. Sincroniza máquinas y compañeros
> vía git (engram es local de cada máquina y no viaja).

---

## Última actualización

- **Fecha**: 2026-07-15
- **Máquina**: Mac (oficina)
- **Rama actual**: `dev`
- **Última acción**: Dogfood — el repo instala inns-ai-flow (gitflow + guardias),
  rama `dev` creada.

---

## Estado del plugin

- **Publicado en `main`**: v0.2.0 — pipeline 4 fases (init/ideate/build/review +
  doctor), doctrina, Playwright MCP bundleado, 10 gotchas de la primera corrida real
  aplicados, SETUP.md para agentes.
- **Proceso de release**: cambios en rama → merge a `dev` → promoción a `main` + bump
  de versión SOLO por decisión explícita de Pepe (main = lo que consumen los proyectos).

## Próximos pasos

- [ ] **Feature "Preview comparativo explícito"** (handoff de landing-crb 2026-07-15,
  rediseño navbar): ante pedido de diseño sin diseño concreto, generar preview con
  ≥2 variaciones (siempre una "fresca" propia), formato explícito obligatorio
  (badge + título + chip de estado + descripción + captions de contexto), cada
  variación en sus contextos reales, render al ancho real del target, fallback
  Chrome headless sin Playwright. Plan de implementación pendiente de aprobación.
- [ ] Segunda corrida real del pipeline en landing-crb → nuevos gotchas.
