local M = {}

---@param path string
---@return string|false
function M.find_obsidian_vault(path)
  local start_path = path
  if vim.fn.isdirectory(start_path) == 0 then
    start_path = vim.fs.dirname(start_path) or start_path
  end

  local obsidian_parents = vim.fs.find(".obsidian", { upward = true, path = start_path })
  if obsidian_parents and obsidian_parents[1] then
    return vim.fs.dirname(obsidian_parents[1]) or false
  end
  return false
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

return M
