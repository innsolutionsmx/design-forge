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

- [ ] **Sumar el check del manifest a `/design-forge:doctor` (viaja con el próximo release)** · `origen: landing-crb` · `2026-08-03`
  - **Contexto/gotcha:** remanente de la entrada "Amarrar el gate del manifest" (ver `Hechas`, cerrada 2026-08-03). El gate ya existe y bloquea, pero como diagnóstico también tiene valor: poder preguntarle a `doctor` "¿está sano lo que voy a publicar?" sin tener que acordarse del path del script.
  - **Por qué NO se hizo junto con el gate:** tocar `commands/` obliga a bump y release. Hacerlo solo por este check quemaría una versión entera para algo que ya está cubierto por el hook. Se cuelga del próximo release real — el del fold, que ya toca `commands/`.
  - **Mejora propuesta:** check nuevo en `commands/doctor.md` que (a) detecte si el cwd es el repo del plugin (`.claude-plugin/plugin.json` con `name == design-forge`); (b) si no lo es, reporte N/A en una línea y siga — en el proyecto del usuario final este check es inútil (ver abajo); (c) si lo es, corra `scripts/validate-manifest.sh` y reporte ✅/❌ con su salida.
  - **Ojo con la paradoja:** en el proyecto del usuario final este check NO puede servir. `doctor` es un comando DEL plugin: si el manifest es inválido, el plugin no carga y el comando no existe. Sólo funciona en el repo dev, donde el `doctor` que corre viene del cache pineado por versión (`~/.claude/plugins/cache/design-forge/design-forge/<v>`) y el archivo que valida es el del working tree. Son dos copias distintas — por eso ahí sí sirve.
  - **Impacto:** bajo (el amarre ya está; esto es ergonomía)

- [ ] **Marcar el fold real y el borde del dispositivo en los preview sheets** · `origen: landing-urn` · `2026-08-02`
  - **Contexto/gotcha:** el frame de preview mobile usa el alto del DISPOSITIVO (390×844 / 393×852) y eso miente: el viewport útil de Safari iOS con la barra de URL desplegada es ~87.5% de eso (~745px en un 14 Pro). En esta sesión una variante del hero "entraba" en el frame de 852 y en el teléfono real quedaba 48px fuera del fold — se estuvo por elegir por un dato falso. Agravante: dentro de un iframe `100svh` mide el IFRAME, así que cualquier layout atado a `svh` se renderiza distinto al teléfono y el preview miente en el sentido contrario (pesimista).
  - **Mejora propuesta:** que el preview sheet de `ideate` (a) dibuje DOS marcas por frame — fold real (~87.5% del alto) y borde del dispositivo — con leyenda; (b) reporte por variante dónde termina el elemento decisivo (CTA, nav, fin del contenido) contra el fold, no solo un screenshot: la diferencia entre elegir bien y mal fueron 12px de aire y eso no se ve a ojo; (c) exponga el fold como variable CSS (`--fold`) e inyecte `--fold:<alto útil>` en el iframe, para que los layouts con `svh`/`dvh` se rendericen como en el teléfono. Sin (c) la marca dice dónde corta pero el contenido está dibujado con la medida equivocada. Alternativa a (c) si el layout no usa svh: renderizar el iframe directamente al alto útil.
  - **Impacto:** alto

- [ ] **Verificar cada variante en los DOS estados del viewport móvil, no en uno** · `origen: landing-urn` · `2026-08-03`
  - **Contexto/gotcha:** el viewport móvil cambia en runtime — Safari iOS pasa de ~745px (barra desplegada) a 852px (colapsada) sobre el MISMO dispositivo. Hay bugs que existen solo en uno de los dos estados. Caso real: un slide del hero que medía por contenido y dos hermanos atados a `svh` diferían 4px a 745 (parecía correcto, se dio el OK) y **107px a 852**, con los controles del carrusel saltando de altura al cambiar de slide. Lo reportó el usuario desde el teléfono DESPUÉS de que el agente diera la verificación por buena con números en la mano.
  - **Mejora propuesta:** que `ideate` y el gate de `review` midan cada variante en los DOS altos (fold útil y alto del dispositivo) y reporten el DIFF de las posiciones clave entre ambos estados; si un elemento se mueve entre estados, es hallazgo y no ruido. No hace falta doble screenshot: alcanza con la comprobación numérica en el segundo alto, que es barata. Regla para `SKILL.md`: “una sola altura de viewport no es evidencia mobile”. Complementa la entrada de las marcas de fold — esa arregla el instrumento de medición, esta obliga a usarlo dos veces.
  - **Impacto:** alto

