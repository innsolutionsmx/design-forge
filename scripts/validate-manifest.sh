#!/usr/bin/env bash
# Gate determinístico del manifest del plugin — se corre ANTES de un release.
#
# Por qué existe: la v0.6.0 se publicó con un `.claude-plugin/plugin.json` inválido
# (declaraba `"hooks": "hooks/hooks.json"`, que Claude Code YA carga por convención) y
# el plugin entero quedó en `failed to load` en la máquina del usuario final. Un plugin
# roto se lleva puestos sus skills, comandos y MCP servers de una.
#
# Postura: esto es un GATE, no un hook de conveniencia. Si NO puede validar, FALLA —
# nunca saltea en silencio. Un gate que falla callado es peor que no tenerlo, porque
# entrega confianza falsa. (Opuesto a `.claude/hooks/*.sh`, que son defensivos a
# propósito y jamás bloquean.)
#
# Uso:  bash scripts/validate-manifest.sh [ruta-al-repo]
# Sale: 0 = manifest publicable · 1 = manifest roto o imposible de validar.
set -uo pipefail

root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
manifest="${root}/.claude-plugin/plugin.json"

errors=0
err()  { printf '❌ %s\n' "$1" >&2; errors=$((errors + 1)); }
ok()   { printf '✅ %s\n' "$1"; }
info() { printf '   %s\n' "$1"; }

# ── 1. El archivo existe ──────────────────────────────────────────────────────
if [ ! -f "${manifest}" ]; then
  err "No existe ${manifest} — ¿estás corriendo esto fuera del repo del plugin?"
  exit 1
fi

# ── 2. Hay con qué parsear ────────────────────────────────────────────────────
# Sin parser NO se valida, y sin validar NO se publica. Se grita, no se saltea.
parser=""
if command -v jq >/dev/null 2>&1; then
  parser="jq"
elif command -v python3 >/dev/null 2>&1; then
  parser="python3"
else
  err "No hay jq ni python3: imposible validar el manifest. Instalá jq (brew install jq)."
  exit 1
fi

# ── 3. JSON parseable ─────────────────────────────────────────────────────────
if [ "${parser}" = "jq" ]; then
  parse_err="$(jq empty "${manifest}" 2>&1)" || { err "JSON inválido: ${parse_err}"; exit 1; }
else
  parse_err="$(python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "${manifest}" 2>&1)" \
    || { err "JSON inválido: ${parse_err}"; exit 1; }
fi
ok "JSON parseable (${parser})"

# ── 4. Normalización: name, version y toda ruta declarada ─────────────────────
# Salida esperada, una cosa por línea:
#   name<TAB><valor>
#   version<TAB><valor>
#   declared<TAB><clave><TAB><ruta>
if [ "${parser}" = "jq" ]; then
  normalized="$(jq -r '
    ["skills","agents","commands","hooks"] as $keys
    | "name\t"    + (.name    // ""),
      "version\t" + (.version // ""),
      ( $keys[] as $k
        | (if has($k) then .[$k] else empty end) as $v
        | (if   ($v|type) == "string" then [$v]
           elif ($v|type) == "array"  then $v
           else [] end)[]
        | select(type == "string")
        | "declared\t" + $k + "\t" + .
      ),
      ( if (.mcpServers|type) == "string" then "declared\tmcpServers\t" + .mcpServers else empty end )
  ' "${manifest}")"
else
  normalized="$(python3 - "${manifest}" <<'PY'
import json, sys
m = json.load(open(sys.argv[1]))
print("name\t%s"    % (m.get("name")    or ""))
print("version\t%s" % (m.get("version") or ""))
for k in ("skills", "agents", "commands", "hooks"):
    v = m.get(k)
    vs = [v] if isinstance(v, str) else (v if isinstance(v, list) else [])
    for p in vs:
        if isinstance(p, str):
            print("declared\t%s\t%s" % (k, p))
mcp = m.get("mcpServers")
if isinstance(mcp, str):
    print("declared\tmcpServers\t%s" % mcp)
PY
)"
fi

name="$(printf '%s\n'    "${normalized}" | awk -F'\t' '$1=="name"    {print $2; exit}')"
version="$(printf '%s\n' "${normalized}" | awk -F'\t' '$1=="version" {print $2; exit}')"

# ── 5. name y version ─────────────────────────────────────────────────────────
# Sin bump NO hay distribución: el cache de plugins es por versión.
[ -n "${name}" ] && ok "name: ${name}" || err "Falta la clave \`name\` (o está vacía)."

if [ -z "${version}" ]; then
  err "Falta la clave \`version\` (o está vacía)."
elif printf '%s' "${version}" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z.-]+)?$'; then
  ok "version: ${version} (semver válido)"
else
  err "version \"${version}\" no es semver válido (esperado MAJOR.MINOR.PATCH)."
fi

# ── 6. Rutas declaradas ───────────────────────────────────────────────────────
# (a) `hooks` NUNCA debe apuntar al estándar hooks/hooks.json — Claude Code lo carga
#     solo; declararlo no es redundante, es INVÁLIDO (este fue el bug de la v0.6.0).
# (b) toda ruta declarada tiene que existir en disco.
declared_count=0
while IFS=$'\t' read -r tag key path; do
  [ "${tag}" = "declared" ] || continue
  declared_count=$((declared_count + 1))

  norm="${path#\$\{CLAUDE_PLUGIN_ROOT\}/}"
  norm="${norm#./}"

  if [ "${key}" = "hooks" ] && [ "${norm}" = "hooks/hooks.json" ]; then
    err "\`hooks\` apunta al estándar hooks/hooks.json — Claude Code ya lo carga por convención."
    info "Declararlo rompe la carga del plugin entero (\`hooks: Invalid input\`)."
    info "Sacá la clave \`hooks\` del manifest; el archivo se sigue cargando igual."
    info "Solo se declaran archivos de hooks ADICIONALES."
    continue
  fi

  if [ -e "${root}/${norm}" ]; then
    ok "${key} → ${path} (existe)"
  else
    err "${key} declara \"${path}\" pero no existe en disco (${root}/${norm})."
  fi
done <<< "${normalized}"

[ "${declared_count}" -eq 0 ] && ok "Sin rutas declaradas que validar (hooks/, skills/ y commands/ se cargan por convención)."

# ── Veredicto ─────────────────────────────────────────────────────────────────
echo
if [ "${errors}" -gt 0 ]; then
  printf '❌ Manifest NO publicable: %s error(es). Arreglalo antes de releasear.\n' "${errors}" >&2
  exit 1
fi
printf '✅ Manifest publicable (v%s).\n' "${version}"
printf '   Gate manual que falta: correr `claude plugin list` sobre la versión candidata y exigir `✔ enabled`.\n'
exit 0
