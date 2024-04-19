use set-environment.nu
use ../../util/

export def --env main [] {
    set-environment

    let profilescripts = [
        (if $nu.os-info.name != "windows" { ['test -f /etc/profile && source /etc/profile'] } else [])
        'test -f ~/.config/shrc.d/51-delta.sh && source ~/.config/shrc.d/51-delta.sh'
        'eval "$(SHELL=nu bash ~/.config/dircolors/dircolors.sh)"'
        'test -f ~/.config/shrc.d/less.sh && source ~/.config/shrc.d/less.sh'
        'test -f ~/.config/shrc.d/libvirt.sh && source ~/.config/shrc.d/libvirt.sh'
        'test -f ~/.config/shrc.d/ssh-agent.sh && source ~/.config/shrc.d/ssh-agent.sh'
    ] | flatten

    $profilescripts | str join ' ; ' | util capture-env
}

