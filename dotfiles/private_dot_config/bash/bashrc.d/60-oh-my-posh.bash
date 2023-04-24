function __configure_oh_my_posh_prompt {
    if command -v oh-my-posh &> /dev/null
    then
        local posh_theme=~/.config/oh-my-posh/current-theme.omp.json

        eval "$(oh-my-posh init bash --config $posh_theme)"
    fi
}

__configure_oh_my_posh_prompt

