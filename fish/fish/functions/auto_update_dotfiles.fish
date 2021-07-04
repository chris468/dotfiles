function auto_update_dotfiles
    set -g _dotfiles_autoupdate_status_dir ~/.cache/dotfiles
    set -g _dotfiles_autoupdate_logfile $_dotfiles_autoupdate_status_dir/auto-update.log
    set -g _dotfiles_autoupdate_statusfile $_dotfiles_autoupdate_status_dir/auto-update-status.txt
    set -g _dotfiles_autoupdate_interval_minutes 120

    function log_exists
        test -e $_dotfiles_autoupdate_logfile
    end

    function log_updated_since_interval
        set -l result (find $_dotfiles_autoupdate_logfile -mmin -$_dotfiles_autoupdate_interval_minutes)
        test -n "$result"
    end

    function should_update
        not log_exists ; or not log_updated_since_interval
    end

    function record_last_status_update_time
        set -g _dotfiles_last_status_update_time (get_last_dotfiles_status_update_time)
    end

    function update
        record_last_status_update_time
        mkdir -p $_dotfiles_autoupdate_status_dir
        echo Starting update at (date) > $_dotfiles_autoupdate_logfile

        set -l dotfiles_dir (dirname (dirname (readlink ~/.config/fish)))
        $dotfiles_dir/update.sh --status-file $_dotfiles_autoupdate_statusfile >> $_dotfiles_autoupdate_logfile 2>&1 &
    end

    if should_update
        echo "Updating dotfiles in background. See $_dotfiles_autoupdate_logfile."
        update
    else
        cat $_dotfiles_autoupdate_statusfile
    end
end

