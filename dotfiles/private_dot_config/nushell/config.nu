export-env {
    use _config *

    $env.config = {
        color_config: (theme default)

        cursor_shape: {
            vi_insert: line
            vi_normal: block
        }

        edit_mode: vi

        hooks: {
            pre_prompt: []
            pre_execution: []
            env_change: {}
            display_output: "if (term size).columns >= 100 { table -e } else { table }"
            command_not_found: []
        }

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
                                | reverse
                                | uniq
                                | str join (char -i 0)
                                | fzf --read0 --layout=reverse --height=40% +s -q (commandline)
                                | decode utf-8
                                | str trim
                        )"
                    }
                ]
            }
        ]
        show_banner: false
    }

    prompt setup

    if $nu.os-info.name == "linux" {
        use _lib/mise.nu
    }

    hook-fix-env-path
    hook-update-tmux-environment

    upgrade-chezmoi
    init-carapace
}
