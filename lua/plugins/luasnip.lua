return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = vim.fn.has("win32") == 1 and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build" or "make install_jsregexp",
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
		}

		local greek_symbols = {
			{ trig = "alpha", cmd = "alpha" },
			{ trig = "beta", cmd = "beta" },
			{ trig = "gamma", cmd = "gamma" },
			{ trig = "Gamma", cmd = "Gamma" },
			{ trig = "delta", cmd = "delta" },
			{ trig = "Delta", cmd = "Delta" },
			{ trig = "epsilon", cmd = "epsilon" },
			{ trig = "varepsilon", cmd = "varepsilon" },
			{ trig = "zeta", cmd = "zeta" },
			{ trig = "eta", cmd = "eta" },
			{ trig = "theta", cmd = "theta" },
			{ trig = "vartheta", cmd = "vartheta" },
			{ trig = "Theta", cmd = "Theta" },
			{ trig = "iota", cmd = "iota" },
			{ trig = "kappa", cmd = "kappa" },
			{ trig = "lambda", cmd = "lambda" },
			{ trig = "Lambda", cmd = "Lambda" },
			{ trig = "mu", cmd = "mu" },
			{ trig = "nu", cmd = "nu" },
			{ trig = "xi", cmd = "xi" },
			{ trig = "omicron", cmd = "omicron" },
			{ trig = "pi", cmd = "pi" },
			{ trig = "Pi", cmd = "Pi" },
			{ trig = "rho", cmd = "rho" },
			{ trig = "varrho", cmd = "varrho" },
			{ trig = "sigma", cmd = "sigma" },
			{ trig = "Sigma", cmd = "Sigma" },
			{ trig = "tau", cmd = "tau" },
			{ trig = "upsilon", cmd = "upsilon" },
			{ trig = "Upsilon", cmd = "Upsilon" },
			{ trig = "phi", cmd = "phi" },
			{ trig = "varphi", cmd = "varphi" },
			{ trig = "Phi", cmd = "Phi" },
			{ trig = "chi", cmd = "chi" },
			{ trig = "omega", cmd = "omega" },
			{ trig = "Omega", cmd = "Omega" },
		}

		local symbols = {
			{ trig = "parallel", cmd = "parallel" },
			{ trig = "perp", cmd = "perp" },
			{ trig = "partial", cmd = "partial" },
			{ trig = "nabla", cmd = "nabla" },
			{ trig = "hbar", cmd = "hbar" },
			{ trig = "ell", cmd = "ell" },
			{ trig = "infty", cmd = "infty" },
			{ trig = "oplus", cmd = "oplus" },
			{ trig = "ominus", cmd = "ominus" },
			{ trig = "otimes", cmd = "otimes" },
			{ trig = "oslash", cmd = "oslash" },
			{ trig = "square", cmd = "square" },
			{ trig = "star", cmd = "star" },
			{ trig = "dagger", cmd = "dagger" },
			{ trig = "vee", cmd = "vee" },
			{ trig = "wedge", cmd = "wedge" },
			{ trig = "subseteq", cmd = "subseteq" },
			{ trig = "subset", cmd = "subset" },
			{ trig = "supseteq", cmd = "supseteq" },
			{ trig = "supset", cmd = "supset" },
			{ trig = "emptyset", cmd = "emptyset" },
			{ trig = "exists", cmd = "exists" },
			{ trig = "nexists", cmd = "nexists" },
			{ trig = "forall", cmd = "forall" },
			{ trig = "implies", cmd = "implies" },
			{ trig = "impliedby", cmd = "impliedby" },
			{ trig = "iff", cmd = "iff" },
			{ trig = "setminus", cmd = "setminus" },
			{ trig = "neg", cmd = "neg" },
			{ trig = "lor", cmd = "lor" },
			{ trig = "land", cmd = "land" },
			{ trig = "bigcup", cmd = "bigcup" },
			{ trig = "bigcap", cmd = "bigcap" },
			{ trig = "cdot", cmd = "cdot" },
			{ trig = "times", cmd = "times" },
			{ trig = "simeq", cmd = "simeq" },
			{ trig = "approx", cmd = "approx" },
		}

		local more_symbols = {
			{ trig = "leq", cmd = "leq" },
			{ trig = "geq", cmd = "geq" },
			{ trig = "neq", cmd = "neq" },
			{ trig = "gg", cmd = "gg" },
			{ trig = "ll", cmd = "ll" },
			{ trig = "equiv", cmd = "equiv" },
			{ trig = "sim", cmd = "sim" },
			{ trig = "propto", cmd = "propto" },
			{ trig = "rightarrow", cmd = "rightarrow" },
			{ trig = "leftarrow", cmd = "leftarrow" },
			{ trig = "Rightarrow", cmd = "Rightarrow" },
			{ trig = "Leftarrow", cmd = "Leftarrow" },
			{ trig = "leftrightarrow", cmd = "leftrightarrow" },
			{ trig = "to", cmd = "to" },
			{ trig = "mapsto", cmd = "mapsto" },
			{ trig = "cap", cmd = "cap" },
			{ trig = "cup", cmd = "cup" },
			{ trig = "inn", cmd = "in" },
			{ trig = "sum", cmd = "sum" },
			{ trig = "prod", cmd = "prod" },
			{ trig = "exp", cmd = "exp" },
			{ trig = "ln", cmd = "ln" },
			{ trig = "log", cmd = "log" },
			{ trig = "sin", cmd = "sin" },
			{ trig = "cos", cmd = "cos" },
			{ trig = "tan", cmd = "tan" },
			{ trig = "arcsin", cmd = "arcsin" },
			{ trig = "arccos", cmd = "arccos" },
			{ trig = "arctan", cmd = "arctan" },
			{ trig = "det", cmd = "det" },
			{ trig = "dots", cmd = "dots" },
			{ trig = "vdots", cmd = "vdots" },
			{ trig = "ddots", cmd = "ddots" },
			{ trig = "pm", cmd = "pm" },
			{ trig = "mp", cmd = "mp" },
			{ trig = "int", cmd = "int" },
			{ trig = "iint", cmd = "iint" },
			{ trig = "iiint", cmd = "iiint" },
			{ trig = "oint", cmd = "oint" },
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
			s({ trig = "lr(", wordTrig = false, snippetType = "autosnippet" }, fmta([[\left(<>\right)]], { i(1) })),
			s({ trig = "lr[", wordTrig = false, snippetType = "autosnippet" }, fmta([[\left[<>\right] ]], { i(1) })),
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
			s(
				{ trig = "@question", wordTrig = false, snippetType = "autosnippet" },
				fmta(
					[[
          \begin{question}
          \questiontext{<>}
          \answer{

          }
          \end{question}
          ]],
					{ i(1) }
				)
			),
			s(
				{ trig = "@align", wordTrig = false, snippetType = "autosnippet" },
				fmta(
					[[
          \begin{align*}
          <>
          \end{align*}
          ]],
					{ i(1) }
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

		local snippet_defs = {}
		for _, tab in ipairs({ greek_symbols, symbols, more_symbols }) do
			for _, sym in ipairs(tab) do
				table.insert(
					snippet_defs,
					s({
						trig = sym.trig,
						regTrig = true,
						wordTrig = false,
						priority = sym.priority or DEFAULT_PRIORITY,
						snippetType = "autosnippet",
						condition = in_math_mode,
					}, {
						f(function()
							return "\\" .. sym.cmd
						end, {}),
					})
				)
			end
		end
		ls.add_snippets("tex", snippet_defs)

		vim.keymap.set("i", "<C-k>", function()
			ls.expand()
		end)
	end,
}
