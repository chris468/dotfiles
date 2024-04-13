use chris468

$env.config = {
    color_config: (chris468 config theme default)

    cursor_shape: {
        vi_insert: line
        vi_normal: block
    }

    edit_mode: vi

    keybindings: [
        {
            name: fzf_history
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: [
                {
                    send: ExecuteHostCommand
                    cmd: "commandline edit (
                        history
                            | each { |it| $it.command }
                            | uniq
                            | reverse
                            | str join (char -i 0)
                            | fzf --read0 --layout=reverse --height=40% -q (commandline)
                            | decode utf-8
                            | str trim
                    )"
                }
            ]
        }
    ]
    show_banner: false
}

source ~/.config/nushell/oh-my-posh.nu
