# Casos de uso

## 1. Rediseño de una sección existente (el caso más común)

El caso real que definió el pipeline: "quiero mejorar el navbar" en landing-crb.

1. `/design-forge:ideate mejorar el navbar` → el router detecta que NO hay diseño
   concreto → modo preview comparativo.
2. Baseline: screenshot del navbar REAL al viewport de referencia (el "antes").
3. El agente propone 3 direcciones — la fiel a lo pedido, y al menos una fresca
   propia (ej: navbar "isla flotante" tipo Linear) — cada una con nombre, tesis,
   tradeoff y chip (`Recomendado` / `Variación fresca` / `Riesgo`).
4. Mockups HTML autocontenidos en worktrees, con los tokens reales de DESIGN.md y
   los assets reales del repo.
5. **Preview sheet**: una página con las 3 variaciones — badge A/B/C, descripción,
   y cada una montada sobre el hero oscuro Y la página clara, con badge
   legible/ilegible. Renderizada al ancho real (nunca columnas angostas).
6. Elegís con los ojos sobre la URL viva. Iteración v2, v3 sobre la que reaccionaste.
7. Con "esta es": fase 2 la implementa en el proyecto real, en rama `feat/*`.

## 2. Tengo un diseño concreto — implementalo

Le pasás el mockup/spec exacto → el router de `ideate` lo detecta y va DIRECTO a
`/design-forge:build`. Cero variaciones: generar alternativas contra un diseño ya
decidido es ruido.

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

1. `/design-forge:review http://localhost:3000` → critique + audit de Impeccable +
   screenshots reales en los viewports de referencia + interacciones ejercitadas.
2. Veredicto por iteración: PASA (→ polish + harden y ship) o ITERA (fix list
   concreta y de vuelta).
3. El loop está ACOTADO a 3 iteraciones: si a la tercera no pasa, el problema es
   estructural (fase 0 o 1 mal resuelta) y el comando te lo dice en vez de churnear.

## 6. Un compañero necesita el pipeline en su proyecto

Le pasás una línea: "pegale esto a tu Claude → *Lee https://raw.githubusercontent.com/innsolutionsmx/design-forge/main/SETUP.md y ejecuta el setup*".
Su agente hace todo (merge seguro de settings, prerequisitos, pasos finales). El
README del repo también redirige a cualquier LLM que aterrice ahí.

## 7. El pipeline falló en algo — mejorarlo

Todo gotcha de una corrida real se documenta (patrón: `design/design-forge-gotchas.md`
en el proyecto) y vuelve al plugin como regla o paso nuevo. Ver
`desarrollo-y-releases.md`.
