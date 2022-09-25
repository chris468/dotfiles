~/.config/yadm/scripts/auto-update.sh -reset
~/.config/yadm/scripts/auto-update.sh

function _set_auto_update_status {
    auto_update_log_dir=~/.cache/yadm/auto-update
    auto_update_status=$auto_update_log_dir/status.log

    if [ -e $auto_update_status ]
    then
        export YADM_AUTO_UPDATE_STATUS=$(cat $auto_update_status)
    else
        unset YADM_AUTO_UPDATE_STATUS
    fi

    if [ -n "$(yadm status -s)" ]
    then
        export YADM_CHANGES=1
    else
        export YADM_CHANGES=0
    fi
}

# Note: put at the fronte of the list so that it will run before
#       oh-my-posh. But note that tnis needs to be added *after*
#       oh-my-posh has already been added, becasue it also adds
#       to the front.
PROMPT_COMMAND="_set_auto_update_status; $PROMPT_COMMAND"
