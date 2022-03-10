if not status is-interactive
    exit
end

~/.config/yadm/scripts/auto-update.sh -reset
~/.config/yadm/scripts/auto-update.sh

function _set_auto_update_status --on-event fish_prompt
    set auto_update_log_dir ~/.cache/yadm/auto-update
    set auto_update_status $auto_update_log_dir/status.log

    [ -e $auto_update_status ]
        and set -gx YADM_AUTO_UPDATE_STATUS (cat $auto_update_status)
        or set -e YADM_AUTO_UPDATE_STATUS
end
