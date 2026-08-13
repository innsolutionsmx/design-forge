# Referencia

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

### `/design-forge:ideate [brief]`
Fase 1 — Ideación. Router: diseño concreto → build directo; sin diseño → preview
comparativo. Baseline de la sección real primero. 2-3 variaciones (una fresca propia
obligatoria) construidas **in-place** — rutas de preview temporales en el dev stack vivo,
o mockups HTML autocontenidos en un subdir gitignored; sin worktrees por defecto (solo
bajo orden explícita). Entregable: **preview sheet** — badge de caso + título + chip de
estado + descripción con tradeoff + frames por contexto real con badge legible/ilegible,
al ancho real del target. **Mobile rinde SIEMPRE dos frames** (estado fold y estado
dispositivo, con la marca del fold en el segundo) y el verificador reporta los elementos
decisivos medidos contra el fold + el diff entre estados — 12px de aire no se ven a ojo.
Render verificado visualmente antes de mostrarse; veredicto del
usuario sobre la URL viva. Al elegir ganadora: **pase de pulido opcional** — UN solo
`/impeccable:critique` sobre el ganador (sin audit, sin loop — eso es fase 3), fixes
aplicados como delta sobre los archivos ya construidos (snapshot previo como rollback,
jamás rebuild), re-verificación con el contrato del paso 7 y antes/después en URL viva;
el usuario decide aplicar o descartar. Los previews no elegidos son efímeros (se limpian
en teardown).

### `/design-forge:build [qué]`
Fase 2 — Build. Implementa contra DESIGN.md (tokens only, mobile-first, accesibilidad
desde el inicio, estados empty/loading/error). Componentes de producción antes que
custom (21st.dev/shadcn); efectos WebGPU solo donde se justifican y con fallbacks.

### `/design-forge:review [url]`
Fase 3 — Loop de crítica (máx 3 iteraciones). Evidencia: impeccable critique + audit,
screenshots a los viewports de DESIGN.md — **desktop Y mobile, ambos obligatorios**
(scroll-through previo para disparar reveals), interacciones ejercitadas, consola
revisada. Veredicto PASA (→ impeccable polish + harden como ship gate) o ITERA (fix list
priorizada) — con **gate de mobile bloqueante: sin evidencia mobile, con evidencia en UNA
sola altura de viewport, o con composición mobile rota nunca PASA**. Tras 3 fallos:
reporta el problema estructural y a qué fase volver.

### `/design-forge:doctor`
Diagnóstico: Impeccable (requerido), Playwright MCP, servidor HTTP estático, fallback
Chrome headless, SkillUI/Stitch/21st.dev/webgpu (opcionales), PRODUCT/DESIGN.md
completos (incluido el viewport mobile registrado como RANGO, no como número),
**detección de cerebros de diseño en conflicto** (UI/UX Pro Max, Taste,
frontend-design → warning) y **aviso de worktrees `idea/*` viejos** sin cerrar
(sugiere `/design-forge:teardown`). La validación del manifest NO vive acá: es el gate
de release del repo del plugin (`scripts/validate-manifest.sh` + hook local).

## Skill de doctrina: `design-pipeline`

Se auto-carga en cualquier tarea de UI del proyecto. Contiene el mapa de fases, el
workflow canónico (cambios quirúrgicos por sección) y 11 hard rules; las claves:

1. DESIGN.md es ley — sin tokens inventados inline.
2. Un solo cerebro de diseño (Impeccable).
3. Evidencia sobre opinión — en la pantalla del USUARIO (viewport de referencia,
   veredicto sobre URL viva).
4. Loop acotado a 3 iteraciones.
5. Los efectos se ganan su lugar (y siempre con fallback reduced-motion/no-WebGPU).
6. Componentes antes que custom.
7. El repo no es la verdad de la marca — vale el inventario de assets.
8. Presupuesto vertical desde v1 (`clamp()`, `100svh`, fold intencional) — en mobile el
   presupuesto es el **alto útil**, nunca el del dispositivo: difieren ~12%.
9. **Never a bare render** — formato comparativo explícito + variación fresca siempre.
   El preview cumple DOS funciones (decidir dirección Y verificar fidelidad); con diseño
   concreto se saltean las variaciones, nunca el preview de fidelidad.
10. **The preview must not lie** — verificación visual del render, especificidad CSS
    (`a.nav-cta`, no `.nav-cta`), ancho real. La verificación es QA interno: se DELEGA a un
    subagente que devuelve veredicto `legible`/`ilegible` en texto; los screenshots quedan
    en cuarentena y no contaminan al orquestador (ideate paso 7). Un verificador pasivo hace
    rubber-stamp: el overflow horizontal se caza determinísticamente (`scrollWidth >
    clientWidth`) y todo `go` debe sobrevivir un pase adversarial de refutación. Renderizá
    mobile al ancho REAL — headless `--window-size` clampea `innerWidth` a ~500 y recorta
    (clips falsos); usá Playwright o un iframe de ancho forzado. Si gate y ojo discrepan,
    gana el gate.
11. **Mobile is first-class, y una sola altura NO es evidencia mobile** — el viewport
    mobile es un RANGO que cambia en runtime: DESIGN.md registra alto útil/fold (barra
    desplegada) Y alto del dispositivo. Cada fase con evidencia visual renderiza desktop Y
    mobile, y mobile en sus DOS estados (iframe al alto que se está renderizando, así `svh`
    resuelve como en el teléfono) reportando los elementos decisivos medidos contra el fold
    y su diff entre estados; review FALLA (ITERA, nunca PASA) sin evidencia mobile, con
    evidencia en una sola altura, o con composición mobile rota.

## MCP bundleado

**Playwright** (`@playwright/mcp`) — viaja con el plugin, cero config: navegación,
screenshots, snapshot de accesibilidad, interacciones. Fallback sin él:
`chrome --headless=new --screenshot=out.png --window-size=W,H <url>`.

## Hooks bundleados

**Disciplina de preview** (`UserPromptSubmit`, `hooks/preview-discipline.sh`) — viaja
con el plugin, cero config. Cuando un prompt huele a decisión visual (construir/cambiar
UI, traer una referencia, colocar un asset), re-inyecta un recordatorio de la disciplina
de preview: idea abierta → variaciones; referencia concreta → preview de fidelidad; asset
→ preview de encuadre. Vive como hook —no como preferencia— porque una preferencia se
pierde en la compactación y un hook se re-inyecta en cada prompt. El hook solo RECUERDA:
no ve el adjunto de imagen (no llega a su payload), lo percibe el modelo. Es no-invasivo
—dispara condicional a señales textuales y ante cualquier falla sale en silencio (nunca
bloquea el prompt)—; si el pedido no es de diseño, se ignora.

## Prerequisitos externos (ver README para instalación)

| Herramienta | Rol | ¿Obligatoria? |
|-------------|-----|---------------|
| Impeccable | Cerebro de diseño (init, critique, audit, polish, harden) | Sí |
| SkillUI | Extraer design system de URL de cliente | Solo con marca existente |
| Stitch skills | Conceptos visuales en ideación | Opcional |
| 21st.dev Magic | Componentes de producción | Opcional (API key) |
| webgpu-claude-skill | Shaders para héroes/motion | Opcional |
