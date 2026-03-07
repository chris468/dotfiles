# Neovim Notes and Task Management

## Dependencies

- `epwalsh/obsidian.nvim` for note workflows.
- Task management uses the `task` CLI (`taskwarrior`) through Lua command integration.

If `task` is missing, task mappings show an error and no task action runs.

## Vault Resolution

- Opening a markdown file under a directory tree that contains `.obsidian` auto-detects that vault.
- Note and task actions under `<leader>N` prompt for a vault when no configured/detected vault is available.
- Vault state is persisted in `stdpath("state")/chris468-vault-state.json`.
- MRU vault history is deduplicated, prunes missing directories, and is capped at 10 entries.

## Keymaps

Notes:

- `<leader>Nn`: new note
- `<leader>Nf`: find note
- `<leader>Nt`: today note
- `<leader>Ny`: yesterday note
- `<leader>Nm`: tomorrow note
- `<leader>Nr`: recent notes
- `<leader>Nv`: pick/switch vault

Tasks:

- `<leader>Nk`: task hub/list
- `<leader>Nka`: add task
- `<leader>Nkt`: today tasks
- `<leader>Nku`: update task (action picker: `done`, `start`, `stop`, `annotate`)
- `<leader>Nkd`: mark done
- `<leader>Nkp`: pending tasks
- `<leader>Nkr`: refresh current task view
- `<leader>Nkv`: toggle pending/today view

## Behavior and Boundaries

- Task actions under `<leader>Nk*` always resolve a vault before running.
- `<leader>Nk*` controls personal Taskwarrior tasks.
- Overseer mappings (`<leader>o*`) remain for run/build automation and are intentionally separate.
