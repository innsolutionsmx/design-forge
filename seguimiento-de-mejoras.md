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

## Hechas

- [x] **Aislar y vigilar los worktrees de ideación (prevención)** · `origen: design-forge` · `2026-07-16` · `cerrada: 2026-07-19`
  - **Contexto/gotcha:** la Fase 4 (teardown) ya limpia los worktrees `idea/*` sin
    perder trabajo, pero es CURATIVA — actúa cuando el residuo ya existe y quedó a la
    vista. Hoy los worktrees nacen como carpetas hermanas sueltas en `Proyectos/`
    (`<repo>-idea-*`), que ensucian la vista de proyectos, y nada avisa si una
    exploración quedó abierta y olvidada.
  - **Alcance reducido por la #2:** la mejora "in-place por defecto" sacó el worktree del
    default, así que la parte (1) dejó de ser "el default ensucia todo" y quedó como
    higiene del caso EXCEPCIONAL (worktree explícito). Se implementó el remanente real:
  - **Resolución:** (1) cuando el usuario pide un worktree explícito, nace agrupado en
    `.worktrees/idea-<name>` (gitignored) dentro del repo, no como carpeta hermana suelta
    — `ideate.md` instruye agregar `.worktrees/` al `.gitignore` del proyecto; `teardown.md`
    apunta al nuevo path y maneja el legacy sibling vía `git worktree list`. (2) nuevo
    check #10 en `doctor` que corre `git worktree list` y avisa (⚠️, nunca error) de
    cualquier worktree `idea/*` viejo, sugiriendo `/design-forge:teardown`. Se DESCARTÓ el
    hook de sesión (infra invasiva injustificada con worktrees ya raros). Tocado:
    `commands/{ideate,teardown,doctor}.md`, `docs/referencia.md`.
  - **Impacto:** medio

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

- [x] **Desarrollar mobile obligatoriamente en todo el pipeline (no solo desktop)** · `origen: landing-crb` · `2026-07-17` · `cerrada: 2026-07-18`
  - **Contexto/gotcha:** el pipeline se centraba en el viewport DESKTOP; el mobile quedaba
    opcional/manual y se colaban bugs de responsive (cards con foto de fondo que colapsan
    a tiras en 1 columna, recortan sujetos, texto ilegible). Ninguna barrera lo detectaba.
  - **Hallazgo clave:** el andamiaje mobile YA existía parcial pero era ciudadano de
    segunda — opcional en `init`, ausente en `ideate`, tibio en `build`, sin poder de veto
    en `critique`. El fix fue elevarlo a evidencia OBLIGATORIA en cada fase.
  - **Resolución:** mobile como ciudadano de primera clase. (1) `init`: viewport mobile
    REQUERIDO junto al desktop + breakpoint(s); `doctor` lo verifica. (2) `ideate`: cada
    dirección se renderiza/screenshotea en desktop Y mobile; frames del preview sheet en
    ambos con badge legible/ilegible por viewport (acá se caza el bug antes del código).
    (3) `build`: el `@media` mobile es entregable + self-check mobile. (4) `review`: gate
    bloqueante — sin evidencia mobile o con composición mobile rota, ITERA nunca PASA.
    (5) `SKILL.md`: hard rule 11 "Mobile is first-class" + rule 3 reforzada + anti-pattern.
    Tocado: `commands/{init,ideate,build,review,doctor}.md`, `skills/pipeline/SKILL.md`,
    `docs/{que-es-y-por-que,referencia}.md`. Default mobile alineado a 390×844.
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
