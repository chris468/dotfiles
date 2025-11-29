local get_mode = require("lualine.components.mode")

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

return function()
  local mode = get_mode()
  return icons[mode] or mode
end