## Hechas

- [x] **Amarrar el gate del manifest: validación determinística que bloquea el release** · `origen: landing-crb` · `2026-07-26` · `cerrada: 2026-08-03`
  - **Contexto/gotcha:** la v0.6.0 se publicó con un `plugin.json` inválido y NADIE lo detectó hasta que un proyecto intentó actualizar y el plugin quedó en `failed to load` (ver la entrada de abajo). El release no tenía ningún gate: se taggeaba, se publicaba, y el error aparecía en la máquina del usuario final — con el agravante de que un plugin roto se lleva puestos sus skills, comandos y MCP servers de una.
  - **Hallazgo clave (cambió el diseño):** la entrada original pedía el check dentro de `commands/doctor.md`. Eso es la MISMA clase de falla que se quería arreglar: un check que hay que acordarse de invocar. El problema nombrado en el gotcha era "NADIE lo detectó" — y este repo ya aprendió dos veces (entradas del hook de preview y del hook de captura) que *una skill/comando disponible no es un amarre, se olvida*. Un gate que depende de la memoria no es un gate: es una sugerencia con cara seria.
  - **Resolución:** (1) `scripts/validate-manifest.sh` — gate determinístico, exit 0/1: JSON parseable, `name` y `version` presentes con semver válido, toda ruta declarada (`skills`/`agents`/`commands`/hooks extra/`mcpServers` como string) existente en disco, y la clave `hooks` NUNCA apuntando al estándar `hooks/hooks.json` (normaliza `./` y `${CLAUDE_PLUGIN_ROOT}/`, así que caza las dos formas del bug). Parser `jq` con fallback `python3`; **sin ninguno de los dos FALLA**, no saltea. (2) `.claude/hooks/pre-release-guard.sh` — `PreToolUse` sobre `Bash` (registrado en `.claude/settings.json`), corre el validador ante `git merge`/`git tag`/`git push` y **bloquea con exit 2** si el manifest está roto. Disparo ancho, bloqueo angosto. (3) `docs/desarrollo-y-releases.md` — la release pasa de 3 pasos a 5: paso 0 de validación y paso 3 de gate manual (`claude plugin list` debe decir `✔ enabled`).
  - **Postura de diseño (contraria a los otros hooks):** los hooks locales existentes son DEFENSIVOS (ante la duda, `exit 0`, nunca molestan). Este bloquea, y también bloquea cuando NO puede validar. Un gate que falla en silencio es peor que no tenerlo: entrega confianza falsa. Nunca bloquea por lo que no sabe (comando que no huele a release, o cwd que no es el repo del plugin → `exit 0` mudo).
  - **Regalo de scope:** al vivir en `.claude/` + `scripts/` no toca `commands/` → **no requiere bump ni release**. El arreglo para "releases rotas" no necesitó quemar una versión. El check de `doctor`, que igual suma como diagnóstico, quedó en `Pendientes` para viajar gratis con el próximo release real.
  - **Verificación:** 8 casos del validador (bug exacto de la v0.6.0 en sus dos formas `hooks/hooks.json` y `./hooks/hooks.json`, hook extra inexistente, skill declarada fantasma, semver inválido, `name` vacío, JSON corrupto, manifest sano) con paridad idéntica entre `jq` y `python3`; y 9 casos del hook (merge/tag/push con manifest sano → mudo; `git status` y comandos no-git → no dispara; tool ≠ Bash, payload vacío, cwd fuera del repo → `exit 0`; merge con manifest roto → `exit 2` + diagnóstico). Tocado: `scripts/validate-manifest.sh` (nuevo), `.claude/hooks/pre-release-guard.sh` (nuevo), `.claude/settings.json`, `docs/desarrollo-y-releases.md`.
  - **Impacto:** alto

