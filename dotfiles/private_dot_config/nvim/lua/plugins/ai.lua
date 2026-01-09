return {
  {
    "codeium.nvim",
    optional = true,
    opts = {
      virtual_text = {
        key_bindings = {
          clear = "<C-E>",
        },
      },
    },
  },
  {
    "copilot.lua",
    optional = true,
    opts = {
      suggestion = {
        keymap = {
          dismiss = "<C-E>",
        },
      },
      filetypes = {
        yaml = true,
      },
    },
  },
}
