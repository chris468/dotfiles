function install-lvim {
    function die {
        echo "$1" >&2
        return 1
    }
    brew install node rust || return die 'failed to install dependencies' >&2
    if [ ! -f ~/.local/bin/nvim ]
    then
        curl -L -o ~/.local/bin/nvim \
            https://github.com/neovim/neovim/releases/download/v0.8.3/nvim.appimage \
            || return die 'failed do download nvim'
        chmod +x ~/.local/bin/nvim
    fi

    curl -L -o /tmp/install-lvim.sh \
        https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh \
        || return die 'failed do download lvim' >&2

    LV_BRANCH='release-1.2/neovim-0.8' bash /tmp/install-lvim.sh -- -y --install-dependencies
}
