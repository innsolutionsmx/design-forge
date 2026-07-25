#!/usr/bin/env bash
# UserPromptSubmit hook (BUNDLEADO en el plugin — se activa en cualquier proyecto
# con design-forge instalado). Re-inyecta la disciplina de PREVIEW en cada prompt
# que huela a decisión visual, para que no se pierda en la compactación.
#
# Reparto (mejora #2): el hook RECUERDA la disciplina; el MODELO percibe la imagen.
# Los adjuntos NO llegan al payload del hook (verificado contra doc oficial), así que
# no intentamos "ver" la referencia — sólo disparamos por señales textuales de trabajo
# visual y dejamos que el modelo, que sí ve el adjunto, decida qué preview aplica.
#
# Defensivo por diseño: ante cualquier falla salimos 0 sin inyectar nada. Un hook
# NUNCA debe bloquear ni romper el prompt del usuario.
set -uo pipefail

# Sin jq no parseamos el payload de forma segura → no molestamos.
command -v jq >/dev/null 2>&1 || exit 0

payload="$(cat 2>/dev/null || true)"
prompt="$(printf '%s' "${payload}" | jq -r '.prompt // empty' 2>/dev/null || true)"
[ -n "${prompt}" ] || exit 0

# Señales de trabajo visual (umbral BAJO a propósito: preferimos un falso positivo
# —algo de ruido— antes que un falso negativo —saltear el preview cuando importaba—).
# Bilingüe: el plugin se usa en proyectos ES e EN.
signals=(
  # verbos de creación/cambio visual
  'diseñ' 'rediseñ' 'maquet' 'estiliz' 'implementá' 'construí' 'armá' 'mejorá'
  'design' 'redesign' 'build' 'restyle' 'revamp' 'mockup'
  # objetos de UI
  'navbar' 'hero' 'header' 'footer' 'landing' 'sección' 'seccion' 'section'
  'componente' 'component' 'layout' 'card' 'botón' 'boton' 'button' 'modal'
  'menú' 'menu' 'interfaz' 'pantalla' 'screen' 'página' 'pagina' ' page' 'ui '
  # señales de referencia/asset visual
  'referencia' 'reference' 'figma' 'captura' 'screenshot' 'adjunt' 'attach'
  'imagen' 'image' ' foto' 'object-cover' 'encuadre' '.png' '.jpg' '.jpeg'
  '.webp' '.svg'
)

matched=0
shopt -s nocasematch
for kw in "${signals[@]}"; do
  if [[ "${prompt}" == *"${kw}"* ]]; then matched=1; break; fi
done
shopt -u nocasematch

[ "${matched}" -eq 1 ] || exit 0

read -r -d '' context <<'EOF' || true
design-forge · DISCIPLINA DE PREVIEW: este pedido parece implicar una decisión visual.
No vayas directo al código — ofrecé el preview que corresponda ANTES de finalizar:
• Idea/dirección abierta → variaciones comparativas (A/B/C, formato explícito, hard rule 9).
• Referencia concreta (mockup/spec/imagen adjunta) → preview de FIDELIDAD: construí y
  mostrá el resultado vs la referencia en desktop Y mobile, confirmá el match (hard rule 9).
• Asset/foto a colocar (object-cover) → preview de encuadre (abanico de object-position).
El preview es la red que atrapa la divergencia entre lo pedido y lo construido; se pierde
si dependés de acordarte. Si claramente NO es una tarea de diseño, ignorá este recordatorio.
EOF

jq -n --arg ctx "${context}" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'

exit 0
