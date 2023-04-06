local if_ext = require 'chris468.util.if-ext'

if_ext({'cmp', 'cmp_nvim_lsp'}, function(cmp, _)

  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local mappings = {
    {
      keys = { '<Tab>', '<C-N>', '<C-J>', },
      mapping = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
        end
      end, { "i", "s" }),
    },
    {
      keys = { '<S-Tab>', '<C-P>', '<C-K>' },
      mapping = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" }),
    },
    {
      keys = { '<CR>' },
      mapping = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm()
        else
          fallback()
        end
      end)
    },
    {
      keys = { '<C-E>' },
      mapping = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.abort()
        else
          fallback()
        end
      end),
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
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    }
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'path' },
      { name = 'cmdline' },
    }
  })

end)

