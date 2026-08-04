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

<!-- Vacío: el backlog está en cero. Las mejoras entran acá desde cualquier proyecto vía
     la skill `design-forge-mejora`; el hook SessionStart las cuenta al abrir sesión. -->

## Hechas

- [x] **Definir el mecanismo de propagación de releases a consumidores (hoy no existe)** · `origen: design-forge` · `2026-08-03` · `cerrada: 2026-08-03`
  - **Contexto/gotcha:** ningún consumidor real tenía `autoUpdate: true` (landing-urn ni siquiera tenía `extraKnownMarketplaces`), así que nadie recibía releases solo: landing-urn corrió 0.6.1 durante una validación mientras el marketplace servía 0.7.1. Versiones fantasma: se cree que un consumidor corre X y corre Y.
  - **Hallazgo:** SETUP.md YA documentaba `autoUpdate: true` como deliberado — el doc estaba bien; las instalaciones reales no lo siguieron (install a mano vía CLI deja `enabledPlugins` sin marketplace: el plugin anda pero congelado). El problema era drift, no falta de doc.
  - **Resolución (opción a, decidida por el owner):** `extraKnownMarketplaces` + `autoUpdate: true` configurado en landing-urn (no tenía la clave) y landing-crb (la tenía sin autoUpdate) — queda que cada proyecto commitee su settings. SETUP.md paso 2 ampliado: aplica también a installs EXISTENTES, con el síntoma del drift descripto. Doc de release paso 4 reescrito: propagación vía autoUpdate, y la verificación contra `installed_plugins.json` sigue vigente porque "el autoUpdate corrió" también es una suposición.
  - **Impacto:** alto

- [x] **Protocolo de corrida real CIEGA para validar features del pipeline** · `origen: landing-urn` · `2026-08-03` · `cerrada: 2026-08-03`
  - **Contexto/gotcha:** la validación de la 0.7.1 se contaminó doble: el ejecutor corría 0.6.1 (nadie verificó la versión CARGADA en la sesión, solo la supuestamente instalada) y el orquestador le pasó el checklist de aceptación al ejecutor — que cumplió los 6 puntos por instrucción, no porque el plugin los exigiera. Una validación contaminada es peor que ninguna: certifica lo no probado.
  - **Resolución:** regla de proceso 3 de `desarrollo-y-releases.md` endurecida con el protocolo de 3 puntos: (1) verificar la versión CARGADA — los bloques nuevos tienen que estar en el contexto del ejecutor (`rg` de una frase distintiva), el marketplace puede servir X mientras la sesión cargó Y; (2) el ejecutor recibe SOLO el brief, el checklist queda con el juez y se contrasta DESPUÉS; (3) sin (1) y (2) la corrida se repite, no se "aprovecha". La validación de la 0.7.1 sigue PENDIENTE y será la primera corrida bajo este protocolo.
  - **Impacto:** alto

- [x] **Taggear los releases con `claude plugin tag` (o decidir explícitamente no taggear)** · `origen: design-forge` · `2026-08-03` · `cerrada: 2026-08-03`
  - **Contexto/gotcha:** el último tag del repo era `v0.4.0` (`git describe` → `v0.4.0-28-g19b5a54`); las releases 0.5.x→0.7.1 existían solo como merges a main. La distribución funciona sin tags (probado), pero "¿qué commit es la 0.6.1?" no tenía respuesta rápida — justo la pregunta que la sesión contaminada necesitó responder.
  - **Resolución (taggear, decidido por el owner):** backfill de 5 tags anotados con el formato de `claude plugin tag` (`design-forge--v{version}`) apuntando al merge de main de cada release: v0.5.0→`ff5620b`, v0.6.0→`398df90`, v0.6.1→`1bb5a7b`, v0.7.0→`faa3a19`, v0.7.1→`d46aae6` (mapeados leyendo `plugin.json` en cada merge de `--first-parent`, no adivinados). Para adelante: paso 2b del release = `claude plugin tag --push` parado en main recién mergeado (valida plugin.json vs marketplace de regalo; exige tree limpio). El tag viejo `v0.4.0` queda como está — histórico.
  - **Impacto:** medio

