---
description: "Fase 4 — Teardown: cierra la exploración, archiva los mockups y elimina los worktrees idea/* residuales"
argument-hint: "[opcional: nombre de idea a conservar]"
---

You are running phase 4 (Teardown) of the design-forge pipeline — the closing gate.

Phase 1 (Ideation) creates one git worktree per direction (`../<repo>-idea-<name>`
on branch `idea/<name>`) and parks the non-winning mockups there as inventory. Nothing
in the pipeline ever removes them, so they pile up as residual sibling folders with
**untracked** HTML mockups inside — work that git never tracked and that a naive
`worktree remove` would destroy. This command is the missing cleanup: it archives the
mockups so they survive, then removes the worktrees and branches safely.

## Golden rule

**Archive before you delete.** The mockups (`design/ideas/*.html`, `DESIGN.md`,
`PRODUCT.md`) are usually untracked. Never remove a worktree with `--force` until its
contents are preserved. Losing an untracked file is unrecoverable — there is no reflog
for what git never saw.

## Steps

1. **Inventory the worktrees.** From the main repo, list every idea worktree and its
   state:
   - `git worktree list` → identify the ones on `idea/*` branches.
   - For each, `git -C <worktree> status --porcelain` → note untracked/uncommitted
     files (the actual mockups). Flag any worktree that has uncommitted work.
   - Read whether the winning direction is already implemented in the real project
     (phase 2 usually did this on a `feat/*` branch). If unsure, ASK the user which
     direction won and whether it already landed.

2. **Present the plan and ask.** Show a table: worktree · branch · has uncommitted
   mockups (yes/no) · proposed action (archive+remove / keep). Then ask the user which
   to KEEP. Default proposal: keep none (the winner already lives in the real project),
   but never assume — a user may want to keep a runner-up as live inventory. If the
   command was invoked with an idea name argument, keep that one and propose removing
   the rest.

3. **Archive the mockups of every worktree to be removed.** Do NOT let untracked work
   die. Use a single archive branch in the main repo so the history is one place:
   - Create/switch to an orphan-free archive branch: `archive/design-ideas` (create it
     if it doesn't exist; otherwise add commits to it).
   - Copy each removed worktree's design artifacts (`design/`, `DESIGN.md`, `PRODUCT.md`
     and any mockup HTML) into a folder named after the idea, e.g.
     `archive/<idea-name>/`, commit them there with a clear message
     (`chore(design): archive <idea-name> mockups before teardown`).
   - If the user confirms a mockup is truly disposable (already fully captured in the
     real project), you may skip archiving it — but state that explicitly and get a
     yes. Silence is NOT consent to delete.

4. **Remove the worktrees and branches.** Only after archiving:
   - `git worktree remove --force ../<repo>-idea-<name>` (force is now safe — the work
     is archived).
   - `git branch -D idea/<name>`.
   - Repeat for each idea marked for removal; leave the kept ones untouched.

5. **Prune dangling registrations.** `git worktree prune -v`. A folder deleted by hand
   leaves a stale registration; prune clears it.

6. **Verify and report.** Run `git worktree list` and `git branch | rg 'idea/'` and
   confirm only the intended worktrees/branches remain. Report: what was archived (and
   on which branch), what was removed, what was kept, and whether the tree is clean.

## Guardrails

- NEVER remove a worktree whose mockups you have not archived or the user has not
  explicitly waived.
- NEVER `git worktree remove` the MAIN worktree or a non-`idea/*` branch.
- If `git worktree list` shows no `idea/*` worktrees, say so and stop — there is
  nothing to tear down.
- This runs against the CURRENT repo. Do not touch worktrees of other repos.
