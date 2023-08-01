local cmp = require("cmp")
local luasnip = require("luasnip")

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function navigate(direction, start)
	start = start == nil or start
	local callbacks = {
		next = {
			completion = cmp.select_next_item,
			snippet_available = luasnip.expand_or_jumpable,
			snippet = luasnip.expand_or_jump,
		},
		prev = {
			completion = cmp.select_prev_item,
			snippet_available = function()
				return luasnip.jumpable(-1)
			end,
			snippet = function()
				luasnip.jump(-1)
			end,
		},
	}
	return function(fallback)
		if cmp.visible() then
			callbacks[direction].completion()
		elseif callbacks[direction].snippet_available() then
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
		cmp.confirm({ select = true })
	else
		cmp.complete()
	end
end

local function abort(fallback)
	if cmp.visible() then
		cmp.abort()
	elseif fallback then
		fallback()
	end
end

local function safe_confirm(fallback)
	if cmp.visible() and cmp.get_active_entry() then
		cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
	else
		fallback()
	end
end

local M = {}

local next_mapping = cmp.mapping({
	i = navigate("next", true),
	s = navigate("next", true),
	c = navigate("next", false),
})

local prev_mapping = cmp.mapping({
	i = navigate("prev", true),
	s = navigate("prev", true),
	c = navigate("prev", false),
})

M.core = {
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources(
		{
			{ name = "nvim_lua" },
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "path" },
			{ name = "nvim_lsp_signature_help" },
		},

		-- only use buffer if nothing else matches
		{
			{ name = "buffer" },
		}
	),
	mapping = {
		-- confirmation
		["<C-Space>"] = cmp.mapping(start_or_select_and_complete, { "i", "s", "c" }),
		["<CR>"] = cmp.mapping({
			i = safe_confirm,
			s = cmp.mapping.confirm({ select = true }),
			c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
		}),

		-- abort
		["<C-E>"] = cmp.mapping(abort, { "i", "s", "c" }),

		-- previous/next
		["<C-N>"] = next_mapping,
		["<C-J>"] = next_mapping,
		["<Tab>"] = next_mapping,
		["<C-P>"] = prev_mapping,
		["<C-K>"] = prev_mapping,
		["<S-Tab>"] = prev_mapping,

		-- arrows are not mapped to command line (they are used to navigate history instead)
		["<Down>"] = cmp.mapping(navigate("next", false), { "i", "s" }),
		["<Up>"] = cmp.mapping(navigate("prev", false), { "i", "s" }),

		-- ctrl b/f to scroll docs
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
	},
}

M.search = {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
}

M.ex = {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
}

return M
