return function(_, package)
  if package.loaded == false then return end

  local autopairs = require 'nvim-autopairs'

  autopairs.setup {}

  local cmp_present, cmp  = pcall(require, 'cmp')
  if cmp_present then
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
  end
end
