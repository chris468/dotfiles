## Context

This Neovim configuration uses LazyVim and currently does not provide an integrated workflow for long-form note authoring in an Obsidian vault or command-driven task tracking with Taskwarrior. The change introduces both capabilities and must preserve existing keymaps by placing note/task mappings under a dedicated `<leader>N` namespace. The implementation should remain modular and follow existing plugin-spec patterns in the repo.

## Goals / Non-Goals

**Goals:**
- Add an Obsidian integration that supports opening vault notes, creating notes, and searching notes from Neovim.
- Add a Taskwarrior integration that supports viewing, creating, and updating tasks from Neovim.
- Lazy-load Obsidian integration when opening markdown files in a detected Obsidian vault.
- Prompt for vault selection if notes/tasks are invoked before a vault path is configured.
- Maintain an MRU vault history that supports selecting a recent vault or entering a new path at prompt time.
- Add resolved vault paths to MRU history whether they were auto-detected or user-entered.
- Define a consistent `<leader>N` keymap namespace for notes and tasks.
- Ensure new mappings are checked against existing keymaps to avoid collisions.
- Keep configuration maintainable with isolated plugin config blocks.

**Non-Goals:**
- Replacing existing personal workflow tooling outside Neovim.
- Building custom Lua UIs for notes/tasks beyond what selected plugins provide.
- Synchronizing task data beyond what Taskwarrior itself supports.

## Decisions

1. Use dedicated plugins for each concern.
- Decision: configure one Obsidian-focused plugin and one Taskwarrior-focused plugin rather than a single multipurpose plugin.
- Rationale: clearer ownership, simpler updates, and lower coupling between notes and tasks.
- Alternative considered: relying only on Telescope/file search and shell commands. Rejected because it increases manual steps and reduces discoverability.

2. Adopt `<leader>N` as a top-level namespace with subgroup-style mappings.
- Decision: reserve `<leader>N` for note/task operations, keep notes on direct second keys, and use `k` as the task subgroup key (`tasK`).
- Agreed mapping set:
  - Notes: `<leader>Nn` (new), `<leader>Nf` (find), `<leader>Nt` (today), `<leader>Ny` (yesterday), `<leader>Nm` (tomorrow), `<leader>Nr` (recent), `<leader>Nv` (vault picker).
  - Tasks: `<leader>Nk` (task list/hub), `<leader>Nka` (add), `<leader>Nkt` (today), `<leader>Nku` (update), `<leader>Nkd` (done), `<leader>Nkp` (pending), `<leader>Nkr` (refresh), `<leader>Nkv` (view/filter toggle).
- Rationale: keeps new commands grouped and easy to memorize while minimizing interference with existing leader mappings.
- Alternative considered: split across unrelated prefixes. Rejected due to poor discoverability and higher conflict probability.

3. Enforce explicit keymap conflict checks during implementation.
- Decision: inspect existing keymaps before assigning each new mapping, and choose fallback mappings if a collision is found.
- Rationale: avoids regressions in existing workflows.
- Alternative considered: force override. Rejected because it can silently break user habits.

4. Keep plugin setup declarative in existing LazyVim plugin spec structure.
- Decision: place plugin declarations and options in dedicated plugin spec files and avoid ad hoc runtime setup in unrelated modules.
- Rationale: aligns with repository conventions and makes future maintenance straightforward.
- Alternative considered: inline setup in init files. Rejected due to reduced clarity and harder troubleshooting.

5. Detect vault context from the opened markdown file path.
- Decision: treat a markdown file as in-vault when a `.obsidian` directory exists in its directory or any ancestor directory.
- Rationale: supports project-local vault discovery without requiring global hardcoding.
- Alternative considered: always require explicit vault configuration before loading. Rejected because it adds friction for already-structured vaults.

6. Add a shared vault bootstrap prompt for notes and task actions.
- Decision: wrap note/task entrypoints with a vault resolver that prompts the user to select a vault path if none is configured or discovered.
- Rationale: guarantees both workflows remain usable on first run and prevents silent failures.
- Alternative considered: fail with an error message only. Rejected due to poor usability.

7. Maintain MRU vault history without source metadata.
- Decision: store a bounded, deduplicated list of recently used vault paths and update it whenever a vault is resolved, whether by detection or user input.
- Rationale: reduces repeated path entry without adding unnecessary metadata complexity.
- Alternative considered: storing only one active path. Rejected because switching between multiple vaults is common.

8. Prompt with recent choices plus manual entry.
- Decision: when vault is unresolved, present recent vault entries first and include an explicit option to enter a new path.
- Rationale: combines fast reuse with flexibility for first-time or uncommon vaults.
- Alternative considered: always opening file-picker/manual entry directly. Rejected because it is slower for repeat usage.

## Resolved Decisions

1. `<leader>Nku` uses an action picker.
- Behavior: shows update choices (`done`, `start`, `stop`, `annotate`) for a selected pending task.
- Rationale: supports common update actions without forcing a single state-toggle workflow.

2. All `<leader>Nk*` actions require vault resolution.
- Behavior: each task action resolves a vault before continuing (detected/current/prompted).
- Rationale: keeps note/task workflows consistent and ensures first-run behavior is predictable.

3. Vault and MRU persistence is file-based in Neovim state.
- Storage: `stdpath("state")/chris468-vault-state.json`.
- Policy: deduplicated MRU list, max length 10, move-used-to-front, prune missing directories on load/update.
- Triggers: update on vault auto-detection, explicit selection, and manual path entry.

4. Failure-mode UX is explicit and non-destructive.
- Missing `task` CLI: task actions abort and show an error that Taskwarrior is required.
- Invalid vault path: action aborts with an error for non-existent path or missing `.obsidian`.
- Canceled vault prompt: action aborts with a warning and no side effects.
- Empty task results: action reports informational empty-state messages instead of errors.

5. Taskwarrior and Overseer workflows remain separate.
- Namespace: `<leader>Nk*` is reserved for personal Taskwarrior actions.
- Existing `<leader>o*` Overseer mappings remain run/build oriented.
- Documentation clarifies scope to avoid overlap between personal tasks and build tasks.

## Risks / Trade-offs

- [Plugin compatibility drift] -> Pin or verify plugin APIs during implementation and validate basic commands in a Neovim session.
- [Keymap namespace saturation] -> Keep initial mapping set minimal and document extension guidance.
- [External dependency mismatch (Taskwarrior CLI missing)] -> Gate task actions behind plugin availability checks and document prerequisite installation.
- [Obsidian vault path ambiguity] -> Use a configurable vault path with sane defaults and clear docs.
- [Directory walk overhead for vault detection] -> Limit parent traversal to filesystem root and cache the resolved vault per buffer/session.
- [Prompt fatigue when vault is unset] -> Persist the selected vault path after first prompt and reuse it for subsequent note/task actions.
- [Stale MRU entries] -> Validate selected paths before use and prune missing directories from history.
- [History growth/noise] -> Enforce max MRU length and move reused paths to front.
