local curl = require("plenary.curl")
local Path = require("plenary.path")
local utf8 = require("utf8")

local strutil = require("chris468-utils.string")

---@alias chris468.utils.unicode.Kind "unicode"|"nerdfonts"
---@alias chris468.utils.unicode.Item { icon: string, name: string, category?: string, code?: string }
---@alias chris468.utils.unicode.AddCallback fun(item: chris468.utils.unicode.Item[])
---@alias chris468.utils.unicode.StreamCallback fun(line: string, add: chris468.utils.unicode.AddCallback)
---@alias chris468.utils.unicode.CompleteCallback fun(body: string, add: chris468.utils.unicode.AddCallback, done: fun(success: boolean))
---t
---@alias chris468.utils.unicode.Status { success?: boolean, items?: chris468.utils.unicode.Item[] }

local M = {}

---@type { [chris468.utils.unicode.Kind]: chris468.utils.unicode.Item[]? }
local cached = {}

local function schedule_notify(message, level, opts)
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

local notify = vim.notify

---@param name string
---@return table
local function datafile(name)
  local datadir = Path:new(vim.fn.stdpath("cache"), "chris468")
  return Path:new(datadir, name .. ".json")
end

---@param name string
---@items chris468.utils.unicode.Item[]
---@return boolean
local function write_data(name, items)
  local path = datafile(name)
  local ok, err = pcall(Path.mkdir, path:parent(), { parents = true })

  local f
  if ok then
    ---@diagnostic disable-next-line: cast-local-type
    f, err = vim.uv.fs_open(path.filename, "w", tonumber("644", 8))
  end
  if f then
    ---@diagnostic disable-next-line: cast-local-type
    _, err = vim.uv.fs_write(f, vim.json.encode({ version = 2, icons = items }))
    vim.uv.fs_close(f)
  end

  if err then
    notify(("Failed to write %s: %s"):format(name, err), vim.log.levels.WARN)
    return false
  end

  return true
end

---@param name string
---@param url string
---@param opts {
---  stream?: chris468.utils.unicode.StreamCallback,
---  complete?: chris468.utils.unicode.CompleteCallback,
---}
---@return chris468.utils.unicode.Status
local function download(name, url, opts)
  if not (opts and (opts.stream or opts.complete)) then
    error("either stream or callback is required")
    return { success = false }
  end
  ---
  ---@type chris468.utils.unicode.Item[]
  local items = {}

  ---@param item chris468.utils.unicode.Item[]
  local function add(item)
    vim.list_extend(items, item)
  end

  ---@type chris468.utils.unicode.Status
  local status = {
    success = nil,
    items = nil,
  }

  local curl_opts = {
    timeout = 30000,
    raw = "--fail",
    callback = function(response)
      if response.exit ~= 0 then
        return
      end

      local function done(success)
        if success and write_data(name, items) then
          status.success, status.items = true, items
          schedule_notify("Finished downloading " .. name)
        else
          status.success = false
        end
      end

      if opts.complete then
        opts.complete(response.body, add, done)
      else
        done(true)
      end
    end,
    on_error = function(result)
      schedule_notify(("Downloading %s failed: %s"):format(name, result.message), vim.log.levels.ERROR)
      status.success = false
    end,
  }

  if opts.stream then
    curl_opts.stream = function(err, line)
      if err or not line then
        return
      end
      opts.stream(line, add)
    end
  end

  notify("Downloading " .. name)
  curl.get(url, curl_opts)
  return status
end

---@return chris468.utils.unicode.Status
local function download_nerdfonts()
  local nerdfont_info_url = "https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/glyphnames.json"
  return download("nerdfonts", nerdfont_info_url, {
    complete = function(body, add, done)
      vim.schedule(function()
        local ok, nerdfont_json = pcall(vim.fn.json_decode, body)
        if not ok then
          notify("Parsing nerdfont json failed: " .. nerdfont_json, vim.log.levels.ERROR)
          done(false)
        end

        for name, data in pairs(nerdfont_json) do
          if name ~= "METADATA" then
            add({
              {
                name = name,
                icon = data.char,
                code = data.code,
              },
            })
          end
        end

        done(true)
      end)
    end,
  })
end

---@return chris468.utils.unicode.Status
local function download_unicode()
  local unicode_info_url = "https://unicode.org/Public/UNIDATA/UnicodeData.txt"
  local unicode_categories = {
    Pc = "Connector Punctuation",
    Pd = "Dash Punctuation",
    Ps = "Open Punctuation",
    Pe = "Close Punctuation",
    Pi = "Initial Punctuation",
    Pf = "Final Punctuation",
    Po = "Other Punctuation",
    Sm = "Math Symbol",
    Sc = "Currency Symbol",
    Sk = "Modifier Symbol",
    So = "Other Symbol",
  }
  ---
  ---@param s string
  ---@return number, string, chris468.utils.unicode.Item[]
  local function parse(s)
    local sp = strutil.split(s, ";")
    local codepoint, names, category = tonumber(sp[1], 16), { sp[2], sp[11] ~= "" and sp[11] or nil }, sp[3]
    local result = {}
    for _, name in ipairs(names) do
      table.insert(result, {
        name = name:lower():gsub(" ", "-"),
        icon = utf8.char(codepoint),
        code = codepoint,
        category = unicode_categories[category],
      })
    end
    return codepoint, category, result
  end

  return download("unicode", unicode_info_url, {
    stream = function(chunk, add)
      local codepoint, category, items = parse(chunk)
      if codepoint > 0x7F and unicode_categories[category] then
        add(items)
      end
    end,
  })
end

---@param name chris468.utils.unicode.Kind
---@return chris468.utils.unicode.Item[]?
local function load_data(name)
  local f, err, err_name = vim.uv.fs_open(datafile(name).filename, "r", tonumber("644", 8))
  if err_name == "ENOENT" then
    return
  end

  local stat
  if f then
    stat, err = vim.uv.fs_fstat(f)
  end

  local data
  if f then
    if stat then
      data, err = vim.uv.fs_read(f, stat.size)
    end
    vim.uv.fs_close(f)
  end

  if data then
    local ok, items = pcall(vim.fn.json_decode, data)
    if ok then
      return items.version == 2 and items.icons or nil
    else
      err = "invalid json: " .. items
    end
  end

  notify("Error loading: " .. err, vim.log.levls.ERROR)
end

---@type { [chris468.utils.unicode.Kind]: fun(): chris468.utils.unicode.Status }
local download_map = {
  nerdfonts = download_nerdfonts,
  unicode = download_unicode,
}

---@param kind chris468.utils.unicode.Kind
---@return chris468.utils.unicode.Status
local function cached_load(kind)
  local items = cached[kind] or load_data(kind)
  return items and { success = true, items = items } or download_map[kind]()
end

---@param ... chris468.utils.unicode.Kind
---@return (chris468.utils.unicode.Item[])?
function M.data(...)
  local kinds = { ... }
  kinds = (not kinds or #kinds == 0) and { "nerdfonts", "unicode" } or kinds
  local results = vim
    .iter(kinds)
    :map(function(kind)
      return cached_load(kind)
    end)
    :totable()

  local function ready()
    return vim.iter(results):all(function(result)
      return result.success ~= nil
    end)
  end

  if not ready() then
    vim.wait(35000, function()
      vim.cmd.redraw()
      return ready()
    end)
  end

  return vim
    .iter(results)
    :filter(function(result)
      return result.success
    end)
    :map(function(result)
      return result.items or {}
    end)
    :totable()
end

return M
