function get_last_dotfiles_status_update_time
    stat "$_dotfiles_autoupdate_statusfile" -c "%Y" 2>/dev/null || true
end
