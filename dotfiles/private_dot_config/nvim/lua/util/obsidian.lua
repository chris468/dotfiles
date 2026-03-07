local M = {}

local vault_path_selector_opts = {
  history_key = "obsidian",
  select_prompt = "Select Obsidian Vault",
  input_prompt = "Obsidian Vault",
  new_item_label = "New Vault",
  enable_path_picker = true,
  allow_custom_path = true,
}

---@param path string
---@return string|false
function M.find_obsidian_vault(path)
  local path_selector = require("util.ui.path_selector")
  local start_path = path
  if vim.fn.isdirectory(start_path) == 0 then
    start_path = vim.fs.dirname(start_path) or start_path
  end

  local obsidian_parents = vim.fs.find(".obsidian", { upward = true, path = start_path })
  if not obsidian_parents or not obsidian_parents[1] then
    return false
  end
  local vault = vim.fs.dirname(obsidian_parents[1])
  if not vault then
    return false
  end
  path_selector.record_history(vault, vault_path_selector_opts)
end

---@param title string|?
---@return string
function M.slugify_note_title(title)
  local slug = title and vim.trim(title):lower() or ""
  if slug == "" then
    return "untitled"
  end

  slug = slug:gsub("[%s_]+", "-")
  slug = slug:gsub('[/\\:<>"|%?%*%.]+', "-")
  slug = slug:gsub("[^%w%-]", "-")
  slug = slug:gsub("%-+", "-")
  slug = slug:gsub("^%-+", "")
  slug = slug:gsub("%-+$", "")

  return slug ~= "" and slug or "untitled"
end

---@param title string|?
---@param dir string|table|?
---@return string
function M.resolve_note_id(title, dir)
  local base = M.slugify_note_title(title)
  if not dir then
    return base
  end

  local dir_path = tostring(dir)
  local candidate = base
  local suffix = 2

  while vim.uv.fs_stat(vim.fs.joinpath(dir_path, candidate .. ".md")) do
    candidate = string.format("%s-%d", base, suffix)
    suffix = suffix + 1
  end

  return candidate
end

---@param cmd string?
function M.obsidian_command(cmd)
  local obsidian = require("obsidian")
  if not Obsidian.workspace or Obsidian.workspace.name == "fallback" then
    local path_selector = require("util.ui.path_selector")
    local path = path_selector.select_path(vault_path_selector_opts)

    local ws = path and obsidian.Workspace.new({
      path = path,
      name = vim.fs.basename(path),
    })
    if not ws then
      return
    end
    obsidian.Workspace.set(ws)
  end

  if cmd then
    vim.cmd(cmd)
  end
end

return M
