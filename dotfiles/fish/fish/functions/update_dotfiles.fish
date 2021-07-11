function update_dotfiles
    set -l dotfiles_dir (dirname (dirname (readlink ~/.config/fish)))
    $dotfiles_dir/update.sh $argv
end