- [x] **Quitar la clave `hooks` del manifest: rompía la carga completa del plugin** · `origen: landing-crb` · `2026-07-26` · `cerrada: 2026-07-26`
  - **Contexto/gotcha:** al actualizar design-forge desde un proyecto (v0.4.0 → v0.6.0), el plugin quedó en `Status: ✘ failed to load` con `Validation errors: hooks: Invalid input`. Causa raíz: la entrada #2 de este backlog ("Amarrar el trigger de preview con un hook bundleado") agregó `"hooks": "hooks/hooks.json"` al `plugin.json` — y Claude Code **ya carga `hooks/hooks.json` automáticamente por convención**. Declararlo a mano no es redundante: es inválido.
  - **Regla dura (verificada en los 3 modos):** (1) `"hooks": "hooks/hooks.json"` → `Invalid input`; (2) `"hooks": "./hooks/hooks.json"` → `Duplicate hooks file detected... The standard hooks/hooks.json is loaded automatically, so manifest.hooks should only reference additional hook files`; (3) sin la clave → `✔ enabled` y el hook igual carga. Contrastado contra los plugins oficiales de Anthropic que bundlean hooks (`hookify`, `claude-security`, `ralph-loop`): ninguno declara `hooks` en su `plugin.json`.
  - **Resolución:** eliminada la clave `hooks` de `.claude-plugin/plugin.json` + bump a 0.6.1. El hook `preview-discipline.sh` sigue funcionando igual — nunca dependió de la declaración. Tocado: `.claude-plugin/plugin.json`. Queda abierto el check preventivo en `doctor` (ver `Pendientes`).
  - **Impacto:** alto

- [x] **Agregar preview de encuadre para assets (abanico de object-position)** · `origen: landing-crb` · `2026-07-21` · `cerrada: 2026-07-22`
  - **Contexto/gotcha:** al colocar fotos en contenedores `object-cover`, el agente adivina UN `object-position` y encuadra mal (cabeza cortada, sujeto arriba/abajo, horizonte partido), con personas Y paisajes. Causa raíz doble: (a) verificación ciega — screenshotear el `<img>` ignora el recorte CSS = falso OK; (b) adivina en vez de comparar.
  - **Resolución:** nuevo paso 8 en `commands/ideate.md` ("Encuadre de assets en `object-cover`") que reusa el sustrato de preview in-place parametrizado sobre el crop: abanico de `object-position` (`top`/`center 25%`/`center`/`center 75%`/`bottom`, ajustable) sobre el contenedor REAL, screenshot del `<div>` contenedor (NUNCA del `<img>`) al aspect ratio real, en desktop Y mobile (el crop rompe distinto por viewport — puede necesitar `object-position` propio en `@media`), el dev elige y se fija el valor. Sin face-detection (anti-sobreingeniería). Refuerzo en el paso 7 (verify): ataca la causa (a) remitiendo al paso 8 y prohibiendo screenshotear el `<img>`. Renumerados los pasos siguientes (iterate/pick/teardown → 9/10/11). Conecta con el hook #2, que ya anticipa "asset → preview de encuadre". Tocado: `commands/ideate.md`.
  - **Impacto:** medio

- [x] **Amarrar el trigger de preview con un hook bundleado en el plugin (imagen/UI)** · `origen: landing-crb` · `2026-07-21` · `cerrada: 2026-07-22`
  - **Contexto/gotcha:** ofrecer el preview depende de que el agente se acuerde; una preferencia en memoria no amarra (se pierde en la compactación). El dev reporta que le construyo algo distinto a la referencia, o que me salto ofrecer opciones con decisión visual abierta.
  - **Hallazgo clave:** verificado contra doc oficial (agente claude-code-guide) — los adjuntos de imagen NO llegan al payload del hook (solo `prompt`, `session_id`, `cwd`). Eso CONFIRMA el reparto propuesto: el hook no puede "ver" la imagen, así que su único trabajo es RECORDAR la disciplina; el MODELO percibe el adjunto y decide qué preview aplica. Caveat cerrado.
  - **Resolución:** hook `UserPromptSubmit` BUNDLEADO en el plugin (`hooks/hooks.json` + `hooks/preview-discipline.sh`, referenciado desde `plugin.json` con `"hooks": "hooks/hooks.json"` y `${CLAUDE_PLUGIN_ROOT}`) — ⚠️ **CORREGIDO el 2026-07-26**: esa declaración en `plugin.json` era INVÁLIDA y rompía la carga del plugin entero; `hooks/hooks.json` se carga solo por convención. Ver la entrada "Quitar la clave `hooks` del manifest". Se activa en todo proyecto con design-forge, sin config per-proyecto. Dispara CONDICIONAL por señales textuales de trabajo visual (umbral bajo, bilingüe ES/EN; preferimos falso positivo a falso negativo), e inyecta `additionalContext` con el protocolo de desambiguación (idea→variaciones / referencia→fidelidad / asset→encuadre). Defensivo: sin jq o ante cualquier falla → exit 0 silencioso, nunca bloquea. Probado con 6 casos (dispara/no-dispara/sin-prompt). Tocado: `hooks/hooks.json` (nuevo), `hooks/preview-discipline.sh` (nuevo), `.claude-plugin/plugin.json`.
  - **Impacto:** alto

