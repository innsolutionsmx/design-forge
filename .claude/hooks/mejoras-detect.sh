#!/usr/bin/env bash
# SessionStart hook — avisa (no bloquea) si hay mejoras pendientes en el backlog.
# El backlog lo alimenta la skill personal `design-forge-mejora` desde otros proyectos.
# Contraparte de consumo: la skill `/revisar-mejoras` procesa los pendientes.
set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
file="${root}/seguimiento-de-mejoras.md"

# Sin archivo → nada que avisar.
[ -f "${file}" ] || exit 0

# Contamos SOLO los pendientes reales: items `- [ ]` que viven DENTRO de la sección
# "## Pendientes". Con awk acotamos a esa sección para no contar el ejemplo de formato
# (que está bajo "## Formato...") ni nada de "## Hechas". Emitimos "N\t<títulos>".
result="$(awk '
  /^## Pendientes[[:space:]]*$/ { inpend=1; next }
  /^## / { inpend=0 }
  inpend && /^- \[ \] / {
    n++
    line=$0
    sub(/^- \[ \] \*\*/, "", line)     # quita el checkbox y el ** de apertura
    sub(/\*\*.*$/, "", line)           # quita desde el ** de cierre en adelante
    titles = titles "     · " line "\n"
  }
  END { printf "%d\t%s", n, titles }
' "${file}")"

pend="${result%%$'\t'*}"
titles="${result#*$'\t'}"
pend="${pend:-0}"

[ "${pend}" -gt 0 ] 2>/dev/null || exit 0

printf 'design-forge — backlog de mejoras: tenés %s pendiente(s) en seguimiento-de-mejoras.md\n' "${pend}"
[ -n "${titles}" ] && printf '%s\n' "${titles}"
printf 'Para procesarlas una por una: invocá la skill /revisar-mejoras\n'

exit 0
