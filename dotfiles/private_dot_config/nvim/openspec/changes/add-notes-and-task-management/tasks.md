## 1. Plugin Setup

- [ ] 1.1 Identify and add an Obsidian plugin spec file in the existing LazyVim plugin layout.
- [ ] 1.2 Implement vault auto-detection for markdown buffers by searching for `.obsidian` in the current directory and parent directories.
- [ ] 1.3 Configure Obsidian plugin options (vault/workspace path and core note commands) using repository conventions, wired to auto-detection results.
- [ ] 1.4 Identify and add a Taskwarrior plugin (or command integration) spec file compatible with current Neovim/LazyVim setup.
- [ ] 1.5 Configure Taskwarrior integration options and validate required external dependency assumptions (`taskwarrior` CLI availability).

## 2. Vault Bootstrap and Keymap Namespace

- [ ] 2.1 Implement a shared vault resolver that prompts the user to select a vault path when note/task actions are invoked without configured or detected vault.
- [ ] 2.2 Persist and reuse the selected vault path for subsequent note/task actions.
- [ ] 2.3 Implement a bounded deduplicated MRU vault history updated by both auto-detected and user-entered vault paths.
- [ ] 2.4 Update vault prompt UX to offer recent vault selection and an option to enter a new vault path.
- [ ] 2.5 Define a `<leader>N` keymap namespace plan covering note and task operations.
- [ ] 2.6 Audit existing mappings in the configuration and detect conflicts for proposed `<leader>N` bindings.
- [ ] 2.7 Implement non-conflicting note mappings under `<leader>N` (for example create/find note actions).
- [ ] 2.8 Implement non-conflicting task mappings under `<leader>N` (for example list/add/update actions).

## 3. Behavior Verification

- [ ] 3.1 Verify Obsidian commands load and execute successfully in Neovim with configured vault path.
- [ ] 3.2 Verify Obsidian auto-load triggers only when opening markdown files within a directory tree containing `.obsidian`.
- [ ] 3.3 Verify invoking note/task actions without configured vault prompts for vault selection and continues after selection.
- [ ] 3.4 Verify vault prompt allows selecting MRU vaults and entering a new path.
- [ ] 3.5 Verify MRU history is updated for both auto-detected vaults and user-entered vaults.
- [ ] 3.6 Verify Taskwarrior commands load and execute successfully in Neovim on a system with Taskwarrior installed.
- [ ] 3.7 Confirm mappings do not override pre-existing bindings and adjust any fallback mappings if collisions appear.

## 4. Documentation

- [ ] 4.1 Document new plugin dependencies and prerequisites (including Taskwarrior CLI) in the relevant README/docs location.
- [ ] 4.2 Document `<leader>N` keymaps and intended note/task workflows for daily usage.

## 5. Open Question Resolution

- [ ] 5.1 Decide `<leader>Nku` behavior (action picker vs single-toggle update) and reflect in spec/design.
- [ ] 5.2 Decide whether all `<leader>Nk*` actions require vault resolution or only note-linked task actions.
- [ ] 5.3 Finalize vault/MRU persistence details (storage location, max length, pruning policy, update triggers).
- [ ] 5.4 Define failure-mode UX/messages for missing Taskwarrior, invalid vault paths, canceled prompts, and empty task results.
- [ ] 5.5 Define and document boundaries between Taskwarrior personal tasks and Overseer run/build tasks.
