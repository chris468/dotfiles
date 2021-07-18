if not status is-interactive
    exit
end

auto_update_dotfiles

function _dotfiles_print_auto_update_status --on-event fish_prompt
    if set -q -g _dotfiles_auto_updating
        and test -e ~/.cache/dotfiles/auto-update-complete
        and test -e ~/.cache/dotfiles/auto-update-status.txt
        set -e -g _dotfiles_auto_updating
        echo
        cat ~/.cache/dotfiles/auto-update-status.txt
        echo
        echo
    end
end

