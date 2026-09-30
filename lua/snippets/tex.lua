-- ~/.config/nvim/lua/snippets/tex.lua
-- LuaSnip port of data-tex.json (Obsidian LaTeX Suite → LaTeX)
-- Requires: enable_autosnippets = true

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local rep = require("luasnip.extras").rep
local visual = require("luasnip.extras.expand_conditions").visual

-- ------------------------------------------------------------
-- Math mode detection (treesitter)
-- ------------------------------------------------------------
local math_types = { "inline_formula", "displayed_equation", "math_environment" }
local function in_math_mode()
	local ok, node = pcall(vim.treesitter.get_node)
	if not ok or not node then
		return false
	end
	local cur = node
	while cur do
		local ty = cur:type()
		for _, mt in ipairs(math_types) do
			if ty == mt then
				return true
			end
		end
		local parent = cur:parent()
		if not parent then
			break
		end
		cur = parent
	end
	return false
end
local function in_text_mode()
	return not in_math_mode()
end

-- ------------------------------------------------------------
-- Regex fragments from snippetVariables
-- ------------------------------------------------------------
local GREEK =
	"(?:alpha|beta|gamma|Gamma|delta|Delta|epsilon|varepsilon|zeta|eta|theta|vartheta|Theta|iota|kappa|lambda|Lambda|mu|nu|xi|omicron|pi|rho|varrho|sigma|Sigma|tau|upsilon|Upsilon|phi|varphi|Phi|chi|psi|omega|Omega)"
local SYMBOL =
	"(?:parallel|perp|partial|nabla|hbar|ell|infty|oplus|ominus|otimes|oslash|square|star|dagger|vee|wedge|subseteq|subset|supseteq|supset|emptyset|exists|nexists|forall|implies|impliedby|iff|setminus|neg|lor|land|bigcup|bigcap|cdot|times|simeq|approx)"
local MORE_SYMBOLS =
	"(?:leq|geq|neq|gg|ll|equiv|sim|propto|rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|to|mapsto|cap|cup|in|sum|prod|exp|ln|log|det|dots|vdots|ddots|pm|mp|int|iint|iiint|oint)"
local ACCENT = "(?:dot|ddot|hat|bar|tilde|vec|underline|overline|mathbf|mathcal|mathrm|mathbb)"

-- Helper: read the visual selection from the unnamed register.
-- LuaSnip yanks the visual selection into `"` before expanding.
local function visual_content()
	return vim.fn.getreg('"')
end

-- ============================================================
local snippets = {}

-- ------------------------------------------------------------
-- Math mode
-- ------------------------------------------------------------
table.insert(
	snippets,
	s({ trig = "mk", snippetType = "autosnippet", condition = in_text_mode }, { t("$"), i(0), t("$") })
)

table.insert(
	snippets,
	s(
		{ trig = "dm", snippetType = "autosnippet", condition = in_text_mode, wordTrig = true },
		{ t("$$\n\t"), i(0), t("\n$$") }
	)
)

table.insert(
	snippets,
	s(
		{
			trig = "(?<=\\S.*)dm",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_text_mode,
			priority = 1,
			wordTrig = false,
		},
		{ t("\n$$\n\t"), i(0), t("\n$$") }
	)
)

-- \begin{env} ... \end{env} — multi-line, math mode, auto
table.insert(
	snippets,
	s(
		{
			trig = "([^\\\\])beg",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("\\begin{"),
			i(1),
			t("}\n\t"),
			i(2),
			t("\n\\end{"),
			rep(1),
			t("}"),
		}
	)
)

-- \begin{env} ... \end{env} — inline, both modes, auto (wordTrig off)
table.insert(
	snippets,
	s({ trig = "([^\\\\])beg", trigEngine = "ecma", snippetType = "autosnippet", wordTrig = false }, {
		f(function(_, snip)
			return snip.captures[1]
		end, {}),
		t("\\begin{"),
		i(1),
		t("} "),
		i(2),
		t(" \\end{"),
		rep(1),
		t("}"),
	})
)

