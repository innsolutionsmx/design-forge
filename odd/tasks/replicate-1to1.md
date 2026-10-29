# replicate-1to1 — redesign design-forge around the 1:1 reference flow

Objective: replace ideate with a 1:1 reference-replica command; slim the pipeline. Branch: `feat/replicate-1to1` (from `dev`). Delivery: ask-on-risk, work-unit commits, no push/PR without the owner. Test runner: none for markdown; shell probes for `hooks/preview-discipline.sh`; `bash scripts/validate-manifest.sh` for the manifest.

## Specs

- **S1** New command `/design-forge:replicate` for the owner's main flow: "Hazme un preview con el diseño uno a uno, que sea idéntico, pero con los assets que tenemos en el proyecto. No uses los assets que están en el ejemplo porque normalmente son screenshots de otras páginas que yo encuentro y esto lo quiero poner en mi proyecto." The owner must no longer have to say "Haz el diseño uno a uno. No uses los assets del ejemplo, usa los assets del proyecto y muéstrame un preview." Input: a reference screenshot, optionally its URL (SkillUI extracts exact tokens/effects when a URL exists). Output: 1:1 build with project assets + side-by-side fidelity preview (reference vs result, desktop and mobile).
- **S2** Remove ideate: "IDEA8 sí lo vamos a quitar porque ya no lo uso". Teardown goes with it (it only served ideate); replicate cleans its own preview area.
- **S3** 21st.dev / shadcn stop being "components first" ("no sabemos si les van a dejar dar mantenimiento"); they become inspiration sources: "Mira, encontré para este carrousel en esta página este diseño y estos efectos."
- **S4** Review: "que pregunte antes de correr el review" — after the preview is approved, replicate asks before running `/design-forge:review`; never automatic. Review passes concrete context to Impeccable.
- **S5** Preview verification keeps catching broken output ("tenemos que encontrar la manera de ajustarnos para que siga pasando eso"): keep the deterministic gates (overflow, true mobile width, fold at both heights) and the verifier subagent; merge the refuter INTO the single verifier (adversarial prior + gates) and compare against the reference section by section. Log every catch so the separate refuter can come back with data.
- **S6** Slim doctrine, hook and doctor accordingly; hard rule "never use the reference's assets"; preview hook fires less broadly; pin Playwright MCP (`@playwright/mcp@0.0.83`).
- **S7** Backlog: the 4 ideate-only items become obsolete; fold in "dir gitignored para las capturas" and "cada comando declara su versión en el texto".
- **S8** Version 1.0.0 (breaking: commands removed). Docs (README, SETUP, docs/*) reflect the new flow.

## Tasks

| ID | Specs | Route | Status | Commit |
|----|-------|-------|--------|--------|
| T1 | S1 S2 S4 S5 S7 | inline | pending | |
| T2 | S3 S4 | inline | pending | |
| T3 | S6 | inline | pending | |
| T4 | S6 S8 | inline | pending | |
| T5 | S7 S8 | inline | pending | |

T1 replicate command + delete ideate/teardown. T2 build/review updates. T3 doctrine skill rewrite. T4 hook + doctor + manifest. T5 docs + backlog + version.

## Log

- **L1** (2026-10-28, owner, verbatim): "La idea es que con el nuevo te va a decir cuándo es mi flujo de trabajo. Normalmente me he dado cuenta de que Claude entiende mejor si le paso una imagen de lo que quiero hacer para que pueda ver el diseño, cómo está, y pueda ver todo tal cual. Normalmente yo le tengo que decir: "Hazme un preview con el diseño uno a uno, que sea idéntico, pero con los assets que tenemos en el proyecto. No uses los assets que están en el ejemplo porque normalmente son screenshots de otras páginas que yo encuentro y esto lo quiero poner en mi proyecto." Entonces primero, yo creo que IDEA8 sí lo vamos a quitar porque ya no lo uso y podemos mejorar el de Wispr. No sé si a lo mejor no usar ChatCN o TwentyOne como first porque no sabemos si les van a dejar dar mantenimiento. Pero sí, estéreo, padre, que a lo mejor me dijeras: "Mira, encontré para este carrousel en esta página este diseño y estos efectos." Y es algo, sí. Entonces yo, cada vez que quiero hacer un diseño, te tengo que decir: "Haz el diseño uno a uno. No uses los assets del ejemplo, usa los assets del proyecto y muéstrame un preview." Ese es ahorita el flujo que más uso con Design Forge. Entonces hay que rebotarlo, hay que afinarlo para implementar y, por ejemplo, hay skill UI que creo que ayuda a mejorar y mitigar el AI slop. Entonces a lo mejor sí lo podemos integrar, eso y el review, que lo aplique automáticamente después de hacer el diseño del paso anterior o que pregunte. Eso también lo tenemos que decidir."
- **L2** (2026-10-28, owner): "que pregunte antes de correr el review"
- **L3** (2026-10-28, owner): "Es que si me dices que el uno es necesario para no entregar nada roto, tenemos que encontrar la manera de ajustarnos para que siga pasando eso (porque sí he notado que casi todo lo que me entregas está bien hecho y no hay problemas o algo roto en diseño)." → merged verifier+refuter, catches logged. Owner: "Me sirve."
- **L4** Assumptions: "Wispr" read as "preview" (stated to owner, not corrected). SkillUI verified as a static extractor (not anti-slop); Impeccable stays the anti-slop authority.
