---
description: "Fase 2 — Build: implementa la UI contra DESIGN.md"
argument-hint: "[qué construir]"
---

You are running phase 2 (Build) of the design-forge pipeline.

## Preconditions

Read `DESIGN.md` (and `PRODUCT.md`) at the repo root. If missing → `/design-forge:init`.
Follow the design-pipeline skill's hard rules; the ones that bite hardest here:

- **DESIGN.md is law.** Every color, font, spacing value, radius, and shadow comes from
  its tokens. If you need a value that doesn't exist, add it to DESIGN.md first (tell
  the user), then use it — never hardcode an off-system value inline.
- **Components before custom.** If 21st.dev Magic MCP is available, pull production
  components and restyle them to the tokens. Same for an existing shadcn setup.
- **Effects earn their place.** WebGPU/shaders (webgpu-claude-skill) only for hero
  moments or explicit requests, always with prefers-reduced-motion and non-WebGPU
  fallbacks.

## Steps

1. Scope the work from $ARGUMENTS (or ask). Break it into components/screens.
2. Implement, matching the project's existing stack and conventions.
3. Accessibility is part of build, not a review afterthought: semantic HTML, focus
   states, labels, contrast per DESIGN.md tokens.
4. Responsive from the start: build mobile-first against the breakpoints in DESIGN.md
   (default: 375 / 768 / 1440 if unspecified).
5. When done, do a quick self-check against DESIGN.md (tokens only? states covered?
   empty/loading/error states?) and hand off: "Listo para `/design-forge:review`."

Do NOT run the full critique loop here — that's phase 3's job. Build, self-check, hand off.
