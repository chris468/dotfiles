if (("SSH_CONNECTION" in $env) and ("SSH_TTY" not-in $env)) {
    if ((which zsh) | is-not-empty) { exec zsh } else { exec bash }
}

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | compact --empty | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | compact --empty | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join scripts)
]

export-env {
    use $"($nu.default-config-dir)/scripts/_env"
    _env
}
