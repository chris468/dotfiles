return LazyVim.has_extra("editor.fzf")
    and {
      {
        "fzf-lua",
        opts = {
          "hide",
          winopts = {
            preview = {
              layout = "vertical",
            },
          },
        },
      },
    }
  or {}
