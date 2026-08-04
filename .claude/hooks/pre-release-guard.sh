#!/usr/bin/env bash
# PreToolUse(Bash) hook — LOCAL al repo design-forge (NO viaja con el plugin: sólo le
# sirve a quien lo desarrolla, no al usuario final que diseña UIs).
#
# Amarra el GATE del manifest. La v0.6.0 se publicó con un `plugin.json` inválido y
# nadie lo detectó hasta que un proyecto la instaló y el plugin quedó en `failed to
# load`. La lección de este repo ya está escrita dos veces en el backlog: *una skill
# disponible no es un amarre — se olvida*. Un check que hay que acordarse de correr es
# la misma falla que estamos arreglando; por eso el gate se dispara solo, en el camino
# que sí o sí se recorre para publicar: `git merge` / `git tag` / `git push`.
#
# Postura, y acá está la diferencia con los otros hooks locales: los demás son
# DEFENSIVOS (ante la duda, exit 0 y nunca molestan). Este BLOQUEA (exit 2) cuando el
# manifest está roto o cuando no se puede validar. Un gate que falla en silencio es
# peor que no tenerlo: entrega confianza falsa.
#
# Nunca bloquea por lo que NO sabe: si el comando no huele a release, o si no estamos
# en el repo del plugin, sale 0 y no dice nada.
set -uo pipefail

payload="$(cat 2>/dev/null || true)"
[ -n "${payload}" ] || exit 0

# Extraemos el comando. Sin jq caemos al texto crudo del payload: perdemos precisión
# (podríamos disparar de más), nunca de menos. Un falso positivo cuesta 50ms; un falso
# negativo cuesta un release roto.
if command -v jq >/dev/null 2>&1; then
  tool="$(printf '%s' "${payload}" | jq -r '.tool_name // empty' 2>/dev/null || true)"
  [ -z "${tool}" ] || [ "${tool}" = "Bash" ] || exit 0
  command_line="$(printf '%s' "${payload}" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
  [ -n "${command_line}" ] || exit 0
else
  command_line="${payload}"
fi

# ¿Huele a publicar? Disparo ancho, bloqueo angosto: corremos el validador en cualquier
# merge/tag/push, pero sólo frenamos si el manifest está REALMENTE roto.
case "${command_line}" in
  *"git merge"*|*"git tag"*|*"git push"*) ;;
  *) exit 0 ;;
esac

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
validator="${root}/scripts/validate-manifest.sh"

# Sin validador no estamos en el repo del plugin (o alguien lo borró): no es asunto
# nuestro, no bloqueamos.
[ -f "${validator}" ] || exit 0
[ -f "${root}/.claude-plugin/plugin.json" ] || exit 0

output="$(bash "${validator}" "${root}" 2>&1)"
status=$?

[ "${status}" -eq 0 ] && exit 0

# exit 2 = se bloquea la llamada al tool y el stderr le llega al agente.
{
  echo "design-forge · GATE DE RELEASE: el manifest del plugin NO es publicable."
  echo
  echo "${output}"
  echo
  echo "Operación de git bloqueada. Arreglá .claude-plugin/plugin.json y reintentá."
  echo "Para validar a mano: bash scripts/validate-manifest.sh"
} >&2

exit 2