-- ------------------------------------------------------------
-- Greek letters
-- ------------------------------------------------------------
local greek_trigs = {
	{ "@a", "\\alpha" },
	{ "@b", "\\beta" },
	{ "@g", "\\gamma" },
	{ "@G", "\\Gamma" },
	{ "@d", "\\delta" },
	{ "@D", "\\Delta" },
	{ "@e", "\\epsilon" },
	{ ":e", "\\varepsilon" },
	{ "@z", "\\zeta" },
	{ "@t", "\\theta" },
	{ "@T", "\\Theta" },
	{ ":t", "\\vartheta" },
	{ "@i", "\\iota" },
	{ "@k", "\\kappa" },
	{ "@l", "\\lambda" },
	{ "@L", "\\Lambda" },
	{ "@s", "\\sigma" },
	{ "@S", "\\Sigma" },
	{ "@u", "\\upsilon" },
	{ "@U", "\\Upsilon" },
	{ "@o", "\\omega" },
	{ "@O", "\\Omega" },
	{ "ome", "\\omega" },
	{ "Ome", "\\Omega" },
}
for _, g in ipairs(greek_trigs) do
	table.insert(
		snippets,
		s({ trig = g[1], snippetType = "autosnippet", condition = in_math_mode, wordTrig = false }, { t(g[2]) })
	)
end

-- ------------------------------------------------------------
-- Text environment
-- ------------------------------------------------------------
table.insert(
	snippets,
	s({ trig = "text", snippetType = "autosnippet", condition = in_math_mode }, { t("\\text{"), i(1), t("}"), i(2) })
)
table.insert(
	snippets,
	s({ trig = '"', snippetType = "autosnippet", condition = in_math_mode }, { t("\\text{"), i(1), t("}"), i(2) })
)

