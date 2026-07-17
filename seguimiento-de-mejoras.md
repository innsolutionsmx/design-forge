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

- [ ] **Limpiar worktrees al cerrar una exploración de ideas** · `origen: landing-crb` · `2026-07-16`
  - **Contexto/gotcha:** design-forge crea un worktree hermano por cada idea de
    diseño (`landing-crb-idea-hero-split`, `-portada`, etc.), pero al terminar la
    exploración NO los destruye. Quedaron 6 carpetas residuales colgando en
    `Proyectos/`, todas apuntando al mismo commit base, con los mockups HTML
    **untracked** (nunca commiteados) adentro — trabajo invisible para git que se
    pierde si borrás la carpeta a mano.
  - **Mejora propuesta:** que el flujo de exploración tenga una **compuerta de
    cierre** (comando `/forge teardown` o similar) que: (1) archive los mockups en
    una rama `archive/design-ideas` para que no queden untracked, (2) haga
    `git worktree remove` + `branch -D` de las ideas descartadas, (3) corra
    `git worktree prune`. Opcional: nacer los worktrees en `.worktrees/` gitignored
    en vez de carpetas hermanas sueltas, y un aviso al detectar worktrees `idea/*`
    viejos sin cerrar.
  - **Impacto:** alto

## Hechas

<!-- Al completar un pendiente, movelo acá con - [x] y la fecha de cierre. -->