- [x] **0.7.1: quitar el check muerto de doctor y delegar el gate en `claude plugin validate`** · `origen: design-forge` · `2026-08-03` · `cerrada: 2026-08-03`
  - **Contexto/gotcha:** doble corrección a decisiones de la 0.7.0, gatillada por dos preguntas del owner ("¿esa solución es la mejor?" / "¿hay ventaja en instalar el plugin acá?"). (1) El check 11 de `doctor` nació MUERTO: el plugin nunca estuvo instalado en su propio repo (las entradas de `claude plugin list` eran landing-crb y landing-urn), así que el check no podía correr en ningún lado y encima imprimía una línea de N/A a cada consumidor. (2) El validador a mano se escribió sin buscar si Claude Code ya traía la herramienta — la trae: `claude plugin validate --strict`.
  - **Decisión: NO instalar el plugin en su propio repo.** Se evaluó habilitarlo y se revirtió: el plugin cargado sería el RELEASE cacheado de GitHub main (verificado: `gitCommitSha` del cache = commit del release), NO el working tree — cero valor para el loop de desarrollo — y costaría en CADA sesión el Playwright MCP + el hook de preview-discipline disparando por señales visuales en un repo donde todos los prompts hablan de "preview" y "mobile". La verificación post-release no lo necesita: `claude plugin list` y `claude plugin update` resuelven los proyectos consumidores desde cualquier cwd.
  - **Verificado del validador oficial:** caza el bug de la v0.6.0, rutas declaradas inexistentes, sintaxis de los hooks por convención y (con `--strict`) claves con typo (`hoooks` → "did you mean 'hooks'?") — clase de falla que la lógica a mano nunca cubrió. Su ÚNICO hueco medido: el semver (`"v0.7"` pasa incluso con `--strict`). Gotcha de target: pasarle el DIRECTORIO con `marketplace.json` presente valida el MARKETPLACE, no el plugin — hay que pasar `plugin.json` explícito.
  - **Resolución:** `scripts/validate-manifest.sh` delega en `claude plugin validate --strict <plugin.json>` + check de semver propio + fallback a la lógica jq/python3 sin el CLI (misma interfaz, el hook no cambia). `doctor` pierde el check 11 (borrado, no corregido — código muerto). `marketplace.json` gana su `description` (mataba un warning de `--strict`). Doc de release: paso 0 documenta la delegación, paso 3 pasa a verificarse desde un consumidor. Bump 0.7.1 justificado por tocar `commands/`. Probado contra 11 fixtures (exit correcto en todos).
  - **Impacto:** medio

- [x] **El viewport mobile es un RANGO: fold real marcado, medido y verificado en los DOS estados** · `origen: landing-urn` · `2026-08-02` + `2026-08-03` · `cerrada: 2026-08-03`
  - **Nota:** cierra DOS entradas del backlog de una — "Marcar el fold real y el borde del dispositivo en los preview sheets" (02/08) y "Verificar cada variante en los DOS estados del viewport móvil" (03/08). Se implementaron juntas porque son la misma mejora partida en dos: una arregla el instrumento de medición, la otra obliga a usarlo dos veces. Separadas, cada una necesitaba andamiaje que la otra vuelve innecesario.
  - **Contexto/gotcha:** (1) el frame de preview mobile usaba el alto del DISPOSITIVO (852) y el viewport útil de Safari iOS con la barra desplegada es ~87.5% (~745): una variante del hero "entraba" en el frame y en el teléfono real quedaba 48px fuera del fold. (2) El viewport móvil cambia en RUNTIME entre esos dos valores sobre el mismo dispositivo: un slide del hero atado a `svh` difería 4px a 745 (se dio el OK) y **107px a 852**, con los controles del carrusel saltando. Lo reportó el usuario desde el teléfono DESPUÉS de que el agente diera la verificación por buena con números en la mano.
  - **Hallazgo clave (cambió el diseño):** la entrada original pedía inyectar `--fold` como variable CSS para que los layouts atados a `svh` se dibujaran bien. Pero eso es un PARCHE a una decisión, no una necesidad: dentro de un iframe `100svh` mide el IFRAME, así que **si el iframe se dimensiona al alto que se está renderizando, `svh` resuelve correcto solo**. Y como la segunda mejora obliga a renderizar en los dos altos igual, el problema desaparece por construcción en vez de compensarse. `--fold` quedó como conveniencia para anclar explícitamente, NO como el mecanismo.
  - **Resolución:** (1) `init.md` paso 7a — DESIGN.md registra el mobile como rango (alto útil/fold + alto del dispositivo), con la instrucción de MEDIRLO en el teléfono real (`window.innerHeight` con la barra desplegada) y el ~87.5% sólo como default marcado `estimado`. (2) `ideate.md` paso 6 — cada variante rinde SIEMPRE dos frames mobile (`estado fold` y `estado dispositivo`), iframe dimensionado al alto real de cada uno, con la marca del fold + leyenda en el de 852; se descartó la versión condicional ("sólo si toca el fold") porque mete un juicio del agente justo donde el pipeline viene poniendo gates. (3) `ideate.md` paso 7 — el subagente verificador suma la **tabla de fold**: `getBoundingClientRect().bottom` de los elementos decisivos contra el fold en cada estado + el DIFF entre estados; se reportan los números incluso cuando todo pasa ("entra" no es una medición). (4) `review.md` — el mobile gate bloqueante ahora falla también con evidencia en UNA sola altura. (5) `SKILL.md` — se extendieron las reglas 8 (presupuesto vertical contra el alto útil) y 11 ("una sola altura no es evidencia mobile") en vez de agregar una regla 12: las hard rules viajan al contexto de toda tarea de UI y son caras. Tocado: `commands/{init,ideate,review,doctor}.md`, `skills/pipeline/SKILL.md`, `docs/referencia.md`.
  - **Colgado del mismo release:** el check del manifest en `commands/doctor.md` (check 11). ⚠️ **Revertido en 0.7.1** — nació muerto: el plugin no está (ni estará) instalado en su propio repo, así que el check no podía correr nunca. Ver la entrada de la 0.7.1.
  - **Pendiente de validación:** como toda feature nueva, se cierra de verdad en la próxima corrida real (`docs/desarrollo-y-releases.md`, regla de proceso 3).
  - **Impacto:** alto

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
