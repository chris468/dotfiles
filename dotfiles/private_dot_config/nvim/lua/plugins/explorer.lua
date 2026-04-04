---@module "snacks.picker.core.actions"
---@type table<string, snacks.picker.Action.spec>
local snacks_explorer_actions = {
  open_in_oil = function(_, item)
    if not item.file then
      return
    end

    local Path = require("plenary").path
    local dir = Path:new(item.file)
    if not dir:is_dir() then
      dir = dir:parent()
    end

    require("oil").open_float(dir:absolute())
  end,
}

local snacks_explorer_keys = {
  ["<Esc>"] = false,
  ["<C-O>"] = "open_in_oil",
}

---@param opts? { hide_tracked_hidden?: boolean, hide_ignored?: boolean}
local function is_hidden_file_factory(opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    hide_tracked_hidden = false,
    hide_ignored = true,
  })

  -- helper function to parse output
  local function parse_output(proc)
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
      for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
        -- Remove trailing slash
        line = line:gsub("/$", "")
        ret[line] = true
      end
    end
    return ret
  end

  -- build git status cache
  local function new_git_status()
    return setmetatable({}, {
      __index = function(self, key)
        local ignore_proc = vim.system(
          { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
          {
            cwd = key,
            text = true,
          }
        )
        local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
          cwd = key,
          text = true,
        })
        local ret = {
          ignored = parse_output(ignore_proc),
          tracked = parse_output(tracked_proc),
        }

        rawset(self, key, ret)
        return ret
      end,
    })
  end
  local git_status = new_git_status()

  local function is_hidden_file(name, bufnr)
    local dir = require("oil").get_current_dir(bufnr)
    local is_dotfile = vim.startswith(name, ".") and name ~= ".."
    -- if no local directory (e.g. for ssh connections), just hide dotfiles
    if not dir then
      return is_dotfile
    end
    -- dotfiles are considered hidden unless tracked
    if is_dotfile then
      return opts.hide_tracked_hidden or not git_status[dir].tracked[name]
    else
      -- Check if file is gitignored
      return opts.hide_ignored and git_status[dir].ignored[name]
    end
  end

  return is_hidden_file
end

---@param bufnr integer
local function update_oil_hidden_files(bufnr)
  require("oil.view").set_is_hidden_file(is_hidden_file_factory({
    hide_tracked_hidden = vim.b[bufnr].chris468_oil_tracked_hidden,
    hide_ignored = vim.b[bufnr].chris468_oil_hide_ignored,
  }))
end

LazyVim.on_load("oil.nvim", function()
  -- Clear git status cache on refresh
  local refresh = require("oil.actions").refresh
  local orig_refresh = refresh.callback
  refresh.callback = function(...)
    git_status = new_git_status()
    orig_refresh(...)
  end
end)

---@param details? boolean
local function toggle_details_factory(details)
  local details = details or false
  function callback()
    detail = not detail
    if detail then
      require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
    else
      require("oil").set_columns({ "icon" })
    end
  end

  return callback
end

return {
  {
    -- TODO: snacks-rename integration
    "stevearc/oil.nvim",
    dependencies = { "mini.icons", "plenary.nvim" },
    cmd = "Oil",
    keys = {
      {
        "<leader>fo",
        function()
          local root = LazyVim.root({ normalize = true })
          require("oil").toggle_float(root)
        end,
        desc = "Oil explorer (root dir) ",
      },
      {
        "<leader>fO",
        function()
          local cwd = vim.fs.normalize(vim.uv.cwd() or ".")
          require("oil").toggle_float(cwd)
        end,
        desc = "Oil explorer (cwd) ",
      },
      {
        "<leader><C-O>",
        function()
          local Path = require("plenary").path
          local p = Path:new(vim.api.nvim_buf_get_name(0))
          if not p:is_dir() then
            p = p:parent()
          end

          require("oil").toggle_float(p:absolute())
        end,
        desc = "Oil explorer (current buffer's dir) ",
      },
    },
    opts = {
      float = {
        border = "rounded",
      },
      keymaps = {
        ["<C-s>"] = false,
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = false,
        ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
        q = "actions.close",
        ["g,"] = {
          function()
            local bufnr = vim.api.nvim_get_current_buf()
            vim.b[bufnr].chris468_oil_tracked_hidden = (vim.b[bufnr].chris468_oil_tracked_hidden == false)
            update_oil_hidden_files(bufnr)
          end,
          desc = "Toggle tracked hidden files and directories",
        },
        ["gi"] = {
          function()
            local bufnr = vim.api.nvim_get_current_buf()
            vim.b[bufnr].chris468_oil_hide_ignored = (vim.b[bufnr].chris468_oil_hide_ignored == false)
            update_oil_hidden_files(bufnr)
          end,
          desc = "Toggle gitignored",
        },
        ["gd"] = {
          toggle_details_factory(),
          desc = "Toggle details",
        },
      },
      view_options = {
        is_hidden_file = is_hidden_file_factory(),
      },
    },
  },
  {
    "snacks.nvim",
    dependencies = { "plenary.nvim" },
    opts = {
      picker = {
        sources = {
          explorer = {
            actions = snacks_explorer_actions,
            win = {
              input = {
                keys = snacks_explorer_keys,
              },
              list = {
                keys = snacks_explorer_keys,
              },
            },
          },
        },
      },
    },
  },
}
