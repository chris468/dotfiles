use set-environment.nu
use ../../util/

const profilescripts = [
    'test -f /etc/profile && source /etc/profile'
    'test -f ~/.config/shrc.d/51-delta.sh && source ~/.config/shrc.d/51-delta.sh'
    'eval "$(bash ~/.config/dircolors/dircolors.sh)"'
    'test -f ~/.config/shrc.d/less.sh && source ~/.config/shrc.d/less.sh'
    'test -f ~/.config/shrc.d/libvirt.sh && source ~/.config/shrc.d/libvirt.sh'
    'test -f ~/.config/shrc.d/ssh-agent.sh && source ~/.config/shrc.d/ssh-agent.sh'
]

export def --env main [] {
    set-environment

    $profilescripts | str join ' ; ' | util capture-env
}

