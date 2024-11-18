local function copy_git_link()
  local gitlinker = require("gitlinker")
  gitlinker.get_repo_url()
end
return {
  "ruifm/gitlinker.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  keys = {
    { "<leader>gy", copy_git_link, mode = { "n", "v" }, desc = "Copy git web permalink" },
  },
  opts = {
    mappings = nil,
  },
}
