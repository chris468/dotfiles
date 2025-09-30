use ../chris468/util/
use set-environment.nu

def --env dircolors [] {
    const script_path = "~/.config/dircolors/dircolors.sh"
    const set_dircolors_env = 'eval "$(SHELL=nu bash ' + $script_path + ')"'
    if ($script_path | path exists) {
        $set_dircolors_env | util env capture
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
        let $user = $env.USER? | default $env.USERNAME?
        if $user == null { error make { msg: "could not determine username" } }
        $env.SSH_AUTH_SOCK = ($nu.temp-path | path join $"($user)-ssh.sock")
        if (ssh-add -l | complete).exit_code >= 2 {
            if ($env.SSH_AUTH_SOCK | path exists) {
                rm --permanent $env.SSH_AUTH_SOCK
            }

            ^ssh-agent -t 14400 -a $env.SSH_AUTH_SOCK o+e>| ignore
        }
    }
}

def --env gpg [] {
    if (which tty | is-not-empty) {
        $env.GPG_TTY = (tty)
    }
}

def --env profile [] {
    if $nu.os-info.name != "windows" {
        'for p in /etc/profile ~/.profile ; do test -f $p && source $p ; done' | util env capture
    }
}

def --env configure-carapace [] {
    if (which carapace | is-not-empty) {
        $env.CARAPACE_BRIDGES = 'zsh,fish,bash,powershell'
        mkdir ~/.cache/carapace
        carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
    }
}

def --env configure_zoxide [] {
  if (which zoxide | is-not-empty) {
    zoxide init nushell 
  } else {
    "# zoxide not installed"
  } | save -f ~/.config/nushell/scripts/_lib/.zoxide.nu
}

def generate-oh-my-posh-config [] {
    if (which oh-my-posh | is-not-empty) {
        oh-my-posh init nu --config ~/.config/oh-my-posh/chris468.omp.yaml --print | save --force ~/.config/nushell/scripts/_lib/.oh-my-posh.nu
    }
}

export def --env main [] {
    set-environment
    profile
    dircolors
    gpg
    less
    libvirt
    configure-carapace
    generate-oh-my-posh-config
    configure_zoxide

    if $nu.os-info.name != "windows" { ssh-agent }
}

