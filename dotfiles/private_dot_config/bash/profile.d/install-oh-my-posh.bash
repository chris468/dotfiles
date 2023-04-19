# Modify template at '{{ yadm.source }}'

oh_my_posh_version="14.26.0"

function __install_oh_my_posh {

    function download {
        curl -L -o ~/.local/bin/oh-my-posh${oh_my_posh_extension} $oh_my_posh_url -s
        chmod +x ~/.local/bin/oh-my-posh${oh_my_posh_extension}
    }

    oh_my_posh_arch=$(uname -m)
    if [ "$oh_my_posh_arch" = "x86_64" ]
    then
        oh_my_posh_arch=amd64
    fi

    oh_my_posh_os=$(uname -s | tr [:upper:] [:lower:])
    oh_my_posh_extension=""
    if [[ $oh_my_posh_os = mingw* ]]
    then
        oh_my_posh_os=windows
        oh_my_posh_extension=".exe"
    fi

    oh_my_posh_url=https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v$oh_my_posh_version/posh-$oh_my_posh_os-$oh_my_posh_arch${oh_my_posh_extension}

    if command -v oh-my-posh &> /dev/null
    then
        current_version="$(oh-my-posh version)"
        if [ "$oh_my_posh_version" != "$current_version" ]
        then
            echo "Updating oh-my-posh from version $current_version to $oh_my_posh_version..."
            download
        fi
    else
        echo "Installing oh-my-posh..."
        download
    fi
}

__install_oh_my_posh
