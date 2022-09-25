function __install_dracula_theme {
    local destination=~/.config/bash/bashrc.d/dracula-theme.priv.bash
    local source=https://raw.githubusercontent.com/dracula/tty/master/dracula-tty.sh

    if [ ! -f "$destination" ]
    then
        echo "Downloading dracula theme..."
        curl -Ls -o "$destination" "$source"
    fi
}

__install_dracula_theme
