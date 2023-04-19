yadm_version="3.2.1"

function __install_yadm {
    yadm_url=https://raw.githubusercontent.com/TheLocehiliosan/yadm/$yadm_version/yadm

    function download {
        curl -Ls -o ~/.local/bin/yadm $yadm_url
        chmod +x ~/.local/bin/yadm
    }

    if command -v yadm &> /dev/null
    then
        current_version="$(yadm version | grep "yadm" | awk '{print $NF}')"
        if [ "$yadm_version" != "$current_version" ]
        then
            echo "Updating yadm from version ${current_version:-unknown} to $yadm_version..."
            download
        fi
    else
        echo "Installing yadm..."
        download
    fi
}

__install_yadm
