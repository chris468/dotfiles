function _set_auto_update_status {
    auto_update_log_dir=~/.cache/yadm/auto-update
    auto_update_status=$auto_update_log_dir/status

    if [ -e $auto_update_status ]
    then
        export YADM_AUTO_UPDATE_STATUS=$(cat $auto_update_status)
    else
        unset YADM_AUTO_UPDATE_STATUS
    fi

#   if [ -n "$(yadm status -s -uno)" ]
#   then
#       export YADM_CHANGES=1
#   else
#       export YADM_CHANGES=0
#   fi
}

_set_auto_update_status
