function __configure_oh_my_posh_prompt {
    if command -v oh-my-posh &> /dev/null
    then
        local oh_my_posh_path=~/.config/oh-my-posh/
        posh_theme=$oh_my_posh_path/$(cat $oh_my_posh_path/current-theme)

        eval "$(oh-my-posh init bash --config $posh_theme)"
    fi
}

__configure_oh_my_posh_prompt

