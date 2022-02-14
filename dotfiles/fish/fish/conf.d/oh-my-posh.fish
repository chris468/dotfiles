type -q oh-my-posh ; or exit

set -l posh_theme_path ~/.config/poshthemes
set posh_theme $posh_theme_path/powerlevel10k_rainbow.omp.json

oh-my-posh --init --shell fish --config $posh_theme | source
