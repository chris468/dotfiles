return LazyVim.has_extra("editor.fzf")
    and {
      {
        "fzf-lua",
        opts = {
          winopts = {
            preview = {
              layout = "vertical",
            },
          },
        },
      },
    }
  or {}
