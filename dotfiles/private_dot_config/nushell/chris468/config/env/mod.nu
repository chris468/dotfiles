use set-environment.nu
use ../../util/

export def --env main [] {
    set-environment

    if ('/etc/profile' | path exists) {
        'source /etc/profile' | util capture-env
    }
}

