local if_ext = require 'chris468.util.if-ext'

if_ext({'cmp', 'cmp_nvim_lsp'}, function(cmp, _)

  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  -- set invisible to false to fallback even if nothing to call if invisible
  -- if left null, the callback will be called unconditionally
  local function mapping(callback, invisible, modes)
    local always = invisible == nil
    modes = modes or { 'i', 's', 'c' }

    if always then
      return cmp.mapping(function(_) callback() end, modes)
    else
      return cmp.mapping(function(fallback)
        if cmp.visible() then
          callback()
        elseif invisible and has_words_before() then
          invisible()
        else
          fallback()
        end
      end, modes)
    end
  end


  local mappings = {
    {
      keys = { '<C-Space>', }, mapping = mapping(cmp.complete) },
    {
      keys = { '<Tab>', '<C-N>', '<C-J>', },
      mapping = mapping(cmp.select_next_item, cmp.complete)
    },
    {
      keys = { '<Down>', },
      mapping = mapping(cmp.select_next_item, cmp.complete, { 'i', 's' })
    },
    {
      keys = { '<S-Tab>', '<C-P>', '<C-K>', },
      mapping = mapping(cmp.select_prev_item, cmp.complete)
    },
    {
      keys = { '<Up>', },
      mapping = mapping(cmp.select_prev_item, cmp.complete, { 'i', 's' })
    },
    {
      keys = { '<CR>' },
      mapping = mapping(cmp.confirm, false, {'i', 's'})
    },
    {
      keys = { '<C-E>' },
      mapping = mapping(cmp.abort, false)
    },
  }

  local options = {
    snippet = {
      expand = function(args)
        require 'luasnip'.lsp_expand(args.body)
      end
    },
    sources = {
      { name = 'luasnip' },
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    },
    mapping = {},
  }

  for _, ms in ipairs(mappings) do
    for _, k in ipairs(ms.keys) do
      options.mapping[k] = ms.mapping
    end
  end

  cmp.setup(options)

  cmp.setup.cmdline({ '/', '?' }, {
    sources = {
      { name = 'buffer' },
    }
  })

  cmp.setup.cmdline(':', {
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    }
  })

end)

