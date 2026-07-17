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

## Hechas

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
