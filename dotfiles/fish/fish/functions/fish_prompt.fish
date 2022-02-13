function fish_prompt --description 'Informative prompt'
    #Save the return status of the previous command
    set -l last_pipestatus $pipestatus

    switch "$USER"
        case root toor
            printf '%s@%s %s%s%s# ' $USER (prompt_hostname) (set -q fish_color_cwd_root
                                                             and set_color $fish_color_cwd_root
                                                             or set_color $fish_color_cwd) \
                (prompt_pwd) (set_color normal)
        case '*'
            set -l time (date "+%H:%M:%S")
            set -l user (set_color brblue)"$USER@"(prompt_hostname)
            set -l workingdir (set_color $fish_color_cwd)(prompt_pwd)
            set -l pipestatus_string (__fish_print_pipestatus "[" "] " "|" (set_color $fish_color_status) \
                                      (set_color --bold $fish_color_status) $last_pipestatus)
            set -l vcs_prompt (fish_git_prompt)

            printf '[%s] %s %s %s%s\f\r%s > ' \
                "$time" \
                "$user" \
                "$workingdir" \
                "$pipestatus_string" \
                (set_color normal) \
                "$vcs_prompt"
    end
end
