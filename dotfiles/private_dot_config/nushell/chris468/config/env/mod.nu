use set-environment.nu
use ../../util/

const profilescripts = [
    'test -f /etc/profile && source /etc/profile'
    'eval "$(bash ~/.config/dircolors/dircolors.sh)"'
]

export def --env main [] {
    set-environment

    $profilescripts | str join ' ; ' | util capture-env
}

