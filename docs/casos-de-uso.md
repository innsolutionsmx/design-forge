# Casos de uso

## 1. Encontré un diseño que me gusta — ponelo en mi proyecto (el caso más común)

1. Adjuntás la captura (y la URL si la tenés): `/design-forge:replicate quiero este
   carrusel en la home, en lugar del actual`.
2. Baseline: captura de la sección real (el "antes").
3. Mapa de assets: cada foto, logo e ícono de la referencia se mapea a uno de tu
   proyecto; lo que falte queda `pendiente` con un placeholder neutro. Nunca se usan los
   assets de la captura: son de otro sitio.
4. Build 1:1 directo en el proyecto: estructura, proporciones y efectos de la referencia;
   colores y fuentes de tu DESIGN.md (salvo que pidas copiarlos).
5. Hoja de preview: la referencia al lado del resultado, en desktop, mobile (las dos
   alturas) y con la sección anterior visible.
6. Un subagente verificador la revisa asumiendo que algo está roto (overflow, fold, header,
   fidelidad, jerarquía, assets). Recién con su `go` la ves, sobre la URL viva.
7. Iterás hasta que quede. Al aprobar: "¿corro el review?" — vos decidís.

## 2. Quiero algo nuevo, sin referencia

`/design-forge:build hero con formulario de contacto` → implementa contra DESIGN.md,
mobile incluido, con preview antes de finalizar. Si un patrón ayuda (un carrusel, un
mega-menú), te muestra dónde lo encontró en vez de meter una librería.

## 3. Proyecto nuevo de un cliente con marca existente

1. `/design-forge:init https://sitio-del-cliente.com` → SkillUI extrae tokens,
   tipografía, spacing y screenshots reales → se consolidan en DESIGN.md.
2. El init además inventaría assets de marca (y lista los que faltan como "asset
   pendiente"), registra el viewport de referencia y los contextos reales.
3. De ahí en más, todo el frontend del proyecto se construye y se juzga contra ese
   DESIGN.md.

## 4. Proyecto con design system interno (docs en el repo)

`/design-forge:init` detecta docs existentes (`design-system.md`, tailwind config con
tokens, etc.) y CONSOLIDA — no rediseña ni inventa tokens que contradigan lo que hay.

## 5. Verificar que el diseño implementado está bien de verdad

1. `/design-forge:review http://localhost:3000` (o un "sí" cuando `replicate`/`build`
   te pregunta) → critique + audit de Impeccable con contexto +
   screenshots reales en los viewports de referencia + interacciones ejercitadas.
2. Veredicto por iteración: PASA (→ polish + harden y ship) o ITERA (fix list
   concreta y de vuelta).
3. El loop está ACOTADO a 3 iteraciones: si a la tercera no pasa, el problema es
   estructural (DESIGN.md incoherente o una referencia que choca con la marca) y el comando te lo dice en vez de churnear.

## 6. Un compañero necesita el pipeline en su proyecto

Le pasás una línea: "pegale esto a tu Claude → *Lee https://raw.githubusercontent.com/innsolutionsmx/design-forge/main/SETUP.md y ejecuta el setup*".
Su agente hace todo (merge seguro de settings, prerequisitos, pasos finales). El
README del repo también redirige a cualquier LLM que aterrice ahí.

## 7. El pipeline falló en algo — mejorarlo

Todo gotcha de una corrida real se documenta (patrón: `design/design-forge-gotchas.md`
en el proyecto) y vuelve al plugin como regla o paso nuevo. Ver
`desarrollo-y-releases.md`.
