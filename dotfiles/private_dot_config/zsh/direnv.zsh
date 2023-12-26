# sign .envrc with `gpg --detach-sign .envrc`
# gpgv looks for trusted keys in ~/.gnupg/trustedkeys.kbx by default.
# trust a key with with `gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.kbx --import <key>`
 
if command -v direnv >&/dev/null ; then
    function _allow_signed_direnv() {
        if [ -n "$DIRENV_DIR" ] && [ "$CHECK_SIGNED_ENVRC" != "$DIRENV_DIR" ] ; then
            if direnv status | grep -q "Found RC allowed false" ; then
                local envrc="$(direnv status | grep "Loaded RC path" | cut -d' ' -f 4-)"
                local signature="${envrc}.sig"
                if [ -f "$signature" ]  && gpgv "$signature" "$envrc" &>/dev/null ; then
                    echo "Allowing signed .envrc"
                    direnv allow
                fi
            fi
        fi
        CHECK_SIGNED_ENVRC="$DIRENV_DIR"
    }
    eval "$(direnv hook zsh)"
    add-zsh-hook chpwd _allow_signed_direnv
    add-zsh-hook precmd _allow_signed_direnv
fi
