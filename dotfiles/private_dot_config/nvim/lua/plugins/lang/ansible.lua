return {
  { -- Ansible lint and other tools are in the venv
    "venv-selector.nvim",
    ft = { "yaml.ansible" },
    keys = function(_, keys)
      for _, key in ipairs(keys) do
        if key.ft then
          key.ft = type(key.ft) == "table" and key.ft or { key.ft }
          table.insert(key.ft, "yaml.ansible")
        end
      end
    end,
    opts = {
      settings = {
        options = {
          require_lsp_activation = false,
        },
      },
    },
  },
}
