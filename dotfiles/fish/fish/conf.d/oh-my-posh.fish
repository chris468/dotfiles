type -q oh-my-posh ; or exit

set posh_theme (realpath $__fish_config_dir)/../../oh-my-posh/current-theme.omp.json

oh-my-posh --init --shell fish --config $posh_theme | source
