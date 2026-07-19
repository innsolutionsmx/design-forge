# Referencia

## Comandos

### `/design-forge:init [url-de-marca]`
Fase 0 — Contexto. Produce `PRODUCT.md` y `DESIGN.md` (la ley del proyecto) por una
de tres vías: URL de marca del cliente (SkillUI extrae tokens/fonts/screenshots),
docs internos existentes (consolida, no rediseña), o desde cero (impeccable init +
opcionalmente un DESIGN.md de referencia de awesome-design-md). Además: inventario de
assets de marca (con "asset pendiente" para lo que falta — el repo NO es la verdad de
la marca), viewport de referencia del usuario, contextos reales (hero oscuro,
secciones claras…). Cierra commiteando ambos archivos.

### `/design-forge:ideate [brief]`
Fase 1 — Ideación. Router: diseño concreto → build directo; sin diseño → preview
comparativo. Baseline de la sección real primero. 2-3 variaciones (una fresca propia
obligatoria) construidas **in-place** — rutas de preview temporales en el dev stack vivo,
o mockups HTML autocontenidos en un subdir gitignored; sin worktrees por defecto (solo
bajo orden explícita). Entregable: **preview sheet** — badge de caso + título + chip de
estado + descripción con tradeoff + frames por contexto real con badge legible/ilegible,
al ancho real del target. Render verificado visualmente antes de mostrarse; veredicto del
usuario sobre la URL viva. Los previews no elegidos son efímeros (se limpian en teardown).

### `/design-forge:build [qué]`
Fase 2 — Build. Implementa contra DESIGN.md (tokens only, mobile-first, accesibilidad
desde el inicio, estados empty/loading/error). Componentes de producción antes que
custom (21st.dev/shadcn); efectos WebGPU solo donde se justifican y con fallbacks.

### `/design-forge:review [url]`
Fase 3 — Loop de crítica (máx 3 iteraciones). Evidencia: impeccable critique + audit,
screenshots a los viewports de DESIGN.md — **desktop Y mobile, ambos obligatorios**
(scroll-through previo para disparar reveals), interacciones ejercitadas, consola
revisada. Veredicto PASA (→ impeccable polish + harden como ship gate) o ITERA (fix list
priorizada) — con **gate de mobile bloqueante: sin evidencia mobile o con composición
mobile rota nunca PASA**. Tras 3 fallos: reporta el problema estructural y a qué fase
volver.

### `/design-forge:doctor`
Diagnóstico: Impeccable (requerido), Playwright MCP, servidor HTTP estático, fallback
Chrome headless, SkillUI/Stitch/21st.dev/webgpu (opcionales), PRODUCT/DESIGN.md
completos, **detección de cerebros de diseño en conflicto** (UI/UX Pro Max, Taste,
frontend-design → warning), y **aviso de worktrees `idea/*` viejos** sin cerrar
(sugiere `/design-forge:teardown`).

## Skill de doctrina: `design-pipeline`

Se auto-carga en cualquier tarea de UI del proyecto. Contiene el mapa de fases, el
workflow canónico (cambios quirúrgicos por sección) y 10 hard rules; las claves:

1. DESIGN.md es ley — sin tokens inventados inline.
2. Un solo cerebro de diseño (Impeccable).
3. Evidencia sobre opinión — en la pantalla del USUARIO (viewport de referencia,
   veredicto sobre URL viva).
4. Loop acotado a 3 iteraciones.
5. Los efectos se ganan su lugar (y siempre con fallback reduced-motion/no-WebGPU).
6. Componentes antes que custom.
7. El repo no es la verdad de la marca — vale el inventario de assets.
8. Presupuesto vertical desde v1 (`clamp()`, `100svh`, fold intencional).
9. **Never a bare render** — formato comparativo explícito + variación fresca siempre.
10. **The preview must not lie** — verificación visual del render, especificidad CSS
    (`a.nav-cta`, no `.nav-cta`), ancho real.

## MCP bundleado

**Playwright** (`@playwright/mcp`) — viaja con el plugin, cero config: navegación,
screenshots, snapshot de accesibilidad, interacciones. Fallback sin él:
`chrome --headless=new --screenshot=out.png --window-size=W,H <url>`.

## Prerequisitos externos (ver README para instalación)

| Herramienta | Rol | ¿Obligatoria? |
|-------------|-----|---------------|
| Impeccable | Cerebro de diseño (init, critique, audit, polish, harden) | Sí |
| SkillUI | Extraer design system de URL de cliente | Solo con marca existente |
| Stitch skills | Conceptos visuales en ideación | Opcional |
| 21st.dev Magic | Componentes de producción | Opcional (API key) |
| webgpu-claude-skill | Shaders para héroes/motion | Opcional |
