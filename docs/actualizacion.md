# Cómo se instala y cómo se actualiza

## Instalación

**Vía agente (recomendado)** — pegale a Claude Code dentro del proyecto:

```
Lee https://raw.githubusercontent.com/innsolutionsmx/design-forge/main/SETUP.md
y ejecuta el setup en este proyecto.
```

**Manual**:

```
/plugin marketplace add innsolutionsmx/design-forge
/plugin install design-forge@design-forge
```

Después: instalar Impeccable (`npx impeccable install`) y correr
`/design-forge:doctor` para verificar el entorno. En proyecto sin contexto de marca:
`/design-forge:init`.

**Por settings del repo**: `.claude/settings.json` declara los marketplaces
(design-forge + impeccable) con `autoUpdate: true`; quien clona y acepta **Trust**
recibe ambos. *Fallback conocido*: si el prompt de instalación no aparece en el primer
open, usar la vía manual una vez.

## Actualización — automática por diseño

Con `autoUpdate: true` (los settings que genera el SETUP ya lo traen):

1. Se publica una release de design-forge (bump de versión + merge a `main`).
2. Claude Code revisa los marketplaces después de arrancar cada sesión (delay
   aleatorio de hasta 10 min).
3. Versión nueva → notificación para `/reload-plugins`, o se carga en la próxima
   sesión. **Nadie pide la actualización — llega sola.**

Detalles a saber:

- La sesión corriendo no cambia de versión (intencional: el pipeline no muta a mitad
  de un rediseño).
- **La versión es el gatillo**: mismo `version` en `plugin.json` = no hay update
  aunque `main` cambie. Cache por versión en
  `~/.claude/plugins/cache/design-forge/design-forge/<version>/` (las viejas se
  limpian a los 7 días).
- Esto también actualiza **Impeccable** solo: su marketplace está declarado con
  `autoUpdate: true` en los mismos settings.

## Actualización manual

```
/plugin marketplace update design-forge
```

y recargá la sesión. Versión activa: `/plugin` → plugins instalados. Última publicada:
`version` de `.claude-plugin/plugin.json` en `main` de este repo.
