# Referencia

Cada comando arranca declarando su versión (`design-forge 1.0.0 · <comando>`) en su
primera respuesta: así sabés qué versión se cargó de verdad, sin leer JSON.

## Comandos

### `/design-forge:init [url-de-marca]`
Fase 0 — Contexto. Produce `PRODUCT.md` y `DESIGN.md` (la ley del proyecto) por una
de tres vías: URL de marca del cliente (SkillUI extrae tokens/fonts/screenshots),
docs internos existentes (consolida, no rediseña), o desde cero (impeccable init +
opcionalmente un DESIGN.md de referencia de awesome-design-md). Además: inventario de
assets de marca (con "asset pendiente" para lo que falta — el repo NO es la verdad de
la marca), viewports de referencia del usuario — el mobile como **rango**: alto útil/fold
(barra desplegada) Y alto del dispositivo, medidos en el teléfono real, no estimados —,
contextos reales (hero oscuro, secciones claras…). Cierra commiteando ambos archivos.

### `/design-forge:replicate [captura y/o URL + dónde va]`
El flujo principal. Le pasás la captura de un diseño que encontraste (y la URL si la
tenés) y lo construye **1:1 en tu proyecto, con tus assets**, sin que tengas que pedirlo:
1. **Intake**: referencia + destino; baseline si reemplaza una sección existente. Por
   defecto copia layout, proporciones, ritmo de espaciado, escala tipográfica, jerarquía y
   efectos; colores y familias tipográficas salen de DESIGN.md (salvo que pidas copiarlos).
2. **Lectura de la referencia**: con URL, la abre con Playwright para ver hovers, reveals y
   carruseles, y ofrece SkillUI para sacar valores exactos. Si la captura sugiere un efecto
   que no muestra, propone uno con su fuente ("encontré este carrusel en…").
3. **Mapa de assets**: tabla asset de la referencia → asset del proyecto o `pendiente`
   (placeholder neutro del mismo tamaño). **Nunca** usa, recorta ni enlaza los assets de la
   referencia.
4. **Build 1:1** directo en el proyecto, mobile incluido; abanico de `object-position` para
   las fotos en `object-cover`.
5. **Hoja de preview** en `design/preview/` (gitignored): referencia al lado del resultado,
   en desktop, mobile estado fold, mobile estado dispositivo y frame de transición.
6. **Verificación**: UN subagente adversarial ("asumí que está roto") que corre los gates
   medibles y compara contra la referencia sección por sección. Devuelve solo texto; máximo
   3 rondas; cada ronda queda en `design/verificaciones.md`.
7. **Show** sobre la URL viva, solo después de un `go`.
8. **Cierre**: pregunta antes de correr el review, actualiza DESIGN.md y borra
   `design/preview/` sin archivar.

### `/design-forge:build [qué]`
UI sin referencia que copiar. Implementa contra DESIGN.md (tokens only, mobile-first,
accesibilidad desde el inicio, estados empty/loading/error). Las librerías de componentes
son inspiración, no dependencias: muestra de dónde sacó un patrón y lo adapta a los
tokens; solo reutiliza una librería si el proyecto ya la usa. Al terminar pregunta si
corre el review.

### `/design-forge:review [url]`
Loop de crítica (máx 3 iteraciones), **solo cuando dijiste que sí**. Le pasa a Impeccable
la sección, su objetivo, DESIGN.md y —si viene de `replicate`— la referencia y las
divergencias que aceptaste. Evidencia: critique + audit, capturas en `design/preview/captures/`
a los viewports de DESIGN.md con device emulation — **desktop Y mobile en sus dos
alturas** —, interacciones ejercitadas, consola revisada. Veredicto PASA (→ polish +
harden) o ITERA, con gate de mobile bloqueante. Tras 3 fallos reporta el problema
estructural.

### `/design-forge:doctor`
Diagnóstico: Impeccable (requerido), Playwright MCP, servidor HTTP estático (y `jq`,
`python3` o `node` para el hook), fallback Chrome headless, SkillUI y webgpu (opcionales),
PRODUCT/DESIGN.md completos (viewport mobile como RANGO), **cerebros de diseño en
conflicto** (UI/UX Pro Max, Taste, frontend-design → warning) e **higiene del preview**
(`.gitignore` y capturas sueltas). La validación del manifest NO vive acá: es el gate de
release del repo del plugin (`scripts/validate-manifest.sh` + hook local).

## Skill de doctrina: `design-pipeline`

Se auto-carga en cualquier tarea de UI del proyecto. Contiene el mapa de fases, el
workflow canónico y 11 hard rules:

1. DESIGN.md es ley.
2. **Nunca usar los assets de la referencia** — se mapean a assets del proyecto o a
   placeholders `pendiente`.
3. **1:1 es 1:1** — estructura y efectos de la referencia, colores y fuentes de DESIGN.md
   salvo pedido; las divergencias se reportan.
4. Un solo cerebro de diseño (Impeccable).
5. Sin preview no hay implementación — el veredicto es tuyo, sobre la URL viva.
6. **El preview no puede mentir** — un verificador adversarial con viewport real (device
   emulation, `clientWidth` = ancho objetivo), header en reposo, gate de overflow, fold
   medido en números, fidelidad y jerarquía vs la referencia; capturas en cuarentena;
   registro de cada ronda.
7. Mobile es de primera clase y es un rango (alto útil y alto del dispositivo); el
   presupuesto vertical es el alto útil.
8. Review solo con un sí; acotado a 3 iteraciones.
9. Las capturas tienen casa (`design/preview/captures/`) y las corridas no dejan residuos.
10. Las librerías son inspiración, no dependencias.
11. El repo no es la verdad de la marca, y los efectos se ganan su lugar.

## MCP bundleado

**Playwright** (`@playwright/mcp@0.0.83`, versión fija — `@latest` cambiaba solo) — viaja
con el plugin, cero config: navegación, screenshots, device emulation, interacciones.
Fallback sin él: `chrome --headless=new --screenshot=out.png --window-size=W,H <url>`.

## Hooks bundleados

**Disciplina de preview** (`UserPromptSubmit`, `hooks/preview-discipline.sh`) — viaja
con el plugin, cero config. Cuando un prompt huele a trabajo visual re-inyecta el
recordatorio: referencia → `replicate` (1:1, assets del proyecto, preview referencia vs
resultado); sin referencia → `build` con preview; en ambos, desktop y mobile verificados y
preguntar antes del review. Salta con señales fuertes (diseñ-, 1:1, captura, referencia,
mockup…) o con un objeto de UI junto a un verbo de cambio ("agrega un carrusel al hero");
ya no con palabras sueltas como `build` o `page`. Lee el prompt con `jq`, `python3` o
`node` —antes dependía de `jq` y sin él nunca disparaba—, y ante cualquier falla sale en
silencio. Tests: `bash tests/preview-discipline.test.sh`.

## Prerequisitos externos (ver README para instalación)

| Herramienta | Rol | ¿Obligatoria? |
|-------------|-----|---------------|
| Impeccable | Cerebro de diseño (init, critique, audit, polish, harden) | Sí |
| SkillUI | Extraer valores exactos de una URL (marca en init, referencia en replicate) | Opcional |
| webgpu-claude-skill | Shaders para héroes/motion | Opcional |
