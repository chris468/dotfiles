function auto_update_dotfiles
    set -g _dotfiles_autoupdate_status_dir ~/.cache/dotfiles
    set -g _dotfiles_autoupdate_logfile $_dotfiles_autoupdate_status_dir/auto-update.log
    set -g _dotfiles_autoupdate_statusfile $_dotfiles_autoupdate_status_dir/auto-update-status.txt
    set -g _dotfiles_autoupdate_interval_days 1

    function log_exists
        test -e $_dotfiles_autoupdate_logfile
    end

    function log_updated_since_interval
        test -z (find $_dotfiles_autoupdate_logfile -mtime +$_dotfiles_autoupdate_interval_days)
    end

    function should_update
        not log_exists ; or not log_updated_since_interval
    end

    function update
        mkdir -p $_dotfiles_autoupdate_status_dir
        echo Starting update at (date) > $_dotfiles_autoupdate_logfile

        set -l dotfiles_dir (dirname (dirname (readlink ~/.config/fish)))
        $dotfiles_dir/update.sh --status-file $_dotfiles_autoupdate_statusfile 2>&1 >> $_dotfiles_autoupdate_logfile
    end

    if should_update
        echo "Updating dotfiles in background. See $_dotfiles_autoupdate_logfile."
        update
    else
        cat $_dotfiles_autoupdate_statusfile
    end

    set -e _dotfiles_autoupdate_status_dir
    set -e _dotfiles_autoupdate_logfile
    set -e _dotfiles_autoupdate_statusfile
    set -e _dotfiles_autoupdate_interval_days
end