-- ------------------------------------------------------------
-- Basic operations
-- ------------------------------------------------------------
table.insert(snippets, s({ trig = "sr", snippetType = "autosnippet", condition = in_math_mode }, { t("^{2}") }))
table.insert(snippets, s({ trig = "cb", snippetType = "autosnippet", condition = in_math_mode }, { t("^{3}") }))
table.insert(
	snippets,
	s({ trig = "rd", snippetType = "autosnippet", condition = in_math_mode }, { t("^{"), i(1), t("}"), i(2) })
)
table.insert(
	snippets,
	s(
		{ trig = "_", snippetType = "autosnippet", condition = in_math_mode, wordTrig = false },
		{ t("_{"), i(1), t("}"), i(2) }
	)
)
table.insert(
	snippets,
	s({ trig = "sts", snippetType = "autosnippet", condition = in_math_mode }, { t("_\\text{"), i(1), t("}") })
)
table.insert(
	snippets,
	s({ trig = "sq", snippetType = "autosnippet", condition = in_math_mode }, { t("\\sqrt{ "), i(1), t(" }"), i(2) })
)
table.insert(
	snippets,
	s(
		{ trig = "//", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\frac{"), i(1), t("}{"), i(2), t("}"), i(3) }
	)
)
table.insert(
	snippets,
	s({ trig = "ee", snippetType = "autosnippet", condition = in_math_mode }, { t("e^{ "), i(1), t(" }"), i(2) })
)
table.insert(snippets, s({ trig = "invs", snippetType = "autosnippet", condition = in_math_mode }, { t("^{-1}") }))

-- exp/log/ln add backslash
table.insert(
	snippets,
	s(
		{
			trig = "([^\\\\])(exp|log|ln)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("\\"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)

table.insert(snippets, s({ trig = "conj", snippetType = "autosnippet", condition = in_math_mode }, { t("^{*}") }))
table.insert(snippets, s({ trig = "Re", snippetType = "autosnippet", condition = in_math_mode }, { t("\\mathrm{Re}") }))
table.insert(snippets, s({ trig = "Im", snippetType = "autosnippet", condition = in_math_mode }, { t("\\mathrm{Im}") }))
table.insert(
	snippets,
	s({ trig = "bf", snippetType = "autosnippet", condition = in_math_mode }, { t("\\mathbf{"), i(1), t("}") })
)
table.insert(
	snippets,
	s({ trig = "rm", snippetType = "autosnippet", condition = in_math_mode }, { t("\\mathrm{"), i(1), t("}"), i(2) })
)

-- ------------------------------------------------------------
-- Linear algebra
-- ------------------------------------------------------------
table.insert(
	snippets,
	s(
		{
			trig = "([^\\\\])(det)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("\\"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)
table.insert(
	snippets,
	s({ trig = "trace", snippetType = "autosnippet", condition = in_math_mode }, { t("\\mathrm{Tr}") })
)

-- ------------------------------------------------------------
-- Accents: letter + suffix   (xhat → \hat{x})
-- ------------------------------------------------------------
local letter_accents = {
	{ "hat", "hat" },
	{ "bar", "bar" },
	{ "dot", "dot", priority = -1 },
	{ "ddot", "ddot", priority = 1 },
	{ "tilde", "tilde" },
	{ "und", "underline" },
	{ "vec", "vec" },
}
for _, a in ipairs(letter_accents) do
	table.insert(
		snippets,
		s(
			{
				trig = "([a-zA-Z])" .. a[1],
				trigEngine = "ecma",
				snippetType = "autosnippet",
				condition = in_math_mode,
				wordTrig = false,
				priority = a.priority,
			},
			{
				t("\\" .. a[2] .. "{"),
				f(function(_, snip)
					return snip.captures[1]
				end, {}),
				t("}"),
			}
		)
	)
end

-- Bold: x,. / x., / \greek,. / \greek.,
table.insert(
	snippets,
	s(
		{
			trig = "([a-zA-Z]),\\.",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\mathbf{"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("}"),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "([a-zA-Z])\\.,",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\mathbf{"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("}"),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. GREEK .. "),\\\\.",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\boldsymbol{\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("}"),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. GREEK .. ")\\\\.,",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\boldsymbol{\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("}"),
		}
	)
)

-- Standalone accents (no captured letter): hat, bar, dot, ddot, cdot, tilde, und, vec
local standalone_accents = {
	{ "hat", "hat", priority = nil },
	{ "bar", "bar", priority = nil },
	{ "dot", "dot", priority = -1 },
	{ "ddot", "ddot", priority = nil },
	{ "tilde", "tilde", priority = nil },
	{ "und", "underline", priority = nil },
	{ "vec", "vec", priority = nil },
}
for _, a in ipairs(standalone_accents) do
	table.insert(
		snippets,
		s(
			{ trig = a[1], snippetType = "autosnippet", condition = in_math_mode, priority = a.priority },
			{ t("\\" .. a[2] .. "{"), i(1), t("}"), i(2) }
		)
	)
end
table.insert(snippets, s({ trig = "cdot", snippetType = "autosnippet", condition = in_math_mode }, { t("\\cdot") }))

-- pmod
table.insert(
	snippets,
	s(
		{ trig = "pmod", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\pmod{"), i(1, "n"), t("}"), i(2) }
	)
)

-- ------------------------------------------------------------
-- Auto letter subscript + combine subscript
-- ------------------------------------------------------------
-- x3 → x_{3};  \alpha3 → \alpha_{3}
table.insert(
	snippets,
	s(
		{
			trig = "(\\\\" .. GREEK .. "|[A-Za-z])(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = -1,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("_{"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
			t("}"),
		}
	)
)

-- x_{3}4 → x_{34}
table.insert(
	snippets,
	s(
		{
			trig = "(\\\\" .. GREEK .. "|[A-Za-z])_{(\\d+)}(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = -1,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("_{"),
			f(function(_, snip)
				return snip.captures[2] .. snip.captures[3]
			end, {}),
			t("}"),
		}
	)
)

-- \dot{x}3 → \dot{x}_{3}
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. ACCENT .. ")\\{((\\\\" .. GREEK .. "|[A-Za-z]))\\}(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = -1,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("{"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
			t("}_{"),
			f(function(_, snip)
				return snip.captures[3]
			end, {}),
			t("}"),
		}
	)
)

-- \dot{x}_{3}4 → \dot{x}_{34}
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. ACCENT .. ")\\{((\\\\" .. GREEK .. "|[A-Za-z]))\\}_\\{(\\d+)\\}(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = -1,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("{"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
			t("}_{"),
			f(function(_, snip)
				return snip.captures[3] .. snip.captures[4]
			end, {}),
			t("}"),
		}
	)
)

-- \dot{\vec{a}}3 → \dot{\vec{a}}_{3}
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. ACCENT .. ")\\{\\\\(" .. ACCENT .. ")\\{((\\\\" .. GREEK .. "|[A-Za-z]))\\}\\}(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = -1,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("{\\"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
			t("{"),
			f(function(_, snip)
				return snip.captures[3]
			end, {}),
			t("}}_{"),
			f(function(_, snip)
				return snip.captures[4]
			end, {}),
			t("}"),
		}
	)
)

-- \dot{\vec{a}}_{3}4 → \dot{\vec{a}}_{34}
table.insert(
	snippets,
	s(
		{
			trig = "\\\\("
				.. ACCENT
				.. ")\\{\\\\("
				.. ACCENT
				.. ")\\{((\\\\"
				.. GREEK
				.. "|[A-Za-z]))\\}\\}_\\{(\\d+)\\}(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = -1,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("{\\"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
			t("{"),
			f(function(_, snip)
				return snip.captures[3]
			end, {}),
			t("}}_{"),
			f(function(_, snip)
				return snip.captures[4] .. snip.captures[5]
			end, {}),
			t("}"),
		}
	)
)

-- Common subscript shortcuts
local subscript_shorts = {
	{ "xnn", "x_{n}" },
	{ "\\xii", "x_{i}", priority = 1 },
	{ "xjj", "x_{j}" },
	{ "xp1", "x_{n+1}" },
	{ "ynn", "y_{n}" },
	{ "yii", "y_{i}" },
	{ "yjj", "y_{j}" },
}
for _, sh in ipairs(subscript_shorts) do
	table.insert(
		snippets,
		s({ trig = sh[1], snippetType = "autosnippet", condition = in_math_mode, priority = sh.priority }, { t(sh[2]) })
	)
end

-- ------------------------------------------------------------
-- Symbols (plain triggers)
-- ------------------------------------------------------------
local plain_symbols = {
	{ "ooo", "\\infty" },
	{ "prod", "\\prod" },
	{ "+-", "\\pm" },
	{ "-+", "\\mp" },
	{ "...", "\\dots" },
	{ "nabl", "\\nabla" },
	{ "xx", "\\times" },
	{ "**", "\\cdot" },
	{ "para", "\\parallel" },
	{ "===", "\\equiv" },
	{ "!=", "\\neq" },
	{ ">=", "\\geq" },
	{ "<=", "\\leq" },
	{ ">>", "\\gg" },
	{ "<<", "\\ll" },
	{ "simm", "\\sim" },
	{ "sim=", "\\simeq" },
	{ "prop", "\\propto" },
	{ "<->", "\\leftrightarrow " },
	{ "->", "\\to" },
	{ "!>", "\\mapsto" },
	{ "=>", "\\implies" },
	{ "=<", "\\impliedby" },
	{ "and", "\\cap" },
	{ "orr", "\\cup" },
	{ "inn", "\\in" },
	{ "notin", "\\not\\in" },
	{ "\\\\\\\\\\", "\\setminus" },
	{ "sub=", "\\subseteq" },
	{ "sup=", "\\supseteq" },
	{ "eset", "\\emptyset" },
	{ "set", "\\{ $0 \\}" },
	{ "e\\xi sts", "\\exists" },
	{ "LL", "\\mathcal{L}" },
	{ "HH", "\\mathcal{H}" },
	{ "CC", "\\mathbb{C}" },
	{ "RR", "\\mathbb{R}" },
	{ "ZZ", "\\mathbb{Z}" },
	{ "NN", "\\mathbb{N}" },
}
for _, sy in ipairs(plain_symbols) do
	if sy[1] == "set" then
		table.insert(
			snippets,
			s(
				{ trig = sy[1], snippetType = "autosnippet", condition = in_math_mode },
				{ t("\\{ "), i(1), t(" \\}"), i(2) }
			)
		)
	else
		table.insert(
			snippets,
			s({ trig = sy[1], snippetType = "autosnippet", condition = in_math_mode, wordTrig = false }, { t(sy[2]) })
		)
	end
end

-- sum / prod / lim with parameters
table.insert(
	snippets,
	s(
		{ trig = "\\sum", snippetType = "snippet", condition = in_math_mode },
		{ t("\\sum_{"), i(1, "i"), t("="), i(2, "1"), t("}^{"), i(3, "N"), t("} "), i(4) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "\\prod", snippetType = "snippet", condition = in_math_mode },
		{ t("\\prod_{"), i(1, "i"), t("="), i(2, "1"), t("}^{"), i(3, "N"), t("} "), i(4) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "lim", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\lim_{ "), i(1, "n"), t(" \\to "), i(2, "\\infty"), t(" } "), i(3) }
	)
)

-- Greek accents: \alpha hat → \hat{\alpha}, etc.
local greek_accents = {
	{ "hat", "hat" },
	{ "dot", "dot" },
	{ "bar", "bar" },
	{ "vec", "vec" },
	{ "tilde", "tilde" },
	{ "und", "underline" },
}
for _, ga in ipairs(greek_accents) do
	table.insert(
		snippets,
		s(
			{
				trig = "\\\\(" .. GREEK .. ") " .. ga[1],
				trigEngine = "ecma",
				snippetType = "autosnippet",
				condition = in_math_mode,
				wordTrig = false,
			},
			{
				t("\\" .. ga[2] .. "{\\"),
				f(function(_, snip)
					return snip.captures[1]
				end, {}),
				t("}"),
			}
		)
	)
end
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") sr",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("^{2}"),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") cb",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("^{3}"),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") rd",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("^{"),
			i(1),
			t("}"),
			i(2),
		}
	)
)

-- Add backslash before Greek letters / symbols
table.insert(
	snippets,
	s(
		{
			trig = "([^\\\\])(" .. GREEK .. ")",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("\\"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "([^\\\\])(" .. SYMBOL .. ")",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("\\"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)

-- Insert space after Greek / symbol followed by letter
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. "|" .. MORE_SYMBOLS .. ")([A-Za-z])",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t(" "),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)

-- ------------------------------------------------------------
-- Derivatives and integrals
-- ------------------------------------------------------------
table.insert(
	snippets,
	s(
		{ trig = "par", snippetType = "snippet", condition = in_math_mode },
		{ t("\\frac{ \\partial "), i(0, "y"), t(" }{ \\partial "), i(1, "x"), t(" } "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "pa([A-Za-z])([A-Za-z])",
			trigEngine = "ecma",
			snippetType = "snippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\frac{ \\partial "),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t(" }{ \\partial "),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
			t(" } "),
		}
	)
)
table.insert(
	snippets,
	s({ trig = "ddt", snippetType = "autosnippet", condition = in_math_mode }, { t("\\frac{d}{dt} ") })
)

table.insert(
	snippets,
	s(
		{
			trig = "([^\\\\])int",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = -1,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("\\int"),
		}
	)
)
table.insert(
	snippets,
	s(
		{ trig = "\\int", snippetType = "snippet", condition = in_math_mode },
		{ t("\\int "), i(1), t(" \\, d"), i(2, "x"), t(" "), i(3) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "dint", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\int_{"), i(1, "0"), t("}^{"), i(2, "1"), t("} "), i(3), t(" \\, d"), i(4, "x"), t(" "), i(5) }
	)
)
table.insert(snippets, s({ trig = "oint", snippetType = "autosnippet", condition = in_math_mode }, { t("\\oint") }))
table.insert(snippets, s({ trig = "iint", snippetType = "autosnippet", condition = in_math_mode }, { t("\\iint") }))
table.insert(snippets, s({ trig = "iiint", snippetType = "autosnippet", condition = in_math_mode }, { t("\\iiint") }))
table.insert(
	snippets,
	s(
		{ trig = "oinf", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\int_{0}^{\\infty} "), i(1), t(" \\, d"), i(2, "x"), t(" "), i(3) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "infi", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\int_{-\\infty}^{\\infty} "), i(1), t(" \\, d"), i(2, "x"), t(" "), i(3) }
	)
)

-- ------------------------------------------------------------
-- Trigonometry (add backslash / space)
-- ------------------------------------------------------------
table.insert(
	snippets,
	s(
		{
			trig = "([^\\\\])(arcsin|sin|arccos|cos|arctan|tan|csc|sec|cot)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("\\"),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(arcsin|sin|arccos|cos|arctan|tan|csc|sec|cot)([A-Za-gi-z])",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t(" "),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)
table.insert(
	snippets,
	s(
		{
			trig = "\\\\(sinh|cosh|tanh|coth)([A-Za-z])",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t(" "),
			f(function(_, snip)
				return snip.captures[2]
			end, {}),
		}
	)
)
-- arccsc / arcsec / arccot → \operatorname{...}
table.insert(
	snippets,
	s(
		{
			trig = "(arccsc|arcsec|arccot)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
			priority = 1,
		},
		{
			t("\\operatorname{"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("}"),
		}
	)
)

-- ------------------------------------------------------------
-- Visual operations
-- (LuaSnip yanks the selection into `"` before expanding,
--  so we read it with vim.fn.getreg('"').)
-- ------------------------------------------------------------
local function vcontent()
	return vim.fn.getreg('"')
end

table.insert(
	snippets,
	s(
		{ trig = "U", snippetType = "snippet", condition = visual },
		{ t("\\underbrace{ "), f(vcontent, {}), t(" }_{ "), i(1), t(" }") }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "O", snippetType = "snippet", condition = visual },
		{ t("\\overbrace{ "), f(vcontent, {}), t(" }^{ "), i(1), t(" }") }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "B", snippetType = "snippet", condition = visual },
		{ t("\\underset{ "), i(1), t(" }{ "), f(vcontent, {}), t(" }") }
	)
)
table.insert(
	snippets,
	s({ trig = "C", snippetType = "snippet", condition = visual }, { t("\\cancel{ "), f(vcontent, {}), t(" }") })
)
table.insert(
	snippets,
	s(
		{ trig = "K", snippetType = "snippet", condition = visual },
		{ t("\\cancelto{ "), i(1), t(" }{ "), f(vcontent, {}), t(" }") }
	)
)
table.insert(
	snippets,
	s({ trig = "S", snippetType = "snippet", condition = visual }, { t("\\sqrt{ "), f(vcontent, {}), t(" }") })
)

-- ------------------------------------------------------------
-- Physics
-- ------------------------------------------------------------
table.insert(snippets, s({ trig = "kbt", snippetType = "autosnippet", condition = in_math_mode }, { t("k_{B}T") }))
table.insert(snippets, s({ trig = "msun", snippetType = "autosnippet", condition = in_math_mode }, { t("M_{\\odot}") }))

-- ------------------------------------------------------------
-- Quantum mechanics
-- ------------------------------------------------------------
table.insert(snippets, s({ trig = "dag", snippetType = "autosnippet", condition = in_math_mode }, { t("^{\\dagger}") }))
table.insert(snippets, s({ trig = "o+", snippetType = "autosnippet", condition = in_math_mode }, { t("\\oplus ") }))
table.insert(snippets, s({ trig = "ox", snippetType = "autosnippet", condition = in_math_mode }, { t("\\otimes ") }))
table.insert(
	snippets,
	s({ trig = "bra", snippetType = "autosnippet", condition = in_math_mode }, { t("\\bra{"), i(1), t("} "), i(2) })
)
table.insert(
	snippets,
	s({ trig = "ket", snippetType = "autosnippet", condition = in_math_mode }, { t("\\ket{"), i(1), t("} "), i(2) })
)
table.insert(
	snippets,
	s(
		{ trig = "brk", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\braket{ "), i(1), t(" | "), i(2), t(" } "), i(3) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "outer", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\ket{"), i(1, "\\psi"), t("} \\bra{"), rep(1), t("} "), i(2) }
	)
)

-- ------------------------------------------------------------
-- Chemistry
-- ------------------------------------------------------------
table.insert(
	snippets,
	s({ trig = "pu", snippetType = "autosnippet", condition = in_math_mode }, { t("\\pu{ "), i(1), t(" }") })
)
table.insert(
	snippets,
	s({ trig = "cee", snippetType = "autosnippet", condition = in_math_mode }, { t("\\ce{ "), i(1), t(" }") })
)
table.insert(
	snippets,
	s({ trig = "he4", snippetType = "autosnippet", condition = in_math_mode }, { t("{}^{4}_{2}He ") })
)
table.insert(
	snippets,
	s({ trig = "he3", snippetType = "autosnippet", condition = in_math_mode }, { t("{}^{3}_{2}He ") })
)
table.insert(
	snippets,
	s(
		{ trig = "iso", snippetType = "autosnippet", condition = in_math_mode },
		{ t("{}^{"), i(1, "4"), t("}_{"), i(2, "2"), t("}"), i(3, "He") }
	)
)

-- ------------------------------------------------------------
-- Environments (matrices)
-- ------------------------------------------------------------
local function env_from_match(cap)
	local typ = cap or ""
	local name = typ:sub(1, 1) .. "matrix"
	if typ == "pmat" then
		name = "pmatrix"
	elseif typ == "bmat" then
		name = "bmatrix"
	elseif typ == "Bmat" then
		name = "Bmatrix"
	elseif typ == "vmat" then
		name = "vmatrix"
	elseif typ == "Vmat" then
		name = "Vmatrix"
	end
	return name
end

table.insert(
	snippets,
	s(
		{
			trig = "([pbBvV]mat)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\begin{"),
			f(function(_, snip)
				return env_from_match(snip.captures[1])
			end, {}),
			t("}\n\t"),
			i(1),
			t("\n\\end{"),
			f(function(_, snip)
				return env_from_match(snip.captures[1])
			end, {}),
			t("}"),
		}
	)
)

table.insert(
	snippets,
	s(
		{
			trig = "(matrix|cases|align|array)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math_mode,
			wordTrig = false,
		},
		{
			t("\\begin{"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("}\n\t"),
			i(1),
			t("\n\\end{"),
			f(function(_, snip)
				return snip.captures[1]
			end, {}),
			t("}"),
		}
	)
)

table.insert(
	snippets,
	s({ trig = "([pbBvV]mat)", trigEngine = "ecma", snippetType = "autosnippet", wordTrig = false }, {
		t("\\begin{"),
		f(function(_, snip)
			return env_from_match(snip.captures[1])
		end, {}),
		t("}"),
		i(1),
		t("\\end{"),
		f(function(_, snip)
			return env_from_match(snip.captures[1])
		end, {}),
		t("}"),
	})
)

table.insert(
	snippets,
	s({ trig = "(matrix|cases|align|array)", trigEngine = "ecma", snippetType = "autosnippet", wordTrig = false }, {
		t("\\begin{"),
		f(function(_, snip)
			return snip.captures[1]
		end, {}),
		t("}"),
		i(1),
		t("\\end{"),
		f(function(_, snip)
			return snip.captures[1]
		end, {}),
		t("}"),
	})
)

-- ------------------------------------------------------------
-- Brackets
-- ------------------------------------------------------------
table.insert(
	snippets,
	s(
		{ trig = "avg", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\langle "), i(1), t(" \\rangle "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "norm", snippetType = "autosnippet", condition = in_math_mode, priority = 1 },
		{ t("\\lvert "), i(1), t(" \\rvert "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "Norm", snippetType = "autosnippet", condition = in_math_mode, priority = 1 },
		{ t("\\lVert "), i(1), t(" \\rVert "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "ceil", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\lceil "), i(1), t(" \\rceil "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "floor", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\lfloor "), i(1), t(" \\rfloor "), i(2) }
	)
)
table.insert(
	snippets,
	s({ trig = "mod", snippetType = "autosnippet", condition = in_math_mode }, { t("|"), i(1), t("|"), i(2) })
)

-- Visual bracket wrap
table.insert(
	snippets,
	s({ trig = "(", snippetType = "snippet", condition = visual }, { t("("), f(vcontent, {}), t(")") })
)
table.insert(
	snippets,
	s({ trig = "[", snippetType = "snippet", condition = visual }, { t("["), f(vcontent, {}), t("]") })
)
table.insert(
	snippets,
	s({ trig = "{", snippetType = "snippet", condition = visual }, { t("{"), f(vcontent, {}), t("}") })
)

-- Non-visual brackets
table.insert(
	snippets,
	s({ trig = "(", snippetType = "autosnippet", condition = in_math_mode }, { t("("), i(1), t(")"), i(2) })
)
table.insert(
	snippets,
	s({ trig = "{", snippetType = "autosnippet", condition = in_math_mode }, { t("{"), i(1), t("}"), i(2) })
)
table.insert(
	snippets,
	s({ trig = "[", snippetType = "autosnippet", condition = in_math_mode }, { t("["), i(1), t("]"), i(2) })
)
table.insert(
	snippets,
	s(
		{ trig = "lr(", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\left( "), i(1), t(" \\right) "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "lr{", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\left\\{ "), i(1), t(" \\right\\} "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "lr[", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\left[ "), i(1), t(" \\right] "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "lr|", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\left| "), i(1), t(" \\right| "), i(2) }
	)
)
table.insert(
	snippets,
	s(
		{ trig = "lra", snippetType = "autosnippet", condition = in_math_mode },
		{ t("\\left< "), i(1), t(" \\right> "), i(2) }
	)
)

-- ------------------------------------------------------------
-- Misc
-- ------------------------------------------------------------

-- Taylor expansion
table.insert(
	snippets,
	s({ trig = "tayl", snippetType = "autosnippet", condition = in_math_mode }, {
		i(1, "f"),
		t("("),
		i(2, "x"),
		t(" + "),
		i(3, "h"),
		t(") = "),
		rep(1),
		t("("),
		rep(2),
		t(") + "),
		rep(1),
		t("'("),
		rep(2),
		t(")"),
		rep(3),
		t(" + "),
		rep(1),
		t("''("),
		rep(2),
		t(") \\frac{"),
		rep(3),
		t("^{2}}{2!} + \\dots"),
		i(4),
	})
)

-- Identity matrix
table.insert(
	snippets,
	s({ trig = "iden(\\d)", trigEngine = "ecma", snippetType = "autosnippet", condition = in_math_mode }, {
		f(function(_, snip)
			local n = tonumber(snip.captures[1]) or 2
			local rows = {}
			for j = 1, n do
				local row = {}
				for i = 1, n do
					row[i] = (i == j) and "1" or "0"
				end
				rows[j] = table.concat(row, " & ")
			end
			return "\\begin{pmatrix}\n" .. table.concat(rows, " \\\\\n") .. "\n\\end{pmatrix}"
		end, {}),
	})
)

-- Display math inside a list item:  "- foo dm"
table.insert(
	snippets,
	s(
		{
			trig = "(?<=(?:\\n|^)[ \\t]*>*)(?<marker>\\d+[.)]|[-*+])(?<whitespace>[ \\t]+)(?<text>.*)dm",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_text_mode,
			priority = 2,
		},
		{
			f(function(_, snip)
				local marker = snip.captures[1] or ""
				local ws = snip.captures[2] or ""
				local text = snip.captures[3] or ""
				local indent = string.rep(" ", #marker) .. ws
				return marker .. ws .. text .. "\n" .. indent .. "$$\n" .. indent .. "\t"
			end, {}),
			i(1),
			f(function(_, snip)
				local marker = snip.captures[1] or ""
				local ws = snip.captures[2] or ""
				local indent = string.rep(" ", #marker) .. ws
				return "\n" .. indent .. "$$"
			end, {}),
		}
	)
)

return snippets
