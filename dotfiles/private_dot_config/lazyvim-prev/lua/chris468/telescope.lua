local M = {
  opts = {},
}

---@type string[]?
local ignore_docs_patterns

---comment
---@param rtp string
---@return boolean, string
local function docpath(rtp)
  local Path = require("plenary.path")
  local doc = Path:new(rtp) / "doc"

  return doc:is_dir(), doc.filename .. Path.path.sep
end

local function get_helpdirs()
  ---@type table<string, true>
  local helpdirs = {}
  for _, rtp in
    ipairs(vim.opt.rtp:get() --[[@as string[] ]])
  do
    local exists, dp = docpath(rtp)
    helpdirs[dp] = exists or nil
  end

  for _, p in ipairs(require("lazy").plugins()) do
    local exists, dp = docpath(p.dir)
    helpdirs[dp] = exists or nil
  end

  return vim.tbl_keys(helpdirs)
end

local function get_ignore_patterns()
  if not ignore_docs_patterns then
    ignore_docs_patterns = vim.list_extend({ ".git/" }, get_helpdirs())
  end
end

---param opts? table<string, any>
function M.opts.ignore_helpdirs(opts)
  return vim.tbl_extend("error", opts or {}, {
    file_ignore_patterns = get_ignore_patterns(),
  })
end

return M
