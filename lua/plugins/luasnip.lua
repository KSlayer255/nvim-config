return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	config = function()
		local ls = require("luasnip")
		local s = ls.snippet
		local i = ls.insert_node
		local t = ls.text_node
		local f = ls.function_node
		local l = require("luasnip.extras").l
		local extras = require("luasnip.extras")
		local rep = extras.rep
		local fmta = require("luasnip.extras.fmt").fmta

		local DEFAULT_PRIORITY = 1000
		-- Define decorators with optional priority overrides
		local decorators = {
			-- Basic decorators (only expand in math mode)
			{ trig = "hat", cmd = "hat" },
			{ trig = "bar", cmd = "bar" },
			{ trig = "tilde", cmd = "tilde" },
			{ trig = "vec", cmd = "vec" },
			{ trig = "und", cmd = "underline" },

			-- Priority overrides for dot/ddot
			{ trig = "dot", cmd = "dot", priority = -1 },
			{ trig = "ddot", cmd = "ddot", priority = 1 },

			-- Math font commands (only in math mode)
			{ trig = "bb", cmd = "mathbb" },
			{ trig = "cal", cmd = "mathcal" },
			{ trig = "bf", cmd = "mathbf" },
			{ trig = "rm", cmd = "mathrm" },
			{ trig = "sf", cmd = "mathsf" },
			{ trig = "tt", cmd = "mathtt" },
			{ trig = "it", cmd = "mathit" },
		}

		local math_types = {
			"inline_formula",
			"displayed_equation",
			"math_environment",
		}
		-- Math mode detection via treesitter
		local function in_math_mode()
			local ok, node = pcall(vim.treesitter.get_node)
			if not ok or not node then
				return false
			end
			local current = node
			while current do
				local ty = current:type()
				for _, mt in ipairs(math_types) do
					if ty == mt then
						return true
					end
				end
				local parent = current:parent()
				if not parent then
					break
				end
				current = parent
			end
			return false
		end
		ls.config.setup({
			enable_autosnippets = true,
			update_events = "TextChanged,TextChangedI",
		})
		ls.add_snippets("tex", {
			s({ trig = "mk", wordTrig = false, snippetType = "autosnippet" }, fmta([[\(<>\)]], { i(1) })),
			s(
				{ trig = "dm", wordTrig = false, snippetType = "autosnippet" },
				fmta(
					[[
      \[
      <>
      \]
      ]],
					{ i(1) }
				)
			),
			s(
				{ trig = "@begin", wordTrig = false, snippetType = "autosnippet" },
				fmta(
					[[
          \begin{<>} 
          <> 
          \end{<>}
          ]],
					{ i(1), i(2), rep(1) }
				)
			),
			-- Add these to your ls.add_snippets("tex", { ... }) call

			-- Basic superscripts/subscripts
			s({ trig = "sr", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode }, t("^{2}")),

			s({ trig = "cb", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode }, t("^{3}")),

			s(
				{ trig = "rd", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode },
				fmta("^{<>}<>", { i(1), i(2) })
			),

			s(
				{ trig = "_", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode },
				fmta("_{<>}<>", { i(1), i(2) })
			),

			-- Subscript with text
			s(
				{ trig = "sts", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode },
				fmta("_\\text{<>}", { i(1) })
			),

			-- Square root
			s(
				{ trig = "sq", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode },
				fmta("\\sqrt{ <> }<>", { i(1), i(2) })
			),

			--Times
			s({ trig = "xx", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode }, t("\\times")),

			-- Fraction
			s(
				{ trig = "//", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode },
				fmta("\\frac{<>}{<>}<>", { i(1), i(2), i(3) })
			),

			-- e^{}
			s(
				{ trig = "ee", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode },
				fmta("e^{ <> }<>", { i(1), i(2) })
			),

			-- Inverse
			s({ trig = "invs", wordTrig = false, snippetType = "autosnippet", condition = in_math_mode }, t("^{-1}")),

			-- Auto letter subscript: x2 -> x_{2} (with lower priority)
			s({
				trig = "([A-Za-z])(%d)",
				regTrig = true,
				wordTrig = false,
				snippetType = "autosnippet",
				priority = -1, -- Lower priority so it doesn't interfere with other snippets
				condition = in_math_mode,
			}, {
				f(function(_, snip)
					local letter = snip.captures[1]
					local digit = snip.captures[2]
					return letter .. "_{" .. digit .. "}"
				end, {}),
			}),
		})
		for _, dec in ipairs(decorators) do
			-- Pattern like: "xhat" -> "\hat{x}"
			ls.add_snippets("tex", {
				s({
					trig = "([a-zA-Z])" .. dec.trig,
					regTrig = true,
					wordTrig = false,
					priority = dec.priority or DEFAULT_PRIORITY,
					snippetType = "autosnippet",
					condition = function()
						return in_math_mode()
					end,
				}, {
					f(function(_, snip)
						return "\\" .. dec.cmd .. "{" .. snip.captures[1] .. "}"
					end, {}),
				}),
			})
		end

		vim.keymap.set("i", "<C-k>", function()
			ls.expand()
		end)
	end,
}
