# Test Plan: Install-Tools Cross-OS Validation

## Summary
This plan validates that `install-tools` can find and install packages across supported OSes. Linux testing is Incus-first locally and Docker-based in CI. Tests are driven by Taskfile tasks and use shared scripts placed in `tests/` at the repo root (sibling of `dotfiles/`). GitHub Actions runs are manual-only.

## Goals
- Confirm packages are found and installed across OS matrix.
- Avoid service enablement requirements (package install success only).
- Prefer Incus for Linux tests locally and Docker in CI.
- Use Taskfile tasks as the single entrypoint for local + CI.

## Non-Goals
- Validate long-running services or systemd units.
- Automatically run on every push/PR.

## Changes Required
### CLI flags (install-tools)
Add flags to `dot_local/share/chris468/bin/executable_install-tools`:
- `--nix-daemon` (default)
- `--no-nix-daemon`
- `--sudo-password-prompt` (default)
- `--no-sudo-password-prompt`

Flags override defaults and pass through to ansible via `-e`.

### Ansible playbook
Update `dot_local/share/chris468/tools/ansible/site.yml`:
- Add variable `nix_install_mode` with default `daemon`.
- When `nix_install_mode=single`, install Nix with `--no-daemon` and write user config to `~/.config/nix/nix.conf`.

### Test scripts
Place in `tests/` at the repo root (sibling of `dotfiles/`):
- `tests/test-install-tools.sh`
- `tests/test-install-tools.ps1`

### Taskfile
Create `Taskfile.yml` at the repo root (sibling of `dotfiles/`).

## Test Harness Behavior
### `tests/test-install-tools.sh`
1. Create temp HOME for the test user if needed.
2. Set `XDG_DATA_HOME=$HOME/.local/share`.
3. Install `chezmoi` via GitHub release binary.
4. `chezmoi init --apply --source "$GITHUB_WORKSPACE"`.
5. Verify `$XDG_DATA_HOME/chris468/tools/tools.yaml` exists.
6. Run `install-tools --all` with passed flags.
7. Fail on error; write logs to a temp dir.

### `tests/test-install-tools.ps1`
1. Prepare temp profile for test user.
2. Install `chezmoi` via GitHub release binary.
3. `chezmoi init --apply --source $env:GITHUB_WORKSPACE`.
4. Verify `$env:XDG_DATA_HOME\chris468\tools\tools.yaml` exists.
5. Run `install-tools.ps1 -All`.
6. Fail on error; write logs.

## Local Testing
### Linux (Incus)
Use Incus VMs for all Linux distros locally. Create a normal user via `useradd --create-home ci`.

Taskfile tasks (local):
- `task test:incus:debian`
- `task test:incus:ubuntu`
- `task test:incus:fedora`
- `task test:incus:arch`
- `task test:incus:tumbleweed`

Each task:
1. Launch Incus VM for the distro.
2. Create `ci` user.
3. Install prerequisites (`curl`, `git`, `python3`, `pipx`, `sudo`).
4. Install `chezmoi`.
5. Run `tests/test-install-tools.sh`.

### Linux (Docker)
Use Docker containers for Linux CI and optional local runs.

Taskfile tasks (local/CI):
- `task test:docker:debian`
- `task test:docker:ubuntu`
- `task test:docker:fedora`
- `task test:docker:arch`
- `task test:docker:tumbleweed`

Each task:
1. Launch container for the distro.
2. Create `ci` user.
3. Install prerequisites (`curl`, `git`, `python3`, `pipx`, `sudo`).
4. Install `chezmoi`.
5. Run `tests/test-install-tools.sh`.

### macOS (local)
Taskfile task: `task test:mac`.
- Create temporary normal user.
- Install `chezmoi`.
- Run `tests/test-install-tools.sh`.

### Windows (local)
Taskfile task: `task test:win`.
- Create temporary admin user (to avoid winget elevation prompts).
- Install `chezmoi`.
- Run `tests/test-install-tools.ps1`.

## CI Strategy (GitHub Actions)
- Manual-only trigger: `workflow_dispatch`.
- Actions call Taskfile tasks.
- Linux jobs use Docker on `ubuntu-latest`.
- Windows/macOS jobs call `test:win` and `test:mac` tasks.

### CI Matrix
Linux (Docker):
- Debian
- Ubuntu
- Fedora
- Arch
- Tumbleweed

Other:
- macOS
- Windows

## Nix Mode
- Linux Incus tests: `--nix-daemon` and `--no-sudo-password-prompt`.
- Linux Docker tests: `--no-nix-daemon` (single-user) and `--no-sudo-password-prompt`.
- macOS/Windows: defaults (no Nix on Windows; macOS uses brew).

## Acceptance Criteria
- All jobs complete without interactive prompts.
- Packages are found and installed on all OSes in the matrix.
- Debian and Ubuntu run as separate Linux jobs.
- Logs are captured for each run.

## Estimated GitHub Actions Minutes
Assuming `install-tools` takes ~5 minutes and ~3 minutes overhead per job:
- Linux jobs: 5 * 8 = ~40 minutes
- macOS: ~8 minutes
- Windows: ~8 minutes
Total ≈ 56 minutes per full run.

## Notes
- Service enablement is not required for test success.
- Incus availability is required for local Incus tests; CI uses Docker.
