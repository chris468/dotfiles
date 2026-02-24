---@module "lazy"
---@type LazySpec[]
return {
  {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    version = "*",
    cmd = { "Obsidian" },
    keys = {
      { "<leader>Nn", "<cmd>Obsidian new<CR>", desc = "Obsidian New" },
      { "<leader>Nf", "<cmd>Obsidian quick_switch<CR>", desc = "Obsidian Quick Switch" },
      { "<leader>Ns", "<cmd>Obsidian search<CR>", desc = "Obsidian Search" },
      { "<leader>Nt", "<cmd>Obsidian today<CR>", desc = "Obsidian Today" },
      { "<leader>Ny", "<cmd>Obsidian yesterday<CR>", desc = "Obsidian Yesterday" },
      { "<leader>Nm", "<cmd>Obsidian tomorrow<CR>", desc = "Obsidian Tomorrow" },
      { "<leader>Nw", "<cmd>Obsidian workspace<CR>", desc = "Obsidian Workspace" },
    },
    dependencies = {
      "blink.cmp",
      "nvim-treesitter",
      "plenary.nvim",
      "render-markdown.nvim",
    },
    --@module "obsidian"
    --@type obsidian.config.ClientOpts
    opts = {
      legacy_commands = false,
      note_id_func = function(title, path)
        local obsidian = require("util.obsidian")
        return obsidian.resolve_note_id(title, path)
      end,
      callbacks = {
        enter_note = function(_)
          local bufnr = vim.api.nvim_get_current_buf()

          vim.keymap.set("n", "<C-]>", "<cmd>Obsidian follow_link<CR>", {
            buffer = bufnr,
            desc = "Obsidian Follow Link",
          })
          vim.keymap.set("n", "<leader>Nr", "<cmd>Obsidian rename<CR>", {
            buffer = bufnr,
            desc = "Obsidian Rename",
          })
          vim.keymap.set({ "n", "v" }, "<leader>Nx", "<cmd>Obsidian extract_note<CR>", {
            buffer = bufnr,
            desc = "Obsidian Extract Note",
          })
          vim.keymap.set({ "n", "v" }, "<leader>Nc", "<cmd>Obsidian toggle_checkbox<CR>", {
            buffer = bufnr,
            desc = "Obsidian Toggle Checkbox",
          })
          vim.keymap.set("n", "<leader>Np", "<cmd>Obsidian paste_img<CR>", {
            buffer = bufnr,
            desc = "Obsidian Paste Image",
          })
          vim.keymap.set("n", "<leader>Nb", "<cmd>Obsidian backlinks<CR>", {
            buffer = bufnr,
            desc = "Obsidian Backlinks",
          })
          vim.keymap.set("n", "<leader>Nl", "<cmd>Obsidian links<CR>", {
            buffer = bufnr,
            desc = "Obsidian Links",
          })
          vim.keymap.set("n", "<leader>Nh", "<cmd>Obsidian toc<CR>", {
            buffer = bufnr,
            desc = "Obsidian TOC",
          })
          vim.keymap.set("n", "<leader>No", "<cmd>Obsidian open<CR>", {
            buffer = bufnr,
            desc = "Obsidian Open",
          })
        end,
      },
      workspaces = {
        {
          name = "current",
          path = function()
            local obsidian = require("util.obsidian")

            return obsidian.find_obsidian_vault(vim.api.nvim_buf_get_name(0)) or vim.fn.getcwd()
          end,
        },
      },
      picker = {
        name = "snacks",
      },
      ui = {
        enable = false,
      },
    },
  },
}
