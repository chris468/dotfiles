return {
	{
		"hrsh7th/cmp-nvim-lsp",
		lazy = true,
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-path" },
			{ "L3MON4D3/LuaSnip" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "rafamadriz/friendly-snippets" },
		},
		opts = function()
			local cmp = require("cmp")
			return {
				editor = {
					snippet = {
						expand = function(args)
							require("luasnip").lsp_expand(args.body)
						end,
					},
					mapping = cmp.mapping.preset.insert({
						["<C-d>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "buffer" },
						{ name = "path" },
					}),
				},
				search = {
					mapping = cmp.mapping.preset.cmdline(),
					sources = {
						{ name = "buffer" },
					},
				},
				ex = {
					mapping = cmp.mapping.preset.cmdline(),
					sources = cmp.config.sources({
						{ name = "path" },
					}, {
						{ name = "cmdline" },
					}),
				},
			}
		end,
		config = function(_, opts)
			local cmp = require("cmp")
			cmp.setup(opts.editor)

			cmp.setup.cmdline("/", opts.search)

			cmp.setup.cmdline(":", opts.ex)

			vim.api.nvim_create_autocmd("CmdwinEnter", {
				group = vim.api.nvim_create_augroup("chris468_cmp", {}),
				callback = function(_)
					cmp.abort()
				end,
			})
		end,
	},
}
