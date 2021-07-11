function auto_update_dotfiles
    set -l dotfiles_dir (readlink -m (readlink -m ~/.config/fish/functions/auto_update_dotfiles.fish)/../../../../..)
    env -C $dotfiles_dir python3.9 -m manager auto-update
        and set -g _dotfiles_auto_updating
end

