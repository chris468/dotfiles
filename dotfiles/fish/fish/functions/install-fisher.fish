function install-fisher
    mkdir -p $fisher_path

    set -a fish_function_path $fisher_path/functions
    set -a fish_complete_path $fisher_path/completions

    test -d $fisher_path/conf.d ; and for file in $fisher_path/conf.d/*.fish
        source $file
    end

    if not type -q fisher ;
        echo Downloading fisher...
        curl -sL https://git.io/fisher | source && fisher update
    end
end
