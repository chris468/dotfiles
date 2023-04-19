function update-dotfiles
    echo "Checking for dotfile updates..."
    yadm fetch --no-prune

    if yadm status -sb | grep behind ;
        echo "Updating dotfiles..."
        yadm pull -q --no-prune
        yadm bootstrap
    else
        echo "Dotfiles up to date."
    end
end
