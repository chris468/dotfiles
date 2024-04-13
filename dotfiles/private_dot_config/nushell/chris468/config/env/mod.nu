use set-environment.nu
use ../../util/

export def --env main [] {
    set-environment

    if ('/etc/locale.conf' | path exists) {
        'source /etc/locale.conf' | util capture-env --vars [ LANG ]
    }
}

