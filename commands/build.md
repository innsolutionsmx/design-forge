---
description: "Fase 2 — Build: implementa la UI contra DESIGN.md"
argument-hint: "[qué construir]"
---

**design-forge 1.0.0 · build.** State this line, verbatim, in your first message to the
user — it proves which version of this command is actually loaded.

You are running phase 2 (Build) of the design-forge pipeline. If the user brought a
reference design to copy (a screenshot or URL), that's `/design-forge:replicate`, not this
command — send them there.

## Preconditions

Read `DESIGN.md` (and `PRODUCT.md`) at the repo root. If missing → `/design-forge:init`.
Follow the design-pipeline skill's hard rules; the ones that bite hardest here:

- **DESIGN.md is law.** Every color, font, spacing value, radius, and shadow comes from
  its tokens. If you need a value that doesn't exist, add it to DESIGN.md first (tell
  the user), then use it — never hardcode an off-system value inline.
- **Libraries are inspiration, not dependencies.** Build components in the project's own
  stack. When an element would benefit from a proven pattern (a carousel, a mega-menu),
  show the user what you found and where — "encontré este carrusel en <url>, con este
  efecto" — and adapt it to the tokens. Reuse a component library only if the project
  already depends on it (e.g. an existing shadcn setup).
- **Effects earn their place.** WebGPU/shaders (webgpu-claude-skill) only for hero
  moments or explicit requests, always with prefers-reduced-motion and non-WebGPU
  fallbacks.

## Steps

1. Scope the work from $ARGUMENTS (or ask). Break it into components/screens.
2. Implement, matching the project's existing stack and conventions.
3. Accessibility is part of build, not a review afterthought: semantic HTML, focus
   states, labels, contrast per DESIGN.md tokens.
4. Responsive is part of the deliverable, not an afterthought: build mobile-first against
   the mobile viewport and breakpoints in DESIGN.md (default: 390 / 768 / 1440 if
   unspecified). The `@media` mobile implementation ships WITH the component — a build
   that only holds at desktop width is incomplete. Watch the failure modes that bite at
   1 column: background-photo cards that crop their subject, text that lands over a busy
   zone, grids that squash into strips, tap targets under 44px.
5. When done, do a quick self-check against DESIGN.md (tokens only? states covered?
   empty/loading/error states?) AND at the mobile viewport (single-column composition
   holds? photos keep their subject in frame? text legible over every background? no
   horizontal scroll?).
6. Ask before reviewing: "¿Corro el review con Impeccable (`/design-forge:review`)?"
   Never start it without a yes.

Do NOT run the critique loop here — that's phase 3's job, and only on the user's yes.
