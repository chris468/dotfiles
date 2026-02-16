# Tools Ansible (Local)

This playbook installs system tools on the local machine using the shared
`tools.yaml` definition.

Notes:
- Linux/macOS only. Windows should use the winget + PowerShell path.
- The default `tools_file` points at `~/.local/share/chris468/tools/tools.yaml`.
  You can override it if you want to run directly from the repo.

Example:
```
ansible-playbook site.yml -K -e "categories=['essential','kubernetes']"
ansible-playbook site.yml -K -e "use_nix=true"
ansible-playbook site.yml -K -e "use_nix=true nix_install_mode=single"
ansible-playbook site.yml -K -e "tools_file=/path/to/.chezmoidata/tools.yaml"
```
