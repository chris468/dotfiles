do -- defaults I don't want
  -- Esc followed by j/k were moving lines instead of navigating
  vim.keymap.del({ "n", "i", "v" }, "<A-j>")
  vim.keymap.del({ "n", "i", "v" }, "<A-k>")

  -- I never increment on purpose
  vim.keymap.set("n", "<C-a>", "<nop>")

  vim.keymap.del("n", "<leader>l") -- Lazy
end

do -- chezmoi
  vim.keymap.set("n", "<leader>za", function()
    require("util.chezmoi").apply("all")
  end, { desc = "Apply" })

  vim.keymap.set("n", "<leader>zA", function()
    require("util.chezmoi").apply("all", true)
  end, { desc = "Apply (ignore unsaved)" })

  vim.keymap.set("n", "<leader>zd", function()
    require("util.chezmoi").apply("current_dir")
  end, { desc = "Apply current source dir" })

  vim.keymap.set("n", "<leader>zD", function()
    require("util.chezmoi").apply("current_dir", true)
  end, { desc = "Apply current source dir (ignore unsaved)" })

  vim.keymap.set("n", "<leader>zf", function()
    require("util.chezmoi").apply("current_file")
  end, { desc = "Apply current source file" })

  vim.keymap.set("n", "<leader>zu", function()
    require("util.chezmoi").update(false)
  end, { desc = "Update" })

  vim.keymap.set("n", "<leader>zU", function()
    require("util.chezmoi").update(true)
  end, { desc = "Update and apply" })
end

do -- package management
  vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<CR>", { desc = "Lazy" })
  vim.keymap.set("n", "<leader>pL", function()
    LazyVim.news.changelog()
  end, { desc = "LazyVim changelog" })
  vim.keymap.set("n", "<leader>px", "<cmd>LazyExtras<CR>", { desc = "LazyVim extras" })
  vim.keymap.set("n", "<leader>pm", "<cmd>Mason<CR>", { desc = "Mason" })
end

do -- tabs
  vim.keymap.set("n", "[<Tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
  vim.keymap.set("n", "]<Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
end

do -- git
  -- overriding many LazyVim maps so they have to appear here instead of in the lazy spec
  vim.keymap.set("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Commit" })
  vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen -- %<cr>", { desc = "Diff current buffer" })
  vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
  vim.keymap.set("n", "<leader>gG", "<cmd>DiffviewOpen<cr>", { desc = "Git (diffview)" })
  vim.keymap.set("n", "<leader>gl", "<cmd>DiffviewFileHistory %<cr>", { desc = "Log (current file)" })
  vim.keymap.set("n", "<leader>gL", "<cmd>DiffviewFileHistory<cr>", { desc = "Log" })
  vim.keymap.set("n", "<leader>gp", "<cmd>Neogit pull<cr>", { desc = "Pull" })
  vim.keymap.set("n", "<leader>gP", "<cmd>Neogit push<cr>", { desc = "Push" })

  -- Move snacks git mappings that I might find useful
  vim.keymap.set("n", "<leader>gsd", function()
    Snacks.picker.git_diff()
  end, { desc = "Git Diff (hunks)" })
  vim.keymap.set("n", "<leader>gsD", function()
    Snacks.picker.git_diff({ base = "origin", group = true })
  end, { desc = "Git Diff (origin)" })
  vim.keymap.set("n", "<leader>gss", function()
    Snacks.picker.git_status()
  end, { desc = "Git Status" })
  vim.keymap.set("n", "<leader>gsS", function()
    Snacks.picker.git_stash()
  end, { desc = "Git Stash" })

  if vim.fn.executable("lazygit") == 1 then
    vim.keymap.set("n", "<leader>gsg", function()
      Snacks.lazygit({ cwd = LazyVim.root.git() })
    end, { desc = "Lazygit (Root Dir)" })
    vim.keymap.set("n", "<leader>gsG", function()
      Snacks.lazygit()
    end, { desc = "Lazygit (cwd)" })
  end

  -- Delete snacks git mappings I moved or don't want but didn't reuse
  vim.keymap.del({ "n", "x" }, "<leader>gB") -- browse/open
  vim.keymap.del("n", "<leader>gD") -- diff origin
  vim.keymap.del("n", "<leader>gi") -- github issues/open
  vim.keymap.del("n", "<leader>gI") -- github issues/all
  vim.keymap.del("n", "<leader>gS") -- stash
  vim.keymap.del({ "n", "x" }, "<leader>gY") -- browse/yank
end

do -- debugging
  if LazyVim.has("one-small-step-for-vimkind") then
    Snacks.toggle({
      name = "Lua debug server",
      wk_desc = {
        enabled = "Stop ",
        disabled = "Start ",
      },
      get = function()
        return require("osv").is_running()
      end,
      set = function(start)
        local osv = require("osv")
        if start then
          osv.launch({
            port = 8086,
          })
        else
          osv.stop()
        end
      end,
      notify = function(started, _)
        if not started then
          print("Server stopped.")
        end
      end,
    }):map("<leader>dN")
  end
end

-- group names / icons
---@module 'lazyvim'
LazyVim.on_load("which-key.nvim", function()
  require("which-key").add({
    { "<leader>gs", group = "Snacks" },
    { "<leader>l", group = "Lua" },
    { "<leader>p", group = "Packages" },
    { "<leader>z", group = "Chezmoi" },
  })
end)
