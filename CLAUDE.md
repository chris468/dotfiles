# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A [chezmoi](https://chezmoi.io) dotfiles repository managing configuration across Linux, macOS, and Windows. The actual dotfile sources live in the `dotfiles/` subdirectory (set via `.chezmoiroot`).

## Common commands

```bash
# Apply all dotfiles to the home directory
chezmoi apply

# Apply a single file
chezmoi apply "$(chezmoi target-path <source-path>)"

# Test a template
chezmoi execute-template < dotfiles/some-file.tmpl

# Pull upstream changes and apply
chezmoi update --apply
```

## Chezmoi file naming conventions

Chezmoi source filenames encode metadata via prefixes/suffixes before chezmoi maps them to their target paths:

| Prefix/Suffix        | Meaning                                                 |
| -------------------- | ------------------------------------------------------- |
| `dot_`               | maps to `.` in target (e.g. `dot_bashrc` → `~/.bashrc`) |
| `private_`           | target gets restricted permissions (600/700)            |
| `symlink_`           | creates a symlink instead of a file                     |
| `create_`            | only creates the file if it doesn't exist               |
| `.tmpl` suffix       | processed as a Go template                              |
| `run_onchange_`      | script run when its content changes                     |
| `run_once_`          | script run only once ever                               |
| `.chezmoiscripts/`   | directory for run scripts                               |
| `.chezmoitemplates/` | shared template partials                                |

## Configuration system

### `dotfiles/.chezmoi.yaml.tmpl`

Generates `~/.config/chezmoi/chezmoi.yaml`. The only prompted value is `work` (bool). Everything else lives under the `config` key in `~/.config/chezmoi/chezmoi.yaml`:

```yaml
data:
  config:
    work: true/false
    font:
      family: "FiraCode Nerd Font"
      size: 13
    theme: catppuccin-mocha # or: nord, tokyonight-night
    nvim:
      flavor: lazyvim # or: lvim, nvim-custom, nvim-custom2, astrovim (unset = default)
    ssh_hosts:
      - name: myserver
        host: myserver.example.com
        type: trusted # or: wezterm
```

### `dotfiles/.chezmoitemplates/config`

Merges `defaults`, OS-specific `defaults.override`, and user `config` via `mergeOverwrite`. Use `{{ template "config" . | fromJson }}` to get the resolved config in templates.

### `dotfiles/.chezmoiignore`

Platform-conditional: `AppData/` and Windows-only files are ignored on non-Windows; `Library/` is ignored on non-macOS; `Documents/` and other Windows paths are ignored on non-Windows.

## Platform detection in templates

```
{{ if eq .chezmoi.os "windows" }} ... {{ end }}
{{ if eq .chezmoi.os "darwin" }} ... {{ end }}
{{ if .config.work }} ... {{ end }}
```

## Tool installation system

Tools are defined in `dotfiles/.chezmoidata/tools.yaml` (validated by `schemas/tools.schema.json`) and installed by `~/.local/share/chris468/bin/install-tools` (bash) or `install-tools.ps1` (Windows).

### `tools.yaml` structure

```yaml
tools:
  <category>: # essential | container | kubernetes | aws | azure
    nerdfonts:
      - name: Hack
    packages:
      - name: ripgrep # package name for default manager
        manager: os # os (default) | nix | psmodule
        platforms: # optional allowlist/denylist
          exclude: false
          matches:
            - match: { os: linux }
        overrides: # per-platform name/manager overrides, first match wins
          - match: { os: windows, family: debian, distro: ubuntu, manager: os }
            name: BurntSushi.ripgrep.MSVC
            manager: os
```

`match` fields are all optional and ANDed together. `os`: `linux`/`darwin`/`windows`. `family`: `debian`/`redhat`/`arch`/`suse`. `distro`: any string. `manager`: `os`/`nix`/`psmodule`.

### How install-tools works

**Linux/macOS** (`executable_install-tools` bash script → ansible playbook at `dotfiles/dot_local/share/chris468/tools/ansible/site.yml`):

