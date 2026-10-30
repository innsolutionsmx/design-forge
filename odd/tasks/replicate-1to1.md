# replicate-1to1 — redesign design-forge around the 1:1 reference flow

Objective: replace ideate with a 1:1 reference-replica command; slim the pipeline. Branch: `feat/replicate-1to1` (from `dev`). Delivery: ask-on-risk, work-unit commits, no push/PR without the owner. Test runner: none for markdown; shell probes for `hooks/preview-discipline.sh`; `bash scripts/validate-manifest.sh` for the manifest.

## Specs

- **S1** New command `/design-forge:replicate` for the owner's main flow: "Hazme un preview con el diseño uno a uno, que sea idéntico, pero con los assets que tenemos en el proyecto. No uses los assets que están en el ejemplo porque normalmente son screenshots de otras páginas que yo encuentro y esto lo quiero poner en mi proyecto." The owner must no longer have to say "Haz el diseño uno a uno. No uses los assets del ejemplo, usa los assets del proyecto y muéstrame un preview." Input: a reference screenshot, optionally its URL (SkillUI extracts exact tokens/effects when a URL exists). Output: 1:1 build with project assets + side-by-side fidelity preview (reference vs result, desktop and mobile).
- **S2** Remove ideate: "IDEA8 sí lo vamos a quitar porque ya no lo uso". Teardown goes with it (it only served ideate); replicate cleans its own preview area.
- **S3** 21st.dev / shadcn stop being "components first" ("no sabemos si les van a dejar dar mantenimiento"); they become inspiration sources: "Mira, encontré para este carrousel en esta página este diseño y estos efectos."
- **S4** Review: "que pregunte antes de correr el review" — after the preview is approved, replicate asks before running `/design-forge:review`; never automatic. Review passes concrete context to Impeccable.
- **S5** Preview verification keeps catching broken output ("tenemos que encontrar la manera de ajustarnos para que siga pasando eso"): keep the deterministic gates (overflow, true mobile width, fold at both heights) and the verifier subagent; merge the refuter INTO the single verifier (adversarial prior + gates) and compare against the reference section by section. Log every catch so the separate refuter can come back with data.
- **S6** Slim doctrine, hook and doctor accordingly; hard rule "never use the reference's assets"; preview hook fires less broadly; pin Playwright MCP (`@playwright/mcp@0.0.83`).
- **S7** Backlog: all 6 pending items apply to the new verifier/flow and are closed inside the redesign (corrected from "4 obsolete" after reading their detail — L5).
- **S8** Version 1.0.0 (breaking: commands removed). Docs (README, SETUP, docs/*) reflect the new flow.

## Tasks

| ID | Specs | Route | Status | Commit |
|----|-------|-------|--------|--------|
| T1 | S1 S2 S4 S5 S7 | inline | done | c18c2d2 |
| T2 | S3 S4 | inline | done | 474f387 |
| T3 | S6 | inline | done | 78f059b |
| T4 | S6 S8 | inline | done | b900dca |
| T5 | S7 S8 | inline | done | 119ab33 |

T1 replicate command + delete ideate/teardown. T2 build/review updates. T3 doctrine skill rewrite. T4 hook + doctor + manifest. T5 docs + backlog + version.

## Log

- **L1** (2026-10-28, owner, verbatim): "La idea es que con el nuevo te va a decir cuándo es mi flujo de trabajo. Normalmente me he dado cuenta de que Claude entiende mejor si le paso una imagen de lo que quiero hacer para que pueda ver el diseño, cómo está, y pueda ver todo tal cual. Normalmente yo le tengo que decir: "Hazme un preview con el diseño uno a uno, que sea idéntico, pero con los assets que tenemos en el proyecto. No uses los assets que están en el ejemplo porque normalmente son screenshots de otras páginas que yo encuentro y esto lo quiero poner en mi proyecto." Entonces primero, yo creo que IDEA8 sí lo vamos a quitar porque ya no lo uso y podemos mejorar el de Wispr. No sé si a lo mejor no usar ChatCN o TwentyOne como first porque no sabemos si les van a dejar dar mantenimiento. Pero sí, estéreo, padre, que a lo mejor me dijeras: "Mira, encontré para este carrousel en esta página este diseño y estos efectos." Y es algo, sí. Entonces yo, cada vez que quiero hacer un diseño, te tengo que decir: "Haz el diseño uno a uno. No uses los assets del ejemplo, usa los assets del proyecto y muéstrame un preview." Ese es ahorita el flujo que más uso con Design Forge. Entonces hay que rebotarlo, hay que afinarlo para implementar y, por ejemplo, hay skill UI que creo que ayuda a mejorar y mitigar el AI slop. Entonces a lo mejor sí lo podemos integrar, eso y el review, que lo aplique automáticamente después de hacer el diseño del paso anterior o que pregunte. Eso también lo tenemos que decidir."
- **L2** (2026-10-28, owner): "que pregunte antes de correr el review"
- **L3** (2026-10-28, owner): "Es que si me dices que el uno es necesario para no entregar nada roto, tenemos que encontrar la manera de ajustarnos para que siga pasando eso (porque sí he notado que casi todo lo que me entregas está bien hecho y no hay problemas o algo roto en diseño)." → merged verifier+refuter, catches logged. Owner: "Me sirve."
- **L4** Assumptions: "Wispr" read as "preview" (stated to owner, not corrected). SkillUI verified as a static extractor (not anti-slop); Impeccable stays the anti-slop authority.
- **L5** (2026-10-28) Reading the backlog detail showed all 6 items are instrument/cleanup issues that also apply to replicate → all folded in and closed (owner told).
- **L6** (2026-10-28) Discovery: `hooks/preview-discipline.sh` required `jq`; this machine has no jq, so the reminder never fired. RED: 7/7 "must fire" cases failed. GREEN after rewrite (jq|python3|node, plain stdout): 16/16 in `tests/preview-discipline.test.sh`. `bash scripts/validate-manifest.sh` → exit 0 (v1.0.0).
- **L7** Pending: blind real run of `replicate` in a consumer (process rule 3) before dev→main; release, push and PR are the owner's call.
- **L8** (2026-10-29, owner): "vamos a hacer la prubea con landing-urn" → native RDD review skipped for now. Blind run loads the unreleased branch via `claude --plugin-dir`; judge checklist kept outside the repo (session scratchpad), not given to the executor.
- **L9** (2026-10-30) Learnings from the landing-urn /por-que-urn session (not a blind run of replicate; the owner drove a preview with SkillUI + ploy.ai/zoah.com references): (a) SkillUI 1.3.4 output was noisy (font/accent roles wrong, no screenshots) — visual captures did the work; (b) the page overflow gate passed while text was clipped inside cards — an "element escapes its parent box" gate caught it; candidate addition to replicate's verifier contract; (c) Impeccable was never installed in landing-urn (`.claude/settings.json` lacked it) — likely cause of the owner's original "Impeccable no funciona"; installed there in e05f0b8. Doctor check 1 should have flagged it: worth verifying in the blind run.
