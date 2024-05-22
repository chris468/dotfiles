local function build()
  if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
    return
  end
  return "make install_jsregexp"
end

return {
  "hrsh7th/nvim-cmp",
  config = function(_, _)
    local cmp = require("cmp")
    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
      }),
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<S-CR>"] = cmp.mapping.confirm({
          select = true,
          behavior = cmp.ConfirmBehavior.Replace,
        }),
      }),
    })

    cmp.setup.filetype(
      "gitcommit",
      cmp.config.sources({
        { name = "git" },
      }, {
        { name = "buffer" },
      })
    )

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      source = cmp.config.sources({
        { name = "path " },
      }, {
        { name = "cmdline" },
      }),
      matching = { disallow_symbol_nonprefix_matching = false },
    })

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
  end,
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      build = build(),
      dependencies = {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "saadparwaiz1/cmp_luasnip" },
    { "petertriho/cmp-git", config = true },
    {
      "nvim-lspconfig",
      optional = true,
      opts = function(_, opts)
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        opts.capabilities = vim.tbl_deep_extend("force", opts.capabilities or {}, capabilities)
      end,
    },
  },
  event = "InsertEnter",
  opts = {},
}
