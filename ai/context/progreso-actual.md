# Progreso actual — design-forge

> Source of truth de "dónde quedamos" en el desarrollo del plugin. Leelo primero al
> abrir sesión, actualizalo al cerrar cada batch. Sincroniza máquinas y compañeros
> vía git (engram es local de cada máquina y no viaja).

---

## Última actualización

- **Fecha**: 2026-07-26
- **Máquina**: Mac (oficina)
- **Rama actual**: `main` (post-release)
- **Última acción**: **RELEASE v0.6.0 a `main`**: contrato ENDURECIDO del paso 7 de
  `ideate`. La verificación visual del preview se **DELEGA a un subagente** que devuelve
  veredicto en TEXTO (screenshots cuarentenados fuera del contexto del orquestador — ahorro
  de tokens), con 3 capas: (1) **gate determinístico** de overflow (`scrollWidth>clientWidth`)
  que gana sobre el ojo; (2) **pase adversarial** de refutación en todo `go`; (3) **harness
  mobile confiable** (el fallback headless `--window-size` clampea `innerWidth` a ~500 y
  recorta el screenshot → clips falsos; preferir Playwright o iframe de ancho forzado).
  Sincronizado en `commands/ideate.md` (paso 7 en a/b/c) + hard rule 10 de
  `SKILL.md`/`referencia.md`. Los proyectos con `autoUpdate` reciben 0.6.0 en su próxima sesión.
  **VALIDADO en corrida real** (rediseño split de "Nosotros" de landing-crb): destapó que el
  "overflow mobile" que perseguíamos era un **artefacto del harness**, no un bug de CSS — el
  gate determinístico fue el único actor que acertó (los verificadores visuales alucinaron).
  El diseño quedó validado en scratchpad pero **NO portado a landing-crb** todavía.

---

## Estado del plugin

- **Publicado en `main`**: v0.6.0 — pipeline 4 fases (init/ideate/build/review) +
  teardown, mobile first-class (hard rule 11), preview de fidelidad + preview de encuadre,
  **verificación del paso 7 DELEGADA a subagente endurecido** (gate determinístico + pase
  adversarial + harness mobile confiable), 2 hooks `UserPromptSubmit` (uno bundleado, uno
  local al repo), doctrina de 11 hard rules, Playwright MCP bundleado.
- **Proceso de release**: cambios en rama → merge a `dev` → promoción a `main` + bump
  de versión SOLO por decisión explícita del owner (main = lo que consumen los proyectos).

## Próximos pasos

- [ ] **Portar el rediseño split de "Nosotros" a landing-crb** (validado en scratchpad en
  v0.6.0, aún NO portado): componente Blade honrando Tailwind v4 + DaisyUI, copiar
  `img/1.jpg,2.png,3.JPG`, encuadre carrera de colores `object-position: 30% center`.
  **DECISIÓN ABIERTA**: ¿reemplaza el hero actual de `nosotros.blade.php` o va como sección
  nueva?
- [ ] **Validar los hooks en un proyecto CONSUMIDOR** (pendiente de v0.5.0): hook #2
  (bundleado) — que el recordatorio de preview se inyecte al mencionar trabajo visual;
  hook #4 (local) — que dispare en ESTE repo al asomar una mejora. (El paso 7 y los
  previews de fidelidad/encuadre YA se validaron en corrida real en v0.6.0.)
- [ ] Seguir dogfooding en landing-crb → nuevos gotchas al backlog vía `design-forge-mejora`.
