{{- if eq .chezmoi.os "windows" }}
[System.Environment]::SetEnvironmentVariable('LUNARVIM_CONFIG_DIR', "$HOME/.config/lvim", "Process")
[System.Environment]::SetEnvironmentVariable('LUNARVIM_CONFIG_DIR', "$HOME/.config/lvim", "User")
{{- end }}
