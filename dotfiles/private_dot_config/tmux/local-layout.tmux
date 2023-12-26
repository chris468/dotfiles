# sign with `gpg --detach-sign .layout.tmux``
# gpgv looks for trusted keys in ~/.gnupg/trustedkeys.kbx by default.
# trust a key with with `gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.kbx --import <key>`
# if use-keyboxd is enabled (check ~/.gnupg/common.conf, default on mac), even explicitly specified keyrings will be ignored.

if-shell 'test -r .layout.tmux' {
    if-shell 'test -r .layout.tmux.sig' {
        if-shell 'gpgv .layout.tmux.sig .layout.tmux' {
            source-file .layout.tmux
        } {
            display-message '#[fg=##d08770]Invalid signature for .layout.tmux'
        }
    } {
        display-message '#[fg=##d08770]Missing signature for .layout.tmux'
    }
}
