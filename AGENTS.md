# Repository Guidelines

## Project Structure & Module Organization

- `README.md`: installation and basic configuration notes.
- `docs/`: helper install/remove scripts (Linux `install.sh`, Windows `install.ps1`, `remove-yadm-files.sh`).
- `dotfiles/`: the chezmoi-managed dotfiles and templates.
  - dotfiles/private_dot_config/nvim: my neovim configuration, using lazyvim
  - dotfiles/dot_local/share/chris468/neovim/plugins: my custom neovim plugins
- Naming conventions for managed files:
  `dot_` → files that land in `$HOME` (example: `dot_bashrc`).
  `private_` → private entries; `private_dot_...` maps to `$HOME/.config/...`.
  `symlink_` → managed symlinks.
  `executable_` → installed with executable bit.
  `remove_` → cleanup hooks.
  `*.tmpl` → templates processed by chezmoi.

## Build, Test, and Development Commands

- `sh -c "$(curl -fsLS chris468.github.io/dotfiles/install.sh)"` installs via chezmoi on Linux.
- `(Invoke-RestMethod -UseBasicParsing https://chris468.github.io/dotfiles/install.ps1) | pwsh -c -` installs via chezmoi on Windows.
- `curl -fsLS https://chris468.github.io/dotfiles/remove-yadm-files.sh | sh -` backs up and removes prior yadm-managed files.
- Local apply workflow: `chezmoi diff` to review changes, `chezmoi apply` to apply.

## Coding Style & Naming Conventions

- Match existing file formatting and indentation in each language (shell, PowerShell, Lua, TOML, etc.).
- Keep scripts POSIX-sh compatible unless the file already uses `bash` features.
- Follow chezmoi naming patterns (`dot_`, `private_`, `symlink_`, `executable_`, `remove_`, `*.tmpl`).

## Testing Guidelines

- No repository-wide test runner is defined.
- Lua specs live at `dotfiles/dot_local/share/chris468/neovim/plugins/tools/tests/` and cover only those Neovim plugins.
- Specs use `plenary.busted`/`luassert` and are typically run in Neovim headless.

## Commit & Pull Request Guidelines

- Commit messages are short and direct; a scope prefix like `tools:` is common (example: `tools: update playbook...`).
- Keep PRs small and focused. Include:
  - A summary of changes.
  - Testing notes or a clear statement if not tested.
  - Screenshots only when UI/terminal visuals change.

## Security & Configuration Tips

- Personal or machine-specific settings belong in templates and `private_` files.
- Prefer `$HOME/.gitconfig` for local git overrides; this repo adds a dotfiles include.
