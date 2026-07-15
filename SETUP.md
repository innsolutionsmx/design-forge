# design-forge — Setup para agentes

> **Humano**: pegale esto a tu agente (Claude Code) dentro del proyecto donde quieras
> instalar el harness:
>
> ```
> Lee https://raw.githubusercontent.com/innsolutionsmx/design-forge/main/SETUP.md
> y ejecuta el setup en este proyecto.
> ```

---

**Agent instructions.** You are setting up the design-forge frontend pipeline in the
current project. Follow these steps exactly; do not improvise extra installs.

## 1. Respect the project's rules first

If the project has a `CLAUDE.md` with a git workflow (protected branches, branch
naming, hooks), follow it. Default when nothing is specified: create a branch
`chore/design-forge-setup` — never commit directly to `main` or `dev`.

## 2. Configure `.claude/settings.json` — MERGE, never overwrite

This is the step where careless agents destroy things. The project may already have
`settings.json` with `hooks`, `permissions`, `env`, or other plugins. **Read the
existing file first** and merge these two keys into it, preserving everything else:

```json
{
  "extraKnownMarketplaces": {
    "design-forge": {
      "source": { "source": "github", "repo": "innsolutionsmx/design-forge" }
    },
    "impeccable": {
      "source": { "source": "github", "repo": "pbakaus/impeccable" }
    }
  },
  "enabledPlugins": {
    "design-forge@design-forge": true,
    "impeccable@impeccable": true
  }
}
```

If the keys already exist, add these entries inside them — do not replace the objects
wholesale. If the file doesn't exist, create it with exactly this content.

## 3. Verify the runtime prerequisite

Phase 1 serves HTML mockups over HTTP (the bundled Playwright MCP blocks `file://`).
Check that `python3 --version` works or `npx serve` is available. If neither, tell
the human — don't install system software silently.

## 4. Commit

Commit `.claude/settings.json` on the branch from step 1 with a conventional message,
e.g. `chore(tooling): install design-forge + impeccable plugins via settings.json`.
If the project tracks session/progress docs (e.g. an `ia/context/progreso-actual.md`),
update them per the project's own rules. Push the branch only if the project workflow
says agents push; otherwise leave the commit local and say so.

## 5. Hand back to the human

The plugins load on session start, so finish by telling the human exactly this:

1. Reiniciá Claude Code en este proyecto.
2. Aceptá el diálogo de **Trust** del workspace — ahí se instalan los marketplaces
   y se habilitan design-forge + Impeccable solos.
3. En la sesión nueva corré `/design-forge:doctor` para verificar el entorno.
4. Si el proyecto no tiene `PRODUCT.md`/`DESIGN.md`, el siguiente paso es
   `/design-forge:init`.

## Notes

- Both GitHub repos above must be reachable (they are public). If a marketplace fails
  to install, the error appears in the `/plugin` → Errors tab.
- This file is fetched from `main`, so it is always current — do not copy it into
  projects; reference it by URL.
- Do NOT additionally install UI/UX Pro Max, Taste, or frontend-design in the project:
  design-forge runs Impeccable as the single design brain (see the pipeline doctrine).
