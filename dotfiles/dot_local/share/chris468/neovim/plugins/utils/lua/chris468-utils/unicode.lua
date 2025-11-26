local curl = require("plenary.curl")
local path = require("plenary.path")
local utf8 = require("utf8")

local strutil = require("chris468-utils.string")

local datadir = path:new(vim.fn.stdpath("cache"), "chris468")
local datafile = path:new(datadir, "unicode.json")

local M = {}

local cached = nil

local function schedule_notify(message, level, opts)
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

local notify = vim.notify

local function write_data(data)
  local ok, err = pcall(path.mkdir, datadir, { parents = true })

  local f
  if ok then
    ---@diagnostic disable-next-line: cast-local-type
    f, err = vim.uv.fs_open(datafile.filename, "w", tonumber("644", 8))
  end
  if f then
    ---@diagnostic disable-next-line: cast-local-type
    _, err = vim.uv.fs_write(f, vim.json.encode(data))
    vim.uv.fs_close(f)
  end

  if err then
    notify("Failed to write unicode data: " .. err, vim.log.levels.WARN)
  end
end

local function download_unicode_data()
  ---@param s string
  ---@return integer codepoint, string[] names, string category
  local function parse(s)
    local sp = strutil.split(s, ";")
    return tonumber(sp[1], 16), { sp[2], sp[11] ~= "" and sp[11] or nil }, sp[3]
  end

  local items = {}
  local function append_items(codepoint, names)
    for _, name in ipairs(names) do
      local n = name:lower():gsub(" ", "-")
      items[#items + 1] = {
        name = n,
        char = utf8.char(codepoint),
        code = string.format("%x", codepoint),
      }
    end
  end

  local unicode_info_url = "https://unicode.org/Public/UNIDATA/UnicodeData.txt"
  local nerdfont_info_url = "https://github.com/ryanoasis/nerd-fonts/raw/refs/heads/master/glyphnames.json"
  local include_unicode_categories = { "Pc", "Pd", "Ps", "Pe", "Pi", "Pf", "Po", "Sm", "Sc", "Sk", "So" }
  notify("Downloading unicode data")
  local download_unicode = curl.get(unicode_info_url, {
    timeout = 30000,
    stream = function(_, chunk)
      if chunk then
        local codepoint, names, category = parse(chunk)
        if codepoint > 0x7F and vim.list_contains(include_unicode_categories, category) then
          append_items(codepoint, names)
        end
      end
    end,
    on_error = function(result)
      schedule_notify("Downloading unicode data failed: " .. result.message, vim.log.levels.ERROR)
    end,
    callback = function(response)
      if response.exit == 0 then
        write_data(items)
      end
    end,
  })
  download_unicode:start()
  download_unicode:wait(30000, 10, true)
  if download_unicode.code ~= 0 then
    return
  end
  notify("Finished downloading unicode data", vim.log.levels.INFO)

  notify("Downloading nerdfont data")
  local nerdfont_json
  local download_nerdfont = curl.get(nerdfont_info_url, {
    callback = function(result)
      if result.exit == 0 then
        nerdfont_json = result.body
      end
    end,
    on_error = function(result)
      schedule_notify("Downloading nerdfont data failed: " .. result.message, vim.log.levels.ERROR)
    end,
  })
  download_nerdfont:start()
  download_nerdfont:wait(30000, 10, true)
  if download_nerdfont.code ~= 0 then
    return
  end

  local ok, nerdfont_items = pcall(vim.fn.json_decode, nerdfont_json)
  if not ok then
    notify("Parsing nerdfont json failed: " .. nerdfont_items, vim.log.levels.ERROR)
    return
  end
  notify("Finished downloading nerdfont data")

  for name, data in pairs(nerdfont_items) do
    if name ~= "METADATA" then
      items[#items + 1] = {
        name = name,
        char = data.char,
        code = data.char,
      }
    end
  end
  write_data(items)

  return items
end

local function load_data()
  local f, err, err_name = vim.uv.fs_open(datafile.filename, "r", tonumber("644", 8))
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
      return items
    else
      err = "invalid json: " .. items
    end
  end

  notify("Error loading: " .. err, vim.log.levls.ERROR)
end

local function load_or_generate_unicode_data()
  ---@diagnostic disable-next-line undefined-field
  local items = load_data()
  if items then
    return items
  end

  ---@diagnostic disable-next-line undefined-field
  return download_unicode_data()
end

function M.data()
  if not cached then
    cached = load_or_generate_unicode_data()
  end
  return cached
end

return M
