use ../../util/
use import-system-profile.nu
use set-environment.nu

def --env dircolors [] {
    const script_path = ~/.config/dircolors/dircolors.sh
    const set_dircolors_env = 'eval "$(SHELL=nu bash ' + $script_path + ')"'
    if ($script_path | path exists) {
        $set_dircolors_env | util capture-env
    }
}

def --env delta [] {
    if (which delta | is-not-empty) {
        $env.GIT_PAGER = delta
    }
}

def --env less [] {
    let $less = $env | get -i LESS | default ""
    $env.LESS = $less + (["-R", "-F"] | each { |flag| if $flag not-in $less { $"($flag) " } else { "" } } | str join)
}

def --env libvirt [] {
    $env.LIBVIRT_DEFAULT_URI = "qemu:///system"
}

def --env ssh-agent [] {
    if "SSH_AUTH_SOCK" not-in $env {
        $env.SSH_AUTH_SOCK = $"/tmp/($env.USER)-ssh.sock"
        if (ssh-add -l | complete).exit_code >= 2 {
            if ($env.SSH_AUTH_SOCK | path exists) {
                rm --permanent $env.SSH_AUTH_SOCK
            }

            ^ssh-agent -t 14400 -a $env.SSH_AUTH_SOCK o+e>| ignore
        }
    }
}

export def --env main [] {
    import-system-profile

    set-environment

    dircolors
    less
    libvirt
    ssh-agent
}

