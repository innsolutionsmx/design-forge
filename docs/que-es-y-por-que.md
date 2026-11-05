# Qué es design-forge y por qué existe

## El problema que lo originó

Pedirle diseño frontend a un agente sin estructura produce dos fallas conocidas:

1. **AI slop**: interfaces genéricas sin identidad — porque el agente no tiene contexto
   de marca ni criterio contra el cual juzgarse.
2. **Saltar a implementar**: ante "mejorá el navbar", el agente toca código del
   proyecto sin que nadie haya visto ni comparado opciones. El dev termina imaginando
   en vez de eligiendo.

Además, el ecosistema de herramientas de diseño para agentes (Impeccable, SkillUI,
Playwright MCP, etc.) creció rápido y desordenado: varias compiten por el
mismo rol y usarlas juntas sin criterio infla el contexto y produce consejos
contradictorios.

## Qué resuelve

design-forge estructura el trabajo de diseño en un pipeline corto donde cada herramienta
tiene SU lugar y ninguna decisión visual se toma sin evidencia:

```
0. CONTEXTO  →  1. REPLICATE (1:1)        →  2. REVIEW (si decís sí)
PRODUCT.md      captura → assets propios      critique + audit
DESIGN.md       → preview verificado          + screenshots reales
(la ley)        referencia vs resultado       → ¿pasa o itera?
```

Sus ideas centrales:

- **DESIGN.md es ley**: la fase 0 establece la verdad de la marca (tokens, tipografía,
  assets, viewports, contextos reales) y todo lo demás la obedece.
- **La referencia manda en el diseño, el proyecto en los assets**: la forma más clara de
  pedirle diseño a un agente es mostrarle una imagen. `replicate` la copia 1:1 sin que lo
  pidas, pero con los assets de tu proyecto — nunca los de la captura, que son de otro sitio.
- **El preview no puede mentir**: antes de que lo veas, un verificador adversarial lo mide
  (overflow, fold, header, fidelidad, jerarquía) en desktop y mobile. Vos decidís sobre la
  URL viva.

> Hasta 0.8.0 la fase 1 era `ideate`: 2-3 variantes comparativas con doble verificación.
> En 1.0.0 se quitó porque gastaba muchos tokens y el flujo real pasó a ser la réplica de
> una referencia.

## Qué NO resuelve (a propósito)

- **El workflow de git/sesiones**: eso es de
  [inns-ai-flow](https://github.com/innsolutionsmx/inns-ai-flow) (este repo lo usa).
- **Ser el cerebro de diseño**: el criterio de crítica es de
  [Impeccable](https://github.com/pbakaus/impeccable) — design-forge lo ORQUESTA, no
  lo reemplaza. Regla de oro: un solo cerebro de diseño (no convive con UI/UX Pro Max
  ni Taste).
- **Decidir por vos**: escribe código, pero el veredicto es tuyo sobre la URL viva, y el
  review corre solo si lo pedís.

## Cómo funciona por dentro

- **Comandos** (`/design-forge:init|replicate|build|review|doctor`): cada fase es un
  comando con su procedimiento. `doctor` diagnostica prerequisitos y detecta cerebros
  de diseño en conflicto.
- **Skill de doctrina** (`design-pipeline`): 11 hard rules que se auto-cargan en
  cualquier tarea de UI del proyecto — aunque no invoques ningún comando. Ahí viven
  "DESIGN.md es ley", "never a bare render", "the preview must not lie", el loop
  acotado a 3 iteraciones, etc.
- **Playwright MCP bundleado**: la evidencia visual (screenshots reales en viewports
  reales) viene incluida con el plugin; con fallback a Chrome headless si falta.
- **Preview in-place y efímero**: la hoja de preview vive en `design/preview/`
  (gitignored), servida por el dev stack vivo o por un servidor HTTP estático; al aprobar
  se borra sin archivar. Solo queda `design/verificaciones.md`, el registro de lo que
  atrapó el verificador.

El pipeline evoluciona por evidencia: cada corrida real en un proyecto deja gotchas
(ver `design/design-forge-gotchas.md` del primer dogfood en landing-crb) que vuelven
al plugin como reglas. Así nació el preview comparativo, el viewport de referencia,
el inventario de assets de marca y media doctrina actual.
