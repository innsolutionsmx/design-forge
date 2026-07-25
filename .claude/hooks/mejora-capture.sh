#!/usr/bin/env bash
# UserPromptSubmit hook — LOCAL al repo design-forge (NO viaja con el plugin: sólo
# sirve a quien desarrolla/dogfoodea el plugin, no al usuario final que diseña UIs).
#
# Amarra la CAPTURA de mejoras (mejora #4): cuando en el prompt asoma una mejora,
# gotcha o limitación DEL plugin, re-inyecta el recordatorio de invocar la skill
# `design-forge-mejora` (modo SEMI) en vez de escribir a mano en un archivo suelto.
# Caso real que lo motivó: se escribió en `landing-crb/design/design-forge-gotchas.md`
# en vez de usar la skill. Una skill disponible no amarra; el hook sí (se re-inyecta
# por prompt → sobrevive la compactación).
#
# Defensivo: ante cualquier falla salimos 0 sin inyectar nada. Nunca bloqueamos.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

payload="$(cat 2>/dev/null || true)"
prompt="$(printf '%s' "${payload}" | jq -r '.prompt // empty' 2>/dev/null || true)"
[ -n "${prompt}" ] || exit 0

# Señal de que ASOMA una mejora/gotcha/limitación del plugin. Requerimos una pista de
# "esto es una mejora/fricción" para no dispararnos en cada prompt de trabajo normal.
signals=(
  'mejora' 'gotcha' 'limitación' 'limitacion' 'limitation'
  'design-forge debería' 'design-forge deberia' 'design-forge podría' 'design-forge podria'
  'el plugin debería' 'el plugin deberia' 'el plugin podría' 'el plugin podria'
  'anotá esto' 'anota esto' 'anotalo' 'guardá este' 'guarda este' 'guardá esta' 'guarda esta'
  'para el plugin' 'para el backlog' 'bug del plugin' 'falta un comando' 'falta el comando'
  'sería mejor si' 'seria mejor si' 'esto es una mejora' 'esto debería' 'esto deberia'
)

matched=0
shopt -s nocasematch
for kw in "${signals[@]}"; do
  if [[ "${prompt}" == *"${kw}"* ]]; then matched=1; break; fi
done
shopt -u nocasematch

[ "${matched}" -eq 1 ] || exit 0

read -r -d '' context <<'EOF' || true
design-forge · CAPTURA DE MEJORAS: parece que asomó una mejora, gotcha o limitación del
plugin. No la escribas a mano en un archivo suelto (ni en el proyecto donde estés) —
invocá la skill `design-forge-mejora`, que en modo SEMI te muestra el registro propuesto
y escribe en el backlog central (seguimiento-de-mejoras.md) sólo tras tu confirmación.
Contraparte de consumo: /revisar-mejoras. Si el prompt no era sobre una mejora del
plugin, ignorá este recordatorio.
EOF

jq -n --arg ctx "${context}" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'

exit 0
