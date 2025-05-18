local strutil = require("chris468.util.string")
local async = require("blink.cmp.lib.async")
local path = require("plenary.path")
local notify = require("chris468.util").schedule_notify

local datadir = path:new(vim.fn.stdpath("cache"), "chris468")
local datafile = path:new(datadir, "unicode.json")

local M = {}

local cached = nil

---@return blink.cmp.Task<lsp.CompletionItem[]>
local function download_unicode_data()
  return async.task.new(function(resolve, reject)
    local curl = require("plenary.curl")
    local utf8 = require("utf8")

    ---@param s string
    ---@return integer codepoint, string[] names, string category
    local function parse(s)
      local sp = strutil.split(s, ";")
      return tonumber(sp[1], 16), { sp[2], sp[11] ~= "" and sp[11] or nil }, sp[3]
    end

    local kind = require("blink.cmp.types").CompletionItemKind.Text
    local completions = {}
    local function append_completions(codepoint, names)
      for _, name in ipairs(names) do
        local n = ":u-" .. name:lower():gsub(" ", "-")
        local c = utf8.char(codepoint)
        completions[#completions + 1] = {
          label = c .. " " .. n,
          kind = kind,
          insertText = c,
          textEdit = {
            newText = n,
          },
        }
      end
    end

    local unicode_info_url = "https://unicode.org/Public/UNIDATA/UnicodeData.txt"
    local include_categories = { "Pc", "Pd", "Ps", "Pe", "Pi", "Pf", "Po", "Sm", "Sc", "Sk", "So" }
    curl
      .get(unicode_info_url, {
        stream = function(_, chunk)
          if chunk then
            local codepoint, names, category = parse(chunk)
            if codepoint > 0x7F and vim.list_contains(include_categories, category) then
              append_completions(codepoint, names)
            end
          end
        end,
        on_error = function(result)
          reject("Download failed: " .. result.message)
        end,
        callback = function(response)
          if response.exit == 0 then
            resolve(completions)
          end
        end,
      })
      :start()
  end)
end

local function write_data(data)
  return async
    .task
    .new(function(resolve, reject)
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
        reject("Error writing data: " .. err)
      else
        resolve(data)
      end
    end)
    ---@diagnostic disable-next-line undefined-field
    :catch(function(err)
      notify("Failed to write unicode completion data: " .. err, vim.log.levels.WARN)
    end)
end

local function load_data()
  return async.task.new(function(resolve, reject)
    local f, err, err_name = vim.uv.fs_open(datafile.filename, "r", tonumber("644", 8))
    if err_name == "ENOENT" then
      resolve(nil)
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
        resolve(items)
      else
        err = "invalid json: " .. items
      end
    end

    if err then
      reject("Error loading: " .. err)
    end
  end)
end

local function load_or_generate_unicode_data()
  ---@diagnostic disable-next-line undefined-field
  return async.task.empty():map(load_data):map(function(items)
    if items then
      return items
    end

    ---@diagnostic disable-next-line undefined-field
    return download_unicode_data():on_completion(write_data)
  end)
end

function M.generate_unicode_completions()
  if cached then
    ---@diagnostic disable-next-line undefined-field
    return async.task.empty():map(function()
      return cached
    end)
  else
    ---@diagnostic disable-next-line undefined-field
    return async.task.empty():map(load_or_generate_unicode_data):on_completion(function(items)
      cached = items
    end)
  end
end

return M
