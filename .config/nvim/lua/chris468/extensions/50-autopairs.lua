local if_ext = require 'chris468.util.if-ext'
if_ext('nvim-autopairs', function(ap)
  ap.setup {}

  local function register_with_cmp(cmp)
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
  end
  if_ext('cmp', register_with_cmp, nil, false)

end)
