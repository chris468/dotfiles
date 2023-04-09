local widths = {
  default = 100,
  python = 88,
  markdown = 80,
}

local wrap = {
  text = true,
  markdown = true,
}

local function configure_colorcolumn(_)
  local ft = vim.bo.filetype
  local width = widths[ft] or widths.default
  vim.opt.colorcolumn = tostring(width)
end

local function configure_textwidth(_)
  local ft = vim.bo.filetype
  if wrap[ft] then
    local width = widths[ft] or widths.default
    vim.bo.textwidth = width
  end
end

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local group = augroup('chris468_widths', {clear = true})
autocmd(
  {'BufRead', 'BufNewFile', 'FileType'},
  {
    group = group,
    callback = configure_textwidth
  }
)
autocmd(
  {'BufWinEnter', 'BufEnter', 'Filetype'},
  {
    group = group,
    callback = configure_colorcolumn
  }
)

