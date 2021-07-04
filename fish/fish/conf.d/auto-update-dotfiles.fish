auto_update_dotfiles

function _dotfiles_print_auto_update_status --on-event fish_prompt
    if set -q -g _dotfiles_last_status_update_time
        set -l update_time (get_last_dotfiles_status_update_time)
        if [ "$update_time" != "$_dotfiles_last_status_update_time" ]
            echo
            cat $_dotfiles_autoupdate_statusfile
            echo

            set -e -g _dotfiles_last_status_update_time
        end
    end
end

