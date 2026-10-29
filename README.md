# design-forge

> **¿Sos un agente / LLM leyendo esto?** Si un humano te pidió instalar o integrar este
> plugin en su proyecto, no improvises: leé y ejecutá las instrucciones de
> [`SETUP.md`](./SETUP.md) (versión raw:
> `https://raw.githubusercontent.com/innsolutionsmx/design-forge/main/SETUP.md`).
> Ahí está TODO el procedimiento — configuración con merge seguro de
> `.claude/settings.json`, prerequisitos y los pasos que debe hacer el humano al final.

Harness de diseño y desarrollo frontend para Claude Code. Le pasás la captura de un diseño
que encontraste y lo construye **1:1 en tu proyecto, con tus assets**, te muestra un preview
verificado (referencia vs resultado, desktop y mobile) y, si querés, lo revisa con Impeccable.

design-forge **no reemplaza** a las herramientas de diseño — las dirige. El plugin aporta
los comandos de orquestación, la doctrina del ciclo y el MCP de Playwright para evidencia
visual real. El cerebro de crítica de diseño es [Impeccable](https://github.com/pbakaus/impeccable).

## El pipeline

```
┌─────────────┐   ┌──────────────────────┐   ┌──────────────────┐
│ 0. CONTEXTO │ → │ 1. REPLICATE (1:1)   │ → │ 2. REVIEW        │
│ PRODUCT.md  │   │ captura → assets del │   │ solo si decís sí │
│ DESIGN.md   │   │ proyecto → preview   │   │ critique + audit │
└─────────────┘   │ verificado           │   └──────────────────┘
                  └──────────────────────┘
                  (sin referencia: build)
```

| Fase | Comando | Qué hace |
|------|---------|----------|
| 0 — Contexto | `/design-forge:init` | Extrae el branding del cliente (SkillUI desde URL), consolida docs internos o lo define desde cero (impeccable init). Todo lo demás lee PRODUCT.md y DESIGN.md. |
| 1 — Réplica | `/design-forge:replicate` | El flujo principal: captura (y URL opcional) → mapa de assets del proyecto (nunca los de la referencia) → build 1:1 → hoja de preview referencia vs resultado en desktop y mobile → un verificador adversarial → URL viva. Al aprobar, pregunta si corre el review. |
| 1b — Build | `/design-forge:build` | UI sin referencia que copiar, contra DESIGN.md. Las librerías son inspiración, no dependencias. |
| 2 — Review | `/design-forge:review` | Solo con tu sí: critique + audit de Impeccable con contexto, capturas reales con Playwright y decisión pasa/itera (máx 3). Antes de ship: polish + harden. |
| — | `/design-forge:doctor` | Verifica prerequisitos y te dice qué falta y cómo instalarlo. |

> **Desde 1.0.0** ya no existen `ideate` ni `teardown`: el preview comparativo de 3
> variantes se reemplazó por la réplica 1:1, y `replicate` limpia su propio preview.

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
| [SkillUI](https://github.com/amaancoderx/npxskillui) | Extraer valores exactos (tokens, motion) de la URL de una marca o de una referencia | `npm i -g skillui` | Opcional |
| [webgpu-claude-skill](https://github.com/dgreenheck/webgpu-claude-skill) | Shaders Three.js/TSL para héroes y motion | copiar a `.claude/skills/` | Opcional |
| [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) | DESIGN.md de referencia de marcas conocidas | copiar el archivo al repo | Opcional |

Corré `/design-forge:doctor` y te dice exactamente qué te falta.

## Documentación

| Doc | Qué cubre |
|-----|-----------|
| [`docs/que-es-y-por-que.md`](./docs/que-es-y-por-que.md) | El problema que originó el plugin, sus dos ideas centrales y cómo funciona por dentro |
| [`docs/casos-de-uso.md`](./docs/casos-de-uso.md) | Escenarios reales paso a paso (réplica 1:1, marca de cliente, review…) |
| [`docs/referencia.md`](./docs/referencia.md) | Cada comando, la doctrina completa y el MCP bundleado |
| [`docs/actualizacion.md`](./docs/actualizacion.md) | Instalación y actualización automática (autoUpdate, /reload-plugins, fallback) |
| [`docs/desarrollo-y-releases.md`](./docs/desarrollo-y-releases.md) | El ciclo gotchas → reglas, y cómo se hace una release (dev → main + bump) |

## Regla de oro: UN solo cerebro de diseño

Impeccable, UI/UX Pro Max, Taste y frontend-design compiten por el mismo rol.
Correr más de uno infla el contexto y produce consejos contradictorios.
design-forge asume **Impeccable** como cerebro único. Si tenés UI/UX Pro Max
instalado globalmente, desactivalo en los proyectos donde uses este plugin.
