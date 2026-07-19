# Seguimiento de mejoras — design-forge

Backlog central de mejoras del plugin **design-forge**, alimentado desde CUALQUIER
proyecto donde se use el plugin (canal de handoff cross-proyecto).

- **Cómo entra una mejora acá:** desde otra sesión, la skill personal
  `design-forge-mejora` detecta el gotcha, lo confirma con el usuario (modo Semi) y
  agrega una entrada bajo `## Pendientes`.
- **Cómo se procesan:** al abrir sesión en este repo, el hook `SessionStart`
  (`.claude/hooks/mejoras-detect.sh`) cuenta los pendientes y avisa. La skill
  `/revisar-mejoras` los recorre uno por uno, ayuda a implementarlos y los tilda.
- **Un pendiente es** un item `- [ ]`. **Hecho** = `- [x]` movido a `## Hechas`.

## Formato de cada entrada

```markdown
- [ ] **<título en imperativo>** · `origen: <proyecto>` · `<YYYY-MM-DD>`
  - **Contexto/gotcha:** qué pasó, por qué es fricción.
  - **Mejora propuesta:** qué debería hacer design-forge distinto.
  - **Impacto:** alto | medio | bajo
```

---

## Pendientes

- [ ] **Aislar y vigilar los worktrees de ideación (prevención)** · `origen: design-forge` · `2026-07-16`
  - **Contexto/gotcha:** la Fase 4 (teardown) ya limpia los worktrees `idea/*` sin
    perder trabajo, pero es CURATIVA — actúa cuando el residuo ya existe y quedó a la
    vista. Hoy los worktrees nacen como carpetas hermanas sueltas en `Proyectos/`
    (`<repo>-idea-*`), que ensucian la vista de proyectos, y nada avisa si una
    exploración quedó abierta y olvidada.
  - **Mejora propuesta:** parte preventiva, complementa al teardown: (1) que `ideate`
    cree los worktrees en `.worktrees/idea-*` (gitignored) dentro del repo en vez de
    carpetas hermanas — agrupados y fuera de la vista; (2) un aviso (hook o chequeo en
    `doctor`) que detecte worktrees `idea/*` viejos sin cerrar y sugiera
    `/design-forge:teardown`. Igual que el teardown cierra el ciclo, esto evita que se
    abra sin control.
  - **Impacto:** medio

- [ ] **Desarrollar mobile obligatoriamente en todo el pipeline (no solo desktop)** · `origen: landing-crb` · `2026-07-17`
  - **Contexto/gotcha:** el pipeline (ideate/build/critique) se centra en el viewport
    de referencia DESKTOP; el mobile queda opcional/manual y se cuelan bugs de
    responsive. Caso real en landing-crb: cards con foto de fondo que en desktop se
    ven bien, pero al colapsar a 1 columna en mobile se aplastan a tiras, recortan a
    los sujetos de la foto y el texto queda ilegible sobre zonas ocupadas. No hubo
    ninguna barrera del pipeline que lo detectara antes del usuario.
  - **Mejora propuesta:** mobile como ciudadano de primera clase: (1) `DESIGN.md`
    guarda un viewport MOBILE junto al desktop de referencia; (2) `ideate` genera y
    screenshotea cada dirección en desktop Y mobile por defecto; (3) `build` implementa
    el `@media` mobile como parte del entregable, no como afterthought; (4) `critique`
    FALLA si no hay evidencia (screenshot) mobile.
  - **Impacto:** alto

## Hechas

- [x] **Usar rama in-place por defecto; worktree solo bajo orden explícita** · `origen: landing-crb` · `2026-07-18` · `cerrada: 2026-07-18`
  - **Contexto/gotcha:** design-forge tiende a crear worktrees para aislar el trabajo,
    pero en proyectos con Docker/Vite montados sobre el directorio de trabajo (ej.
    green-school/landing-crb), el contenedor y el HMR watchean SOLO el checkout
    principal. Un worktree hermano NO es vigilado → se rompe el preview en vivo y hay
    que re-apuntar el mount o levantar un 2do stack. Fricción pura para un cambio chico.
  - **Hallazgo clave:** el `build` (fase 2) YA era in-place; los worktrees vivían SOLO
    en la fase 1 (ideate) para los mockups de variantes. Así que la política se aplicó
    ahí: el sustrato de ideación pasó a ser **in-place adaptativo**.
  - **Resolución:** nueva política **in-place por defecto, sin worktrees automáticos**.
    (1) `ideate` detecta el sustrato: con dev stack vivo (Docker/Vite/HMR) → rutas de
    preview temporales in-project (`/dev/<name>-preview`, gitignored) servidas por el
    stack real; sin stack → mockups HTML autocontenidos en `design/ideas/` (gitignored)
    + `http.server`. (2) Worktree SOLO bajo orden explícita (paralelismo real). (3) Los
    previews no elegidos son efímeros; `teardown` los archiva y limpia el área in-place
    (o los worktrees si el usuario los creó). Tocado: `commands/ideate.md`,
    `skills/pipeline/SKILL.md`, `commands/teardown.md`, `commands/doctor.md`,
    `README.md`, `docs/{referencia,casos-de-uso,que-es-y-por-que}.md`.
  - **Nota para la #3:** esto reduce la mejora "Aislar y vigilar worktrees de ideación"
    a solo su parte de vigilancia (aviso de worktrees explícitos viejos en `doctor`),
    porque el worktree ya no es el default.
  - **Impacto:** alto

- [x] **Limpiar worktrees al cerrar una exploración de ideas** · `origen: landing-crb` · `2026-07-16` · `cerrada: 2026-07-16`
  - **Contexto/gotcha:** design-forge crea un worktree hermano por cada idea de
    diseño (`landing-crb-idea-hero-split`, `-portada`, etc.), pero al terminar la
    exploración NO los destruía. Quedaron 6 carpetas residuales colgando en
    `Proyectos/`, todas apuntando al mismo commit base, con los mockups HTML
    **untracked** (nunca commiteados) adentro — trabajo invisible para git que se
    pierde si borrás la carpeta a mano.
  - **Resolución:** nueva **Fase 4 — Teardown** del pipeline. Comando
    `/design-forge:teardown` (`commands/teardown.md`) que archiva los mockups antes
    de borrar (regla de oro: nada untracked muere) y hace `worktree remove` +
    `branch -D` + `prune`. Enganchado en `ideate.md` (paso 10), `pipeline/SKILL.md`
    (fila fase 4) y `README.md`. Pendiente opcional NO hecho: nacer worktrees en
    `.worktrees/` gitignored + aviso de worktrees viejos (queda para otra iteración).
  - **Impacto:** alto

<!-- Al completar un pendiente, movelo acá con - [x] y la fecha de cierre. -->
