export def astrovim [...rest] {
    NVIM_APPNAME=astrovim nvim ...$rest
}

export def lazyvim-original [...rest] {
    NVIM_APPNAME="lazyvim-original" nvim ...$rest
}

export def lazyvim [...rest] {
    NVIM_APPNAME=lazyvim nvim ...$rest
}

export def lvim [...rest] {
    $env.LUNARVIM_RUNTIME_DIR = ($env | get --ignore-errors LUNARVIM_RUNTIME_DIR | default $"($env.HOME)/.local/share/lunarvim")
    $env.LUNARVIM_CONFIG_DIR = ($env | get --ignore-errors LUNARVIM_CONFIG_DIR | default $"($env.HOME)/.config/lvim")
    $env.LUNARVIM_CACHE_DIR = ($env | get --ignore-errors LUNARVIM_CACHE_DIR | default $"($env.HOME)/.cache/lvim")

    $env.LUNARVIM_BASE_DIR = ($env | get --ignore-errors LUNARVIM_BASE_DIR | default $"($env.HOME)/.local/share/lunarvim/lvim")

    NVIM_APPNAME=lvim nvim -u $"($env.LUNARVIM_BASE_DIR)/init.lua" ...$rest
}
