-- ~/.config/nvim/snippets/tex.lua

-- Load necessary modules
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta

-- VimTeX helper functions
local tex_utils = {}
tex_utils.in_mathzone = function()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex_utils.in_text = function()
	return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function()
	return vim.fn["vimtex#syntax#in_comment"]() == 1
end
tex_utils.in_env = function(name)
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
end

-- Define snippets (MUST be in this format for the Lua loader)
return {
	s(
		{
			trig = "@begin",
			name = "begin-end",
			dscr = "Insert a \\begin{} and \\end{} environment",
			wordTrig = false,
			priority = 1100,
			snippetType = "autosnippet",
			condition = tex_utils.in_text,
		},
		fmta(
			[[
            \begin{<>}
                <>
            \end{<>}
            ]],
			{ i(1), i(2), rep(1) }
		)
	),
	-- Add more snippets here if you want
}
