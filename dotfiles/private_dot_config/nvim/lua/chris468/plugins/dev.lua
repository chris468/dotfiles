return {
  { 'rafcamlet/nvim-luapad' },
  {
    "williamboman/mason.nvim",
    tag = "stable",
    build = ":MasonUpdate",
    config = function (_) require("mason").setup() end,
    cmd = {
      "Mason",
      "MasonUpdate",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
    },
  },
}