- [x] **Amarrar la captura de mejoras con un hook que dispare la skill design-forge-mejora** · `origen: landing-crb` · `2026-07-22` · `cerrada: 2026-07-22`
  - **Contexto/gotcha:** la skill `design-forge-mejora` existe para registrar mejoras en el backlog central, pero NADA obliga a usarla. Caso real: surgió una mejora del plugin y el agente escribió en el archivo equivocado (`landing-crb/design/design-forge-gotchas.md`) en vez de invocar la skill. Una skill disponible no es un amarre — se olvida.
  - **Decisión de scope:** el hook va LOCAL al repo design-forge (`.claude/hooks/`), NO bundleado en el plugin. Razón: recordar "capturá una mejora del plugin" solo le sirve a quien desarrolla/dogfoodea el plugin, no al usuario final que solo diseña UIs (para él sería ruido: no tiene el backlog ni le importa). Al quedar local, se cae la sub-decisión abierta: la skill `design-forge-mejora` sigue siendo personal, no se mueve al plugin.
  - **Resolución:** hook `UserPromptSubmit` local (`.claude/hooks/mejora-capture.sh`, registrado en `.claude/settings.json` junto al SessionStart existente). Dispara cuando el prompt trae una señal de mejora/gotcha/limitación del plugin e inyecta `additionalContext` recordando invocar `design-forge-mejora` en modo SEMI. Mismo patrón defensivo que el #2 (exit 0 silencioso ante fallas). Probado (dispara con "esto es una mejora para el plugin"; NO dispara con "bug del login"). Tocado: `.claude/hooks/mejora-capture.sh` (nuevo), `.claude/settings.json`.
  - **Impacto:** medio

- [x] **Corregir "diseño concreto → sin preview": el preview de fidelidad es obligatorio** · `origen: landing-crb` · `2026-07-21` · `cerrada: 2026-07-22`
  - **Contexto/gotcha:** la regla actual (F6 "diseño concreto → implementar directo") saltea el preview cuando el dev pasa una referencia concreta. Caso real: es JUSTO ahí donde el agente a veces construye algo distinto a lo pedido, y saltear el preview saca la única red que atrapa esa divergencia.
  - **Hallazgo clave:** el preview tenía DOS funciones fundidas en una sola regla — DECIDIR (qué dirección gana) y VERIFICAR FIDELIDAD (lo construido hace match con lo pedido). La regla concreta salteaba AMBAS; solo debía saltear la de decisión. Y la fase 3 (Critique) NO tapa el hueco: verifica CALIDAD, no FIDELIDAD contra la referencia concreta que trajo el dev.
  - **Resolución:** se separaron las dos funciones. (1) `SKILL.md` hard rule 9: se nombra explícitamente la doble función del preview; con diseño concreto se saltean las VARIACIONES pero NUNCA el preview de fidelidad, y se prohíbe "implementar directo sin preview". (2) `commands/ideate.md` Step 0b: la ruta de diseño concreto ya no hace hand-off ciego a build — ahora debe renderizar el resultado construido en ambos viewports (desktop Y mobile) y mostrar UN frame lado a lado contra la referencia (mockup/spec = "before", construido = "after") y confirmar el match antes de finalizar. Sin infra nueva (reusa el preview in-place existente); no toca la fase 3. Tocado: `skills/pipeline/SKILL.md`, `commands/ideate.md`.
  - **Impacto:** alto

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
