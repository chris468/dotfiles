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

## Open Questions

1. What exact UX should `<leader>Nku` implement for task updates?
- Open question: should it show an action picker (done/start/annotate/etc.) or apply a single default state toggle?

2. Should all `<leader>Nk*` task actions depend on vault resolution?
- Open question: require vault selection for every task action vs only for note-linked task workflows.

3. How should vault and MRU state be persisted?
- Open question: finalize persistence location, max MRU length, stale-entry pruning policy, and write/update triggers.

4. What are the expected failure-mode behaviors and messages?
- Open question: define user-facing behavior for missing `taskwarrior` CLI, invalid vault path, canceled vault prompt, and empty task results.

5. How should personal Taskwarrior workflows stay distinct from Overseer build/run tasks?
- Open question: document and enforce conceptual and keymap separation to avoid ambiguity between task systems.

## Risks / Trade-offs

- [Plugin compatibility drift] -> Pin or verify plugin APIs during implementation and validate basic commands in a Neovim session.
- [Keymap namespace saturation] -> Keep initial mapping set minimal and document extension guidance.
- [External dependency mismatch (Taskwarrior CLI missing)] -> Gate task actions behind plugin availability checks and document prerequisite installation.
- [Obsidian vault path ambiguity] -> Use a configurable vault path with sane defaults and clear docs.
- [Directory walk overhead for vault detection] -> Limit parent traversal to filesystem root and cache the resolved vault per buffer/session.
- [Prompt fatigue when vault is unset] -> Persist the selected vault path after first prompt and reuse it for subsequent note/task actions.
- [Stale MRU entries] -> Validate selected paths before use and prune missing directories from history.
- [History growth/noise] -> Enforce max MRU length and move reused paths to front.
