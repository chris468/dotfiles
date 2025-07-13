local M = {}

local decipher = setmetatable({}, {
  __index = function(_, k)
    return require("decipher")[k]
  end,
})

---@class chris468.decipher.codec
---@field display_name string
---@field key string

---@type table<string, chris468.decipher.codec>
local codecs = {
  base64 = {
    display_name = "Base64",
    key = "b",
  },

  url = {
    display_name = "Url",
    key = "u",
  },
}

local modes = {
  n = "motion",
  v = "selection",
}

---@enum chris468.decipher.Op
local ops = {
  encode = "encode",
  decode = "decode",
}

---@param key string
---@param op chris468.decipher.Op
---@param preview boolean
local function lhs(key, op, preview)
  return "<leader>D" .. key .. (preview and "p" or "") .. ops[op]:sub(1, 1)
end

---@param codec string
---@param op chris468.decipher.Op
---@param preview boolean
local function rhs(codec, op, method, preview)
  return function()
    decipher[("%s_%s"):format(op, method)](codec, { preview = preview })
  end
end

---@param codec string
---@param config chris468.decipher.codec
---@param mode string
---@param method string
---@param op chris468.decipher.Op
---@param preview boolean
local function mapping(codec, config, mode, method, op, preview)
  return {
    lhs(config.key, op, preview),
    rhs(codec, op, method, preview),
    desc = op,
    mode = { mode },
  }
end

function M.mappings()
  local m = {}
  for codec, config in pairs(codecs) do
    for mode, method in pairs(modes) do
      for op, _ in pairs(ops) do
        table.insert(m, mapping(codec, config, mode, method, op, false))
        table.insert(m, mapping(codec, config, mode, method, op, true))
      end
    end
  end
  return m
end

function M.whichkey_specs()
  local s = {
    { "<leader>D", group = "Encodings", mode = { "n", "v" } },
  }
  for _, config in pairs(codecs) do
    table.insert(s, { "<leader>D" .. config.key, group = config.display_name, mode = { "n", "v" } })
    table.insert(s, { "<leader>D" .. config.key .. "p", group = "Preview", mode = { "n", "v" } })
  end

  return s
end

return M
