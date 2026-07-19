# design-forge

> **¿Sos un agente / LLM leyendo esto?** Si un humano te pidió instalar o integrar este
> plugin en su proyecto, no improvises: leé y ejecutá las instrucciones de
> [`SETUP.md`](./SETUP.md) (versión raw:
> `https://raw.githubusercontent.com/innsolutionsmx/design-forge/main/SETUP.md`).
> Ahí está TODO el procedimiento — configuración con merge seguro de
> `.claude/settings.json`, prerequisitos y los pasos que debe hacer el humano al final.

Harness de diseño y desarrollo frontend para Claude Code. Orquesta un pipeline de 4 fases
que lleva una interfaz de 0 a 100: contexto → ideación → build → crítica/test en loop.

design-forge **no reemplaza** a las herramientas de diseño — las dirige. El plugin aporta
los comandos de orquestación, la doctrina del ciclo y el MCP de Playwright para evidencia
visual real. El cerebro de crítica de diseño es [Impeccable](https://github.com/pbakaus/impeccable).

## El pipeline

```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌──────────────────┐
│ 0. CONTEXTO │ → │ 1. IDEACIÓN │ → │  2. BUILD   │ → │ 3. CRÍTICA + TEST│
│ PRODUCT.md  │   │ variantes   │   │ código vs   │   │ critique + audit │
│ DESIGN.md   │   │ in-place    │   │ DESIGN.md   │   │ + screenshots    │
└─────────────┘   └─────────────┘   └─────────────┘   └────────┬─────────┘
                                          ↑                    │
                                          │     ¿pasa? ──no────┘
                                          └────────────        sí → ship
```

| Fase | Comando | Qué hace |
|------|---------|----------|
| 0 — Contexto | `/design-forge:init` | Extrae el branding del cliente (SkillUI desde URL) o lo define desde cero (impeccable init). Todo lo demás lee PRODUCT.md y DESIGN.md. |
| 1 — Ideación | `/design-forge:ideate` | Genera 2–3 direcciones de diseño in-place (rutas de preview temporales en el dev stack vivo, o mockups HTML en un subdir gitignored — sin worktrees por defecto); pairing tipográfico; concepto visual con Stitch si está instalado. |
| 2 — Build | `/design-forge:build` | Implementa contra DESIGN.md. Componentes de 21st.dev y efectos WebGPU solo donde se justifican. |
| 3 — Loop | `/design-forge:review` | impeccable critique + audit, screenshots reales en 3 viewports con Playwright, y decisión: pasa o vuelve a build. Antes de ship: polish + harden. |
| 4 — Teardown | `/design-forge:teardown` | Cierra la exploración sin dejar residuos: archiva los mockups (para no perder trabajo untracked) y elimina el área de preview in-place (y los worktrees `idea/*` si el usuario los creó explícito). |
| — | `/design-forge:doctor` | Verifica prerequisitos y te dice qué falta y cómo instalarlo. |

## Instalación

### Setup automático (recomendado — para agentes)

Pegale esto a Claude Code dentro del proyecto:

```
Lee https://raw.githubusercontent.com/innsolutionsmx/design-forge/main/SETUP.md
y ejecuta el setup en este proyecto.
```

El agente deja `.claude/settings.json` configurado (merge seguro, sin pisar hooks ni
permisos existentes). Como ese archivo va trackeado en git, **el resto del equipo no
hace nada**: pull → abrir Claude Code → aceptar Trust, y los plugins se instalan solos.

### Manual

```
/plugin marketplace add innsolutionsmx/design-forge
/plugin install design-forge
```

El MCP de Playwright viene incluido en el plugin — no hay que instalarlo aparte.

## Prerequisitos

| Herramienta | Rol | Instalación | ¿Obligatoria? |
|-------------|-----|-------------|---------------|
| [Impeccable](https://github.com/pbakaus/impeccable) | Cerebro de diseño: init, critique, audit, polish, harden | `npx impeccable install` | Sí |
| [SkillUI](https://github.com/amaancoderx/npxskillui) | Extraer design system de una URL/repo de cliente | `npm i -g skillui` | Solo si partís de branding existente |
| [Stitch skills](https://github.com/google-labs-code/stitch-skills) | Concepto visual en fase de ideación | `npx plugins add google-labs-code/stitch-skills --scope project --target claude-code` | Opcional |
| [21st.dev Magic](https://github.com/21st-dev/magic-mcp) | Componentes React/Tailwind de producción | `npx @21st-dev/cli@latest install claude --api-key <KEY>` | Opcional (requiere API key) |
| [webgpu-claude-skill](https://github.com/dgreenheck/webgpu-claude-skill) | Shaders Three.js/TSL para héroes y motion | copiar a `.claude/skills/` | Opcional |
| [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | DESIGN.md de referencia de marcas conocidas | copiar el archivo al repo | Opcional |

Corré `/design-forge:doctor` y te dice exactamente qué te falta.

## Documentación

| Doc | Qué cubre |
|-----|-----------|
| [`docs/que-es-y-por-que.md`](./docs/que-es-y-por-que.md) | El problema que originó el plugin, sus dos ideas centrales y cómo funciona por dentro |
| [`docs/casos-de-uso.md`](./docs/casos-de-uso.md) | Escenarios reales paso a paso (rediseño de sección, marca de cliente, review…) |
| [`docs/referencia.md`](./docs/referencia.md) | Cada comando, la doctrina completa y el MCP bundleado |
| [`docs/actualizacion.md`](./docs/actualizacion.md) | Instalación y actualización automática (autoUpdate, /reload-plugins, fallback) |
| [`docs/desarrollo-y-releases.md`](./docs/desarrollo-y-releases.md) | El ciclo gotchas → reglas, y cómo se hace una release (dev → main + bump) |

## Regla de oro: UN solo cerebro de diseño

Impeccable, UI/UX Pro Max, Taste y frontend-design compiten por el mismo rol.
Correr más de uno infla el contexto y produce consejos contradictorios.
design-forge asume **Impeccable** como cerebro único. Si tenés UI/UX Pro Max
instalado globalmente, desactivalo en los proyectos donde uses este plugin.
