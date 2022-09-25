~/.config/yadm/scripts/auto-update.sh -reset
~/.config/yadm/scripts/auto-update.sh

function _set_auto_update_status {
    auto_update_log_dir=~/.cache/yadm/auto-update
    auto_update_status=$auto_update_log_dir/status.log

    [ -e $auto_update_status ] \
        && export YADM_AUTO_UPDATE_STATUS=$(cat $auto_update_status) \
            || unset YADM_AUTO_UPDATE_STATUS
}

PROMPT_COMMAND="_set_auto_update_status; $PROMPT_COMMAND"
