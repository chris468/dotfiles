local nvim_treesitter = require("nvim-treesitter")

local debounce = require("util.debounce")

local status = {}

--- @param filetype? string
--- @return string? lang
local function available_parser(filetype)
  if not filetype then
    return
  end
  local lang = vim.treesitter.language.get_lang(filetype)
  if lang and vim.tbl_contains(nvim_treesitter.get_available(), lang) then
    return lang
  end
end

--- @param langs string[]
--- @param on_installed? fun(bufnr: number, already: boolean)
local function ensure_parser_installed(langs, on_installed)
  on_installed = on_installed or function() end
  nvim_treesitter.install(langs):await(function()
    for _, lang in ipairs(langs) do
      status[lang].complete = true
      for _, buf in ipairs(status[lang].buffers) do
        on_installed(buf, false)
      end
    end
  end)
end

local parsers = {}

---@param bufnr number
---@param langs string|string[]
--- @param on_installed? fun(bufnr: number, already: boolean)
local function ensure_parsers_installed(bufnr, langs, on_installed)
  on_installed = on_installed or function() end
  langs = type(langs) == "table" and langs or { langs }
  local ensure = {}
  for _, lang in ipairs(langs) do
    if status[lang] then
      if status[lang].complete then
        on_installed(bufnr, true)
      else
        table.insert(status[lang].buffers, bufnr)
      end
    else
      status[lang] = { complete = false, buffers = { bufnr } }
      table.insert(ensure, lang)
    end

    ensure_parser_installed(ensure, on_installed)
  end
end

local function attach_injected(bufnr)
  vim.treesitter.stop(bufnr)
  vim.treesitter.start(bufnr)
end

local function find_and_ensure_injected_parsers(bufnr, tree, query)
  local injected_languages = {}

  if not tree then
    return
  end
  for id, node, _ in query:iter_captures(tree:root(), bufnr, 0, -1) do
    local name = query.captures[id]
    if name == "injection.language" or name == "language" then
      local language = vim.treesitter.get_node_text(node, bufnr):lower():match("^[a-zA-Z0-9]+")
      if language then
        table.insert(injected_languages, language)
      end
    end
  end
  ensure_parsers_installed(bufnr, injected_languages, attach_injected)
end

---@param parser TSParser
---@param bufnr number
---@param immediate bool?
---@return nil|fun(_, tree: TSTree)
local function ensure_injected_parsers(parser, bufnr, immediate)
  local query = vim.treesitter.query.get(parser:lang(), "injections")
  if not query then
    return nil
  end

  return immediate and function(_, tree)
    find_and_ensure_injected_parsers(bufnr, tree, query)
  end or function(_, tree)
    debounce(2000, false, find_and_ensure_injected_parsers, bufnr, tree, query)
  end
end

---@param bufnr number
local function attach(bufnr)
  local parser = vim.treesitter.get_parser(bufnr)
  if not parser or parsers[bufnr] == parser then
    return
  end

  parsers[bufnr] = parser
  parser:register_cbs({
    on_changedtree = ensure_injected_parsers(parser, bufnr),
    on_detach = function(bn)
      if parsers[bn] == parser then
        parsers[bn] = nil
      end
    end,
  }, true)

  ensure_injected_parsers(parser, bufnr, 0)(nil, parser:parse()[1])
end

local group = vim.api.nvim_create_augroup("chris468.autocmds.treesitter", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  callback = function(a)
    local filetype = a.match
    local bufnr = a.buf

    local lang = available_parser(filetype)
    if not lang then
      return
    end
    ensure_parsers_installed(bufnr, lang, function(b)
      debounce(2000, true, attach, b)
    end)
  end,
  group = group,
})
