use ~/.config/nushell/nu_scripts/themes/themes/dracula.nu

let-env config = ({
  show_banner: false
  edit_mode: vi
  cursor_shape: {
    vi_insert: block
    vi_normal: line
  }
} | merge { color_config: (dracula) })

source ~/.config/nushell/oh-my-posh.nu
