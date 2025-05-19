local M = { format = {} }

local icons = {
  COMMAND = Chris468.ui.icons.command,
  CONFIRM = Chris468.ui.icons.confirm,
  EX = Chris468.ui.icons.command,
  INSERT = Chris468.ui.icons.insert,
  MORE = Chris468.ui.icons.more,
  NORMAL = Chris468.ui.icons.normal,
  ["O-PENDING"] = Chris468.ui.icons.pending,
  REPLACE = Chris468.ui.icons.replace,
  ["S-BLOCK"] = Chris468.ui.icons.visual,
  ["S-LINE"] = Chris468.ui.icons.visual,
  SELECT = Chris468.ui.icons.visual,
  SHELL = Chris468.ui.icons.shell,
  TERMINAL = Chris468.ui.icons.terminal,
  ["V-BLOCK"] = Chris468.ui.icons.visual,
  ["V-LINE"] = Chris468.ui.icons.visual,
  ["V-REPLACE"] = Chris468.ui.icons.visual,
  VISUAL = Chris468.ui.icons.visual,
}

function M.format.mode(mode)
  return icons[mode] or mode
end

function M.format.filetype(filetype)
  local icon, hl = require("mini.icons").get("filetype", filetype)
  return "%#" .. hl .. "#" .. icon
end

function M.format.encoding(encoding)
  return encoding ~= "utf-8" and encoding or ""
end

return M
