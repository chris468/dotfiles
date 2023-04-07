local if_ext = require 'chris468.util.if-ext'

if_ext({'cmp', 'cmp_nvim_lsp', 'luasnip'}, function(cmp, _, luasnip)

  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local function navigate(direction, include_snippets, start)
    start = start ~= nil and start or true
    local callbacks = {
      next = {
        completion = cmp.select_next_item,
        snippet_available = luasnip.expand_or_jumpable,
        snippet = luasnip.expand_or_jump,
      },
      prev = {
        completion = cmp.select_prev_item,
        snippet_available = function() return luasnip.jumpable(-1) end,
        snippet = function() luasnip.jump(-1) end,
      },
    }
    return function(fallback)
      if cmp.visible() then
        callbacks[direction].completion()
      elseif include_snippets and callbacks[direction].snippet_available() then
        callbacks[direction].snippet()
      elseif start and has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end
  end

  local function start_or_select_and_complete()
    if cmp.visible() then
      cmp.confirm({select = true })
    else
      cmp.complete()
    end
  end

  local function abort()
    if cmp.visible() then
      cmp.abort()
    end
  end

  local function safe_confirm(fallback)
    if cmp.visible() and cmp.get_active_entry() then
      cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
    else
      fallback()
    end
  end

      -- keys = { '<Tab>', '<C-N>', '<C-J>', },
      --keys = { '<S-Tab>', '<C-P>', '<C-K>', },

  local options = {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end
    },
    sources = {
      { name = 'luasnip' },
      { name = 'nvim_lsp' },
      { name = 'buffer' },
    },
    mapping = {
      ['<C-Space>'] = start_or_select_and_complete,
      ['<C-N>'] = cmp.mapping(navigate('next', true), { 'i', 's', }),
      ['<Down>'] = cmp.mapping(navigate('next', false, false), { 'i', 's' }),
      ['<C-P>'] = cmp.mapping(navigate('prev', true), { 'i', 's', }),
      ['<Up>'] = cmp.mapping(navigate('prev', false, false), { 'i', 's' }),
      ['<C-E>'] = abort,
      ['<CR>' ] = cmp.mapping({
        i = safe_confirm,
        s = cmp.mapping.confirm({ select = true }),
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      }),
    },
  }

  local alternates = {
    ['<C-N>'] = { '<Tab>', '<C-J>', },
    ['<C-P>'] = { '<S-Tab>', '<C-K>'  },
  }

  for k, alts in pairs(alternates) do
    for _, alt in ipairs(alts) do
      options.mapping[alt] = options.mapping[k]
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

