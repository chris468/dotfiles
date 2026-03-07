local function obsidian_command(cmd)
  return function()
    local async = require("plenary.async")
    local obsidian_util = require("util.obsidian")
    async.void(function()
      obsidian_util.obsidian_command(cmd)
    end)()
  end
end

---@module "lazy"
---@type LazySpec[]
return {
  {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    version = "*",
    cmd = { "Obsidian" },
    keys = {
      { "<leader>Nn", obsidian_command("Obsidian new"), desc = "Obsidian New" },
      { "<leader>Nf", obsidian_command("Obsidian quick_switch"), desc = "Obsidian Quick Switch" },
      { "<leader>Ns", obsidian_command("Obsidian search"), desc = "Obsidian Search" },
      { "<leader>Ng", obsidian_command("Obsidian tags"), desc = "Obsidian Tags" },
      { "<leader>Nt", obsidian_command("Obsidian today"), desc = "Obsidian Today" },
      { "<leader>Ny", obsidian_command("Obsidian yesterday"), desc = "Obsidian Yesterday" },
      { "<leader>Nm", obsidian_command("Obsidian tomorrow"), desc = "Obsidian Tomorrow" },
      { "<leader>Nw", obsidian_command("Obsidian workspace"), desc = "Obsidian Workspace" },
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
        post_set_workspace = function(workspace)
          local util_obsidian = require("util.obsidian")
          util_obsidian.on_workspace_set(workspace)
        end,
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
          -- name = "current",
          path = function()
            local obsidian = require("util.obsidian")

            return obsidian.find_obsidian_vault(vim.api.nvim_buf_get_name(0)) or nil
          end,
        },
        {
          name = "fallback",
          path = function()
            local p = vim.fn.stdpath("state") .. "/fallback-notes"
            vim.fn.mkdir(p, "p")
            return p
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
    config = function(_, opts)
      require("obsidian").setup(opts)

      if opts.picker and opts.picker.name == "snacks" and Obsidian and Obsidian.picker then
        local picker = Obsidian.picker
        if not picker._chris468_string_user_data_fix then
          local original_pick = picker.pick
          picker.pick = function(values, pick_opts)
            if type(values) == "table" and #values > 0 and type(values[1]) == "string" then
              values = vim.tbl_map(function(v)
                return { text = v, user_data = v }
              end, values)
            end
            return original_pick(values, pick_opts)
          end
          picker._chris468_string_user_data_fix = true
        end
      end
    end,
  },
}
