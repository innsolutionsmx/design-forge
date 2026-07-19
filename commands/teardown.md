---
description: "Fase 4 — Teardown: cierra la exploración, archiva los mockups y elimina el área de preview in-place (y worktrees idea/* si el usuario los creó)"
argument-hint: "[opcional: nombre de idea a conservar]"
---

You are running phase 4 (Teardown) of the design-forge pipeline — the closing gate.

Phase 1 (Ideation) now works **in-place**: variations live either as temporary preview
routes inside the running dev stack or as self-contained HTML mockups in a gitignored
subdir (`design/ideas/`) — no worktrees by default. Either way the mockups are
**untracked** and a naive delete would destroy them. Worktrees only exist when the user
explicitly asked for real parallelism (`.worktrees/idea-<name>` on branch `idea/<name>`).
This command is the closing cleanup: it archives the mockups so they survive, then
removes the ephemeral preview area — and any explicit `idea/*` worktrees and branches —
safely.

## Golden rule

**Archive before you delete.** The mockups (`design/ideas/*.html`, `DESIGN.md`,
`PRODUCT.md`) are usually untracked. Never remove a worktree with `--force` until its
contents are preserved. Losing an untracked file is unrecoverable — there is no reflog
for what git never saw.

## Steps

1. **Inventory the exploration.** From the main repo, find both substrates:
   - **In-place preview area (default):** locate the gitignored preview dir(s) used this
     round — `design/ideas/` for the static substrate, or the dev-stack preview area
     (`resources/dev-preview/`, `src/dev-preview/`, `/dev/*-preview` routes). List the
     mockup files there; `git status --porcelain --ignored` surfaces the gitignored ones.
   - **Explicit worktrees (opt-in):** `git worktree list` → identify any on `idea/*`
     branches. For each, `git -C <worktree> status --porcelain` → note untracked/
     uncommitted files (the actual mockups). Flag any worktree with uncommitted work.
   - Read whether the winning direction is already implemented in the real project
     (phase 2 usually did this on a `feat/*` branch). If unsure, ASK the user which
     direction won and whether it already landed.

2. **Present the plan and ask.** Show a table: artifact (preview dir / worktree) · branch
   (if any) · has uncommitted mockups (yes/no) · proposed action (archive+remove / keep).
   Then ask the user which to KEEP. Default proposal: keep none (the winner already lives
   in the real project), but never assume — a user may want to keep a runner-up around. If
   the command was invoked with an idea name argument, keep that one and propose removing
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

4. **Remove the previews.** Only after archiving:
   - **In-place preview area (default):** delete the gitignored mockup files/dir
     (`design/ideas/`, the dev-preview dir) and any throwaway `/dev/*-preview` routes
     wired into the app. Leave any preview the user chose to keep.
   - **Explicit worktrees:** `git worktree remove --force .worktrees/idea-<name>` (force is
     now safe — the work is archived) + `git branch -D idea/<name>`. Repeat for each idea
     marked for removal; leave the kept ones untouched. (Older explorations may live in the
     legacy sibling path `../<repo>-idea-<name>`; `git worktree list` shows the real path —
     use whatever it reports.)

5. **Prune dangling registrations.** If any worktrees existed, `git worktree prune -v` —
   a folder deleted by hand leaves a stale registration; prune clears it. Skip if the
   round was purely in-place (no worktrees).

6. **Verify and report.** Confirm the preview area is gone (`git status --porcelain
   --ignored` no longer lists the removed mockups) and, if worktrees existed, that
   `git worktree list` and `git branch | rg 'idea/'` show only the intended ones. Report:
   what was archived (and on which branch), what was removed, what was kept, and whether
   the tree is clean.

## Guardrails

- NEVER remove a preview (in-place dir OR worktree) whose mockups you have not archived
  or the user has not explicitly waived. Golden rule holds for both substrates.
- NEVER `git worktree remove` the MAIN worktree or a non-`idea/*` branch.
- If there are neither in-place preview mockups nor `idea/*` worktrees, say so and stop —
  there is nothing to tear down.
- This runs against the CURRENT repo. Do not touch preview areas or worktrees of other
  repos.
