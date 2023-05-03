# The default config record. This is where much of your global configuration is setup.
let-env config = {
  # true or false to enable or disable the welcome banner at startup
  show_banner: false
  edit_mode: vi
  cursor_shape: {
    vi_insert: block
    vi_normal: line
  }
}

source ~/.config/nushell/oh-my-posh.nu