- Reads `tools.yaml`, resolves overrides for the current platform
- `manager: os` packages → `brew` (macOS) or native package manager (`apt`/`dnf`/`pacman`/`zypper`)
- `manager: nix` packages → home-manager (installs/bootstraps nix if needed on Debian)
- Nerd Fonts → `oh-my-posh font install`

**Windows** (`executable_install-tools.ps1`):

- Reads `tools.yaml` directly (via `PowerShell-Yaml` module, auto-installed)
- `manager: os` → `winget import` (bulk install via generated JSON payload)
- `manager: psmodule` → `Install-Module`
- Nerd Fonts → `oh-my-posh font install`

### Running install-tools

```bash
# Install essential tools (default)
install-tools

# Install specific categories
install-tools --container --kubernetes

# Install all categories
install-tools --all

# Linux: nix daemon mode options
install-tools --nix-daemon          # daemon (default)
install-tools --no-nix-daemon       # single-user nix
install-tools --nix-daemon-direct   # start nix daemon directly (for containers)
```

```powershell
# Windows
install-tools                         # essential
install-tools -Container -Kubernetes  # specific categories
install-tools -All                    # all
```

### Testing

Tests live in `tests/` and are driven by `Taskfile.yml` (requires [Task](https://taskfile.dev)):

```bash
# Run tests in an Incus VM
task test:incus:debian
task test:incus:ubuntu
task test:incus:fedora
task test:incus:arch
task test:incus:tumbleweed
task test:incus:all        # all distros sequentially

# Run tests in Docker containers (uses --nix-daemon-direct)
task test:docker:debian
task test:docker:all

# Run on the current macOS machine
task test:mac

# Run on the current Windows machine
task test:win

# Reset cached Incus VMs
task test:incus:reset:debian
task test:incus:reset:all
```

## Neovim config (`dotfiles/private_dot_config/nvim/`)

Based on [LazyVim](https://lazyvim.org). Structure:

- `init.lua` — bootstraps lazy.nvim via `config.lazy`
- `lua/config/lazy.lua` — lazy.nvim setup; imports `lazyvim.plugins`, `plugins.extras`, `plugins`
- `lua/config/keymaps.lua` — custom keymaps (overrides LazyVim defaults)
- `lua/config/autocmds.lua` — entry point; delegates to `autocmds/*.lua`
- `lua/config/chezmoi.lua.tmpl` — sets `vim.g.chris468_ai_providers` based on work/home
- `lua/plugins/` — plugin specs (one file per plugin or feature area)
- `lua/plugins/extras/` — optional extras loaded explicitly in `lazy.lua`
- `lua/util/` — custom Lua utilities

### Key custom utilities

- `util.chezmoi` — apply/update chezmoi from within neovim (keymaps: `<leader>z*`)
- `util.ui.path_selector` — MRU path picker backed by snacks explorer; persists history to `stdpath("state")/path_selector_history.json`
- `util.ui.menu` — generic UI menu helper
- `util.debounce` — debounce utility

### Picker

snacks.nvim is the picker (not telescope). Custom `toggle_cwd` action cycles root → cwd → global. `<C-\>c` toggles picker scope. Custom `plugin` source browses lazy.nvim plugins.

### AI providers (`lua/plugins/extras/ai.lua` + `lua/plugins/ai.lua`)

Provider is set via `vim.g.chris468_ai_providers` (from the chezmoi template): `codeium` for personal, `copilot`/`copilot-chat` for work.

### Local plugins

Custom local neovim plugins are kept in `$XDG_DATA_HOME/chris468/neovim/plugins` and loaded with the lazy plugin manager. Plugins changes should include testing w/ the test framework from plenary.

#### Local utils plugin

A local plugin at `$XDG_DATA_HOME/chris468/neovim/plugins/utils` (named `chris468-utils`) is loaded as a lazy dependency of snacks. It provides `chris468-utils.unicode` for icon picking.
