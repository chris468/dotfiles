local icons = require("chris468.config.icons")

local function build()
  if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
    return
  end
  return "make install_jsregexp"
end

local format = {}

function format.default(entry, vim_item)
  vim_item.kind = vim_item.kind .. " (" .. entry.source.name .. ")"
  return vim_item
end

function format.nvim_lsp(_, vim_item)
  local icon = (vim_item.kind and icons.symbols[string.lower(vim_item.kind)]) or " "
  vim_item.kind = icon

  return vim_item
end

format.dap = format.nvim_lsp
format.luasnip = format.nvim_lsp

format.git = function(_, vim_item)
  vim_item.kind = nil
  return vim_item
end

format.nerdfont = format.git

function format.path(_, vim_item)
  local wda = require("nvim-web-devicons")
  local icon, hl
  if vim_item.abbr and string.sub(vim_item.abbr, -1) == "/" then
    icon, hl = "", "NeoTreeDirectoryIcon"
  else
    local filename = vim_item.word
    local extension = vim.fn.fnamemodify(filename, ":e")
    icon, hl = wda.get_icon(filename, extension, { default = true })
  end
  vim_item.kind = icon
  vim_item.kind_hl_group = hl
  return vim_item
end

function format.buffer(_, vim_item)
  vim_item.kind = icons.symbols.text
  return vim_item
end

function format.cmdline_history(_, vim_item)
  vim_item.kind = icons.history
  return vim_item
end

function format.cmdline(_, vim_item)
  vim_item.kind = icons.command
  vim_item.kind_hl_group = "NoiceCmdlineIcon"
  return vim_item
end

return {
  "hrsh7th/nvim-cmp",
  config = function(_, _)
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    local function select_prev_item()
      return cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })
    end

    local function select_next_item()
      return cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })
    end

    local function confirm(behavior)
      return cmp.mapping.confirm({ select = true, behavior = behavior })
    end

    local function safe_confirm(behavior)
      return function(fallback)
        if cmp.get_active_entry() then
          return cmp.confirm({ select = false, behavior = behavior })
        else
          fallback()
        end
      end
    end

    local function scroll_docs_down()
      return cmp.mapping.scroll_docs(4)
    end

    local function scroll_docs_up()
      return cmp.mapping.scroll_docs(-4)
    end

    local function confirm_expand_or_forward_jump()
      return function(fallback)
        if not cmp.confirm({ select = true }) then
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end
      end
    end

    local function backward_jump()
      return function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end
    end

    cmp.setup({
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          local f = format[entry.source.name] and entry.source.name or "default"
          return format[f](entry, vim_item)
        end,
      },
      mapping = {
        ["<C-P>"] = cmp.mapping(select_prev_item(), { "c", "i" }),
        ["<C-K>"] = cmp.mapping(select_prev_item(), { "c", "i" }),
        ["<C-N>"] = cmp.mapping(select_next_item(), { "c", "i" }),
        ["<C-J>"] = cmp.mapping(select_next_item(), { "c", "i" }),
        ["<CR>"] = cmp.mapping({
          i = safe_confirm(),
          s = confirm(),
          c = safe_confirm(cmp.ConfirmBehavior.Replace),
        }),
        ["<S-CR>"] = cmp.mapping({
          i = safe_confirm(cmp.ConfirmBehavior.Replace),
          s = confirm(),
          c = safe_confirm(cmp.ConfirmBehavior.Replace),
        }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "c", "i" }),
        ["<C-E>"] = cmp.mapping(cmp.mapping.abort(), { "c", "i" }),
        ["<C-B>"] = cmp.mapping(scroll_docs_up(), { "c", "i" }),
        ["<C-F>"] = cmp.mapping(scroll_docs_down(), { "c", "i" }),
        ["<Tab>"] = cmp.mapping({
          i = confirm_expand_or_forward_jump(),
          s = confirm_expand_or_forward_jump(),
          c = cmp.mapping.confirm({ select = true }),
        }),
        ["<S-Tab>"] = cmp.mapping(backward_jump(), { "i", "s" }),
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = "luasnip" },
        { name = "nvim_lsp" },
      }, {
        { name = "nerdfont" },
      }, {
        { name = "buffer" },
      }),
      window = {
        completion = {
          border = "rounded",
          winhighlight = "FloatBorder:NoiceCmdlinePopupBorder",
        },
        documentation = {
          border = "rounded",
          winhighlight = "FloatBorder:NoiceCmdlinePopupBorder",
        },
      },
    })

    cmp.setup.filetype({ "gitcommit", "octo" }, {
      formatting = {
        fields = { "abbr", "menu" },
        format = format.git,
      },
      sources = cmp.config.sources({
        { name = "git" },
      }, {
        { name = "buffer" },
      }),
    })

    cmp.setup.cmdline(":", {
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
        { name = "cmdline_history" },
      }),
      matching = { disallow_symbol_nonprefix_matching = false },
    })

    cmp.setup.cmdline({ "/", "?" }, {
      sources = {
        { name = "buffer" },
        { name = "cmdline_history", opts = { history_type = "/" } },
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
    { "dmitmel/cmp-cmdline-history" },
    { "chrisgrieser/cmp-nerdfont" },
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
  event = { "InsertEnter", "CmdLineEnter" },
  version = false,
}
