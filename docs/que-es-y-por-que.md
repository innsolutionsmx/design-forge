# Qué es design-forge y por qué existe

## El problema que lo originó

Pedirle diseño frontend a un agente sin estructura produce dos fallas conocidas:

1. **AI slop**: interfaces genéricas sin identidad — porque el agente no tiene contexto
   de marca ni criterio contra el cual juzgarse.
2. **Saltar a implementar**: ante "mejorá el navbar", el agente toca código del
   proyecto sin que nadie haya visto ni comparado opciones. El dev termina imaginando
   en vez de eligiendo.

Además, el ecosistema de herramientas de diseño para agentes (Impeccable, SkillUI,
Stitch, Playwright MCP, etc.) creció rápido y desordenado: varias compiten por el
mismo rol y usarlas juntas sin criterio infla el contexto y produce consejos
contradictorios.

## Qué resuelve

design-forge estructura el trabajo de diseño en un **pipeline de 4 fases** donde cada
herramienta tiene SU lugar y ninguna decisión visual se toma sin evidencia:

```
0. CONTEXTO  →  1. IDEACIÓN  →  2. BUILD  →  3. CRÍTICA/TEST (loop)
PRODUCT.md      preview           código        critique + audit
DESIGN.md       comparativo       contra        + screenshots reales
(la ley)        explícito         DESIGN.md     → ¿pasa o itera?
```

Sus dos ideas centrales:

- **DESIGN.md es ley**: la fase 0 establece la verdad de la marca (tokens, tipografía,
  assets, viewport de referencia, contextos reales) y todo lo demás la obedece. Nada
  de colores inventados inline.
- **Preview comparativo explícito** (fase 1): ante un pedido sin diseño concreto, el
  entregable NO es código ni un render pelado — es una hoja comparativa con 2-3
  variaciones descritas (badge + título + chip de estado + tradeoff), cada una
  montada en sus contextos reales, renderizada al ancho real. Se elige con los ojos,
  ANTES de tocar el proyecto. Siempre incluye una dirección fresca propia además de
  la literal pedida.

## Qué NO resuelve (a propósito)

- **El workflow de git/sesiones**: eso es de
  [inns-ai-flow](https://github.com/innsolutionsmx/inns-ai-flow) (este repo lo usa).
- **Ser el cerebro de diseño**: el criterio de crítica es de
  [Impeccable](https://github.com/pbakaus/impeccable) — design-forge lo ORQUESTA, no
  lo reemplaza. Regla de oro: un solo cerebro de diseño (no convive con UI/UX Pro Max
  ni Taste).
- **Implementar por vos**: la fase 2 escribe código, pero solo después de que la
  fase 1 produjo una decisión con evidencia.

## Cómo funciona por dentro

- **Comandos** (`/design-forge:init|ideate|build|review|doctor`): cada fase es un
  comando con su procedimiento. `doctor` diagnostica prerequisitos y detecta cerebros
  de diseño en conflicto.
- **Skill de doctrina** (`design-pipeline`): 10 hard rules que se auto-cargan en
  cualquier tarea de UI del proyecto — aunque no invoques ningún comando. Ahí viven
  "DESIGN.md es ley", "never a bare render", "the preview must not lie", el loop
  acotado a 3 iteraciones, etc.
- **Playwright MCP bundleado**: la evidencia visual (screenshots reales en viewports
  reales) viene incluida con el plugin; con fallback a Chrome headless si falta.
- **Ideación in-place (sin worktrees por defecto)**: las variaciones se construyen sobre
  el checkout actual — rutas de preview temporales servidas por el dev stack vivo
  (Docker/Vite/HMR real), o mockups HTML autocontenidos en un subdir gitignored cuando no
  hay stack. Un worktree hermano sería invisible al HMR y rompería el preview vivo; solo
  se crea bajo orden explícita (paralelismo real). Las variaciones no elegidas son
  efímeras y se limpian en el teardown.

El pipeline evoluciona por evidencia: cada corrida real en un proyecto deja gotchas
(ver `design/design-forge-gotchas.md` del primer dogfood en landing-crb) que vuelven
al plugin como reglas. Así nació el preview comparativo, el viewport de referencia,
el inventario de assets de marca y media doctrina actual.
