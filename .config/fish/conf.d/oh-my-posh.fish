type -q oh-my-posh ; or exit

set -l oh_my_posh_path (realpath $__fish_config_dir)/../oh-my-posh/
set posh_theme $oh_my_posh_path/(cat $oh_my_posh_path/current-theme)

oh-my-posh init fish --config $posh_theme | source
