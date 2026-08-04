# Desarrollo del plugin y releases

## El principio

`main` es lo que consumen los proyectos — cada merge a `main` con bump de versión es
una **release**, y las releases se deciden, no se acumulan. El desarrollo vive en `dev`.

```
rama de trabajo (feat/*, fix/*, docs/*)
        │  merge
        ▼
       dev          ← integración y prueba
        │  SOLO por decisión explícita del owner: bump + merge
        ▼
       main         ← release (lo que reciben los proyectos)
```

Este repo usa **inns-ai-flow** (dogfood): git-guard bloquea editar en `main`/`dev`,
las skills de gitflow llevan las ramas, y `ai/context/progreso-actual.md` mantiene la
continuidad entre sesiones y máquinas.

## Cómo evoluciona el pipeline: gotchas → reglas

El mecanismo de mejora es empírico, no especulativo:

1. Se usa el pipeline en un proyecto real (dogfood).
2. Lo que falla o falta se documenta como **gotcha ejecutable** — qué pasó, y qué
   archivo del plugin tocar (patrón: `design/design-forge-gotchas.md` en el proyecto,
   o un handoff con RFs y criterios de aceptación).
3. Los fixes se aplican al plugin en una rama, con plan aprobado antes de ejecutar.
4. La siguiente corrida real valida contra los criterios de aceptación.

Así nacieron: el preview comparativo explícito, el viewport de referencia, el
inventario de assets ("el repo no es la verdad de la marca"), el presupuesto vertical,
el scroll-through pre-screenshot y la disciplina de especificidad CSS.

## Dónde vive cada cosa al modificar

| Quiero cambiar… | Archivo |
|-----------------|---------|
| El procedimiento de una fase | `commands/{init,ideate,build,review}.md` |
| El diagnóstico | `commands/doctor.md` |
| Una regla que aplique SIEMPRE (aunque no se invoque comando) | `skills/pipeline/SKILL.md` (hard rules / doctrina) |
| El MCP bundleado | `mcpServers` en `.claude-plugin/plugin.json` |
| Lo que se valida antes de publicar | `scripts/validate-manifest.sh` (gate) |
| El onboarding para agentes | `SETUP.md` (+ blockquote del README) |

Regla de reparto: si es procedimiento de UNA fase → comando; si es criterio
transversal → doctrina (hard rule). Las hard rules son caras (van al contexto de toda
tarea de UI) — solo entra lo que previene errores reales ya vistos.

## Cómo se hace una release

0. **Validar el manifest** — `bash scripts/validate-manifest.sh`. Sale 0 = publicable,
   1 = no. Delega en `claude plugin validate --strict` (la verdad del runtime: sintaxis,
   rutas declaradas, la clave `hooks` apuntando al estándar —el bug de la v0.6.0—,
   claves con typo, y la sintaxis de los hooks por convención) y le suma el hueco
   verificado del oficial: el **semver** de `version` (`"v0.7"` pasa el oficial incluso
   con `--strict`). Sin el CLI cae a una validación propia equivalente. ⚠️ El oficial
   necesita el `plugin.json` EXPLÍCITO: si le pasás el directorio y existe
   `marketplace.json`, valida el marketplace y cambia de target en silencio.
1. **Bump de versión** en `.claude-plugin/plugin.json` (semver: fix = patch,
   feature = minor, incompatible = major). Sin bump NO hay distribución — el cache de
   plugins es por versión.
2. Merge `dev` → `main` y push.
3. **Verificación post-release, desde un proyecto CONSUMIDOR** (el plugin NO está
   instalado en este repo — decisión deliberada: acá no hay UI, y tenerlo cargaría el
   Playwright MCP y el hook de preview en cada sesión para nada): correr
   `claude plugin update design-forge@design-forge --scope project` en un consumidor
   (landing-crb/landing-urn) y exigir `Status: ✔ enabled` en `claude plugin list`.
   ⚠️ El `update` funciona desde cualquier cwd (resuelve los proyectos instalados
   globalmente), pero el `Status` del `list` es RELATIVO al cwd: desde otro repo muestra
   `✘ disabled` aunque el consumidor lo tenga sano — el `list` corrélo parado EN el
   consumidor. Un `✘ failed to load` es un release que se lleva puestos los
   skills, comandos y MCP servers de todos los que lo consumen.
4. Los proyectos con `autoUpdate: true` la reciben en su próxima sesión.

El paso 0 no depende de tu memoria: `.claude/hooks/pre-release-guard.sh` (`PreToolUse`
sobre `Bash`, registrado en `.claude/settings.json`) corre el validador solo ante
`git merge` / `git tag` / `git push` y **bloquea** la operación si el manifest está
roto. Disparo ancho, bloqueo angosto: valida seguido, frena sólo cuando hay error real.
Por qué un hook y no un check que haya que invocar: este repo ya aprendió dos veces que
*una skill disponible no es un amarre — se olvida*. La v0.6.0 salió rota justamente
porque el gate no existía y nadie se acordó de mirar.

**No requiere bump**: `docs/`, `SETUP.md`, `README.md`, `.claude/settings.json` del
repo, `ai/context/` (no viajan al consumidor — se sirven raw desde main o son locales).
**Sí requiere bump**: `commands/`, `skills/`, `templates/`, `plugin.json`.

## Reglas de proceso

- Nunca commitear directo en `main` ni `dev` (git-guard lo bloquea).
- Cambios de fondo: plan corto → OK del owner → ejecutar. Cambios relacionados en UNA
  rama/propuesta.
- Toda feature nueva se valida en una corrida real antes de considerarse cerrada
  (los criterios de aceptación del handoff son el checklist).
