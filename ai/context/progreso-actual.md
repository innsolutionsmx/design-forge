# Progreso actual — design-forge

> Source of truth de "dónde quedamos" en el desarrollo del plugin. Leelo primero al
> abrir sesión, actualizalo al cerrar cada batch. Sincroniza máquinas y compañeros
> vía git (engram es local de cada máquina y no viaja).

---

## Última actualización

- **Fecha**: 2026-08-03
- **Máquina**: Mac (oficina)
- **Rama actual**: `fix/doctor-check-muerto-y-validate-oficial` (0.7.1 lista para dev→main)
- **Última acción**: **RELEASE 0.7.1 (correctiva de la 0.7.0)**. Dos correcciones, ambas
  gatilladas por preguntas del owner que destaparon errores del agente:
  (1) **El check 11 de `doctor` nació MUERTO y se BORRÓ**: el plugin nunca estuvo instalado
  en su propio repo (las entradas de `plugin list` eran landing-crb y landing-urn). Se evaluó
  instalarlo y se REVIRTIÓ: el plugin cargado sería el release CACHEADO de GitHub main, no el
  working tree (cero valor de dev-loop), y costaría Playwright MCP + hook de preview en cada
  sesión de un repo sin UI. La verificación post-release se hace desde un consumidor
  (`claude plugin list`/`update` resuelven proyectos desde cualquier cwd).
  (2) **`validate-manifest.sh` ahora DELEGA en `claude plugin validate --strict`** (existía y
  no se buscó antes de escribir el validador a mano): caza el bug v0.6.0, rutas inexistentes,
  sintaxis de hooks por convención y claves con typo. Su único hueco medido es el semver
  (`"v0.7"` pasa incluso con --strict) — el script lo suma, más fallback jq/python3 sin CLI.
  Gotcha: pasarle el DIRECTORIO valida el marketplace.json si existe; hay que pasar
  `plugin.json` explícito. + `description` al marketplace.json (mataba warning de --strict).
  **Falta**: merge a dev→main + push, verificación `✔ enabled` desde consumidor.
- **Acción histórica (0.7.0, ya en `main`)**: **BACKLOG EN CERO — dos batches.**
  **(1) Gate del manifest (sin release, no toca `commands/`)**: `scripts/validate-manifest.sh`
  (determinístico, exit 0/1: JSON parseable, `name`/`version` semver, rutas declaradas
  existentes, y la clave `hooks` NUNCA apuntando al estándar `hooks/hooks.json`) + hook LOCAL
  `.claude/hooks/pre-release-guard.sh` (`PreToolUse`/Bash) que lo corre ante
  `git merge`/`tag`/`push` y **bloquea con exit 2**. Se DESCARTÓ ponerlo en `doctor` como
  amarre: un check que hay que acordarse de invocar es la misma clase de falla que se estaba
  arreglando (el gotcha decía "NADIE lo detectó"). El `doctor` quedó sólo como diagnóstico.
  Postura invertida respecto de los otros hooks del repo: éste bloquea también cuando NO puede
  validar — un gate que falla en silencio da confianza falsa. `docs/desarrollo-y-releases.md`:
  la release pasa de 3 pasos a 5.
  **(2) Viewport mobile como RANGO (release 0.7.0, PUBLICADA en `main`)**: cierra las
  dos entradas del fold. DESIGN.md registra alto útil/fold Y alto del dispositivo (medidos en
  el teléfono, `window.innerHeight`; el ~87.5% es default `estimado`); `ideate` rinde SIEMPRE
  dos frames mobile con el iframe dimensionado al alto real de cada estado —así `svh` resuelve
  como en el teléfono SIN parche, y `--fold` quedó como conveniencia, no como mecanismo— más
  la **tabla de fold** del verificador (`getBoundingClientRect().bottom` contra el fold por
  estado + DIFF entre estados); `review` falla también con evidencia en UNA sola altura;
  reglas 8 y 11 de `SKILL.md` extendidas (no se agregó una regla 12: son caras). Colgado del
  mismo release, el check 11 del manifest en `doctor` (⚠️ revertido en 0.7.1 — nació muerto).
  **NO validado aún en corrida real** (regla de proceso 3).
- **Acción previa**: **HOTFIX v0.6.1 a `main`**: la v0.6.0 se publicó con un
  `.claude-plugin/plugin.json` INVÁLIDO — traía `"hooks": "hooks/hooks.json"`, pero Claude
  Code ya carga ese archivo por convención, así que declararlo tira
  `Validation errors: hooks: Invalid input` y **el plugin entero queda en `failed to load`**
  (se cae con sus skills, comandos y MCP servers). Detectado al intentar actualizar
  design-forge desde landing-crb (v0.4.0 → v0.6.0). Regla dura: `manifest.hooks` solo
  referencia archivos de hooks **ADICIONALES**, nunca el estándar `hooks/hooks.json`
  (contrastado contra `hookify`, `claude-security` y `ralph-loop` de Anthropic: ninguno lo
  declara). Fix = eliminar la clave. Queda **PENDIENTE** el check preventivo de manifest en
  `/design-forge:doctor` (anotado en `seguimiento-de-mejoras.md`), porque hoy el release no
  tiene ningún gate que valide el manifest antes de publicar.
- **Acción previa**: **RELEASE v0.6.0 a `main`**: contrato ENDURECIDO del paso 7 de
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

- **Publicado en `main`**: v0.6.1 — pipeline 4 fases (init/ideate/build/review) +
  teardown, mobile first-class (hard rule 11), preview de fidelidad + preview de encuadre,
  **verificación del paso 7 DELEGADA a subagente endurecido** (gate determinístico + pase
  adversarial + harness mobile confiable), 2 hooks `UserPromptSubmit` (uno bundleado, uno
  local al repo), doctrina de 11 hard rules, Playwright MCP bundleado.
- **En `dev`, sin publicar**: v0.7.0 — viewport mobile como RANGO (dos frames mobile siempre
  + tabla de fold medida + gate de review por altura única) y check 11 de manifest en
  `doctor`. Más el gate de release (script + hook local), que NO viaja al consumidor.
- **Proceso de release**: cambios en rama → merge a `dev` → promoción a `main` + bump
  de versión SOLO por decisión explícita del owner (main = lo que consumen los proyectos).

## Próximos pasos

- [ ] **Cerrar el release 0.7.0**: pushear `dev`, merge a `main`, y `claude plugin list`
  sobre la candidata exigiendo `✔ enabled` (paso 3 del proceso).
- [ ] **Validar 0.7.0 en corrida real** (regla de proceso 3, la feature no está cerrada sin
  esto): la próxima ideación con mobile debe producir los dos frames y la tabla de fold, y el
  número del alto útil tiene que salir MEDIDO del teléfono, no del default del 87.5%.
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
