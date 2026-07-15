# design-forge

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
│ DESIGN.md   │   │ worktrees   │   │ DESIGN.md   │   │ + screenshots    │
└─────────────┘   └─────────────┘   └─────────────┘   └────────┬─────────┘
                                          ↑                    │
                                          │     ¿pasa? ──no────┘
                                          └────────────        sí → ship
```

| Fase | Comando | Qué hace |
|------|---------|----------|
| 0 — Contexto | `/design-forge:init` | Extrae el branding del cliente (SkillUI desde URL) o lo define desde cero (impeccable init). Todo lo demás lee PRODUCT.md y DESIGN.md. |
| 1 — Ideación | `/design-forge:ideate` | Genera 2–3 direcciones de diseño en git worktrees paralelos; pairing tipográfico; concepto visual con Stitch si está instalado. |
| 2 — Build | `/design-forge:build` | Implementa contra DESIGN.md. Componentes de 21st.dev y efectos WebGPU solo donde se justifican. |
| 3 — Loop | `/design-forge:review` | impeccable critique + audit, screenshots reales en 3 viewports con Playwright, y decisión: pasa o vuelve a build. Antes de ship: polish + harden. |
| — | `/design-forge:doctor` | Verifica prerequisitos y te dice qué falta y cómo instalarlo. |

## Instalación

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

## Regla de oro: UN solo cerebro de diseño

Impeccable, UI/UX Pro Max, Taste y frontend-design compiten por el mismo rol.
Correr más de uno infla el contexto y produce consejos contradictorios.
design-forge asume **Impeccable** como cerebro único. Si tenés UI/UX Pro Max
instalado globalmente, desactivalo en los proyectos donde uses este plugin.
