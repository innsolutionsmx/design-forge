#!/usr/bin/env bash
# UserPromptSubmit hook (bundled with the plugin — active in every project that has
# design-forge installed). Re-injects the preview discipline on prompts that look like
# visual work, so it survives compaction.
#
# Split of duties: the hook REMINDS; the model, which sees any attached image, decides.
# Attachments don't reach the hook payload, so we only match textual signals.
#
# Defensive by design: on any failure, exit 0 without injecting. A hook must never block
# or break the user's prompt. No hard dependency on jq: it used to require jq, and on a
# machine without it the reminder silently never fired.
set -uo pipefail

payload="$(cat 2>/dev/null || true)"
[ -n "${payload}" ] || exit 0

extract_prompt() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "${payload}" | jq -r '.prompt // empty' 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "${payload}" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("prompt") or "")
except Exception: pass' 2>/dev/null
  elif command -v node >/dev/null 2>&1; then
    printf '%s' "${payload}" | node -e 'let d="";process.stdin.on("data",c=>d+=c).on("end",()=>{try{process.stdout.write(JSON.parse(d).prompt||"")}catch(e){}})' 2>/dev/null
  fi
}

prompt="$(extract_prompt || true)"
[ -n "${prompt}" ] || exit 0

# Strong signals: on their own they mean visual design work.
strong=(
  'diseñ' 'disen' 'maquet' 'estiliz' 'uno a uno' '1:1' 'idéntic' 'identic' 'replic'
  'design' 'restyle' 'revamp' 'mockup' 'look like' 'se vea como'
  'captura' 'screenshot' 'referencia' 'reference' 'figma'
  '.png' '.jpg' '.jpeg' '.webp' 'object-cover' 'encuadre'
)
# UI objects: only count together with a creation/change verb.
objects=(
  'navbar' 'hero' 'header' 'footer' 'landing' 'sección' 'seccion' 'section'
  'componente' 'component' 'layout' 'card' 'tarjeta' 'botón' 'boton' 'button' 'modal'
  'carrusel' 'carousel' 'slider' 'pantalla' 'screen' 'vista' 'view' 'interfaz'
)
verbs=(
  'haz ' 'hazme' 'hacé' 'crea' 'creá' 'arma' 'armá' 'construí' 'construye' 'implementa'
  'implementá' 'agrega' 'agregá' 'añade' 'mejora' 'mejorá' 'cambia' 'cambiá' 'rehaz'
  'make' 'create' 'add ' 'improve' 'redo' 'style'
)

has_any() { # needle-array-name -> 0 if the prompt contains any needle
  local -n list="$1"
  local kw
  for kw in "${list[@]}"; do
    [[ "${prompt}" == *"${kw}"* ]] && return 0
  done
  return 1
}

shopt -s nocasematch
matched=1
if has_any strong; then
  matched=0
elif has_any objects && has_any verbs; then
  matched=0
fi
shopt -u nocasematch

[ "${matched}" -eq 0 ] || exit 0

# Plain stdout on exit 0 is added to the prompt's context by UserPromptSubmit.
cat <<'EOF'
design-forge · DISCIPLINA DE PREVIEW: este pedido parece implicar una decisión visual.
• Referencia (captura/URL de un diseño encontrado) → /design-forge:replicate: 1:1 con los
  assets DEL PROYECTO — nunca los de la referencia — y preview referencia vs resultado.
• Sin referencia → /design-forge:build, y preview antes de finalizar.
• En ambos: desktop Y mobile (las dos alturas), verificado antes de mostrarlo, y preguntá
  antes de correr /design-forge:review.
Si claramente NO es una tarea de diseño, ignorá este recordatorio.
EOF

exit 0
