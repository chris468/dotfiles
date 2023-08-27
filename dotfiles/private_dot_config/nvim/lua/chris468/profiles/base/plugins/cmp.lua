return {
  {
    "L3MON4D3/LuaSnip",
    keys = function(_, keys)
      local updated = {}
      for _, k in ipairs(keys) do
        if string.lower(k[1]) ~= "<tab>" then
          updated[#updated + 1] = k
        end
      end

      return updated
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "L3MON4D3/LuaSnip",
    },
    event = "CmdlineEnter",
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local mapping = opts.mapping
      opts.mapping = vim.tbl_extend("force", mapping, {
        ["<C-k>"] = cmp.mapping(mapping["<C-P>"], { "i", "c" }),
        ["<C-j>"] = cmp.mapping(mapping["<C-N>"], { "i", "c" }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm()
          -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
