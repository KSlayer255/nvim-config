-- ~/.config/nvim/lua/snippets/typst.lua
-- LuaSnip port of Obsidian LaTeX Suite snippets for Typst

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmta = require("luasnip.extras.fmt").fmta

-- ============================================================
-- Helpers
-- ============================================================
-- Math-mode detection via treesitter
-- In uben0/tree-sitter-typst, both inline ($x$) and display ($ x $)
-- math are wrapped in a node of type "math". Walk up from the cursor
-- node until we find it (or run out of ancestors).
local function in_math()
	local bufnr = vim.api.nvim_get_current_buf()

	-- get_parser(bufnr, lang) attaches the parser to the buffer if needed.
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "typst")
	if not ok or not parser then
		return false
	end

	local ok2, trees = pcall(parser.parse, parser)
	if not ok2 or not trees or not trees[1] then
		return false
	end

	-- Cursor: nvim_win_get_cursor returns {row, col} with row 1-indexed
	-- and col 0-indexed bytes. Treesitter wants 0-indexed row, byte col.
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local col = cursor[2]

	local root = trees[1]:root()
	local node = root:named_descendant_for_range(row, col, row, col)

	while node do
		if node:type() == "math" then
			return true
		end
		node = node:parent()
	end
	return false
end

local function in_text()
	return not in_math()
end

local visual = require("luasnip.extras.expand_conditions").visual

local ALL_MACROS = {
	"alpha",
	"beta",
	"gamma",
	"Gamma",
	"delta",
	"Delta",
	"epsilon",
	"varepsilon",
	"zeta",
	"eta",
	"theta",
	"vartheta",
	"Theta",
	"iota",
	"kappa",
	"lambda",
	"Lambda",
	"mu",
	"nu",
	"xi",
	"omicron",
	"pi",
	"rho",
	"varrho",
	"sigma",
	"Sigma",
	"tau",
	"upsilon",
	"Upsilon",
	"phi",
	"varphi",
	"Phi",
	"chi",
	"psi",
	"omega",
	"Omega",
	"parallel",
	"perp",
	"partial",
	"nabla",
	"hbar",
	"ell",
	"infty",
	"oplus",
	"ominus",
	"otimes",
	"oslash",
	"square",
	"star",
	"dagger",
	"vee",
	"wedge",
	"subseteq",
	"subset",
	"supseteq",
	"supset",
	"emptyset",
	"exists",
	"nexists",
	"forall",
	"implies",
	"impliedby",
	"iff",
	"setminus",
	"neg",
	"lor",
	"land",
	"bigcup",
	"bigcap",
	"cdot",
	"times",
	"simeq",
	"approx",
	"leq",
	"geq",
	"neq",
	"gg",
	"ll",
	"equiv",
	"sim",
	"propto",
	"rightarrow",
	"leftarrow",
	"Rightarrow",
	"Leftarrow",
	"leftrightarrow",
	"to",
	"top",
	"mapsto",
	"cap",
	"cup",
	"in",
	"sum",
	"prod",
	"exp",
	"ln",
	"log",
	"det",
	"dots",
	"vdots",
	"ddots",
	"pm",
	"mp",
	"int",
	"iint",
	"iiint",
	"oint",
	"dot",
	"ddot",
	"hat",
	"bar",
	"tilde",
	"vec",
	"underline",
	"overline",
	"mathbf",
	"mathcal",
	"mathrm",
	"mathbb",
}

local GREEK =
	"(?:alpha|beta|gamma|Gamma|delta|Delta|epsilon|varepsilon|zeta|eta|theta|vartheta|Theta|iota|kappa|lambda|Lambda|mu|nu|xi|omicron|pi|rho|varrho|sigma|Sigma|tau|upsilon|Upsilon|phi|varphi|Phi|chi|psi|omega|Omega)"
local SYMBOL =
	"(?:parallel|perp|partial|nabla|hbar|ell|infty|oplus|ominus|otimes|oslash|square|star|dagger|vee|wedge|subseteq|subset|supseteq|supset|emptyset|exists|nexists|forall|implies|impliedby|iff|setminus|neg|lor|land|bigcup|bigcap|cdot|times|simeq|approx)"
local MORE_SYMBOLS =
	"(?:leq|geq|neq|gg|ll|equiv|sim|propto|rightarrow|leftarrow|Rightarrow|Leftarrow|leftrightarrow|to|top|mapsto|cap|cup|in|sum|prod|exp|ln|log|det|dots|vdots|ddots|pm|mp|int|iint|iiint|oint)"
local ACCENT = "(?:dot|ddot|hat|bar|tilde|vec|underline|overline|mathbf|mathcal|mathrm|mathbb)"

-- Helper: extract the delimiter for pmat/bmat/.../Vmat.
local function mat_delim(typ)
	if typ == "pmat" then
		return "("
	elseif typ == "bmat" then
		return "["
	elseif typ == "Bmat" then
		return "{"
	elseif typ == "vmat" then
		return "|"
	else
		return "||"
	end
end

-- ============================================================
return {

	-- ----------------------------------------------------------
	-- Math mode
	-- ----------------------------------------------------------
	s({ trig = "mk", snippetType = "autosnippet", condition = in_text }, { t("$"), i(0), t("$") }),

	s({ trig = "mk", snippetType = "autosnippet", condition = in_math }, { t("\\("), i(0), t("\\)") }),

	s({ trig = "dm", snippetType = "autosnippet", condition = in_text, wordTrig = true }, fmta("$\n<>\n$", { i(0) })),

	-- Regex: (\S\s*)dm → capture \n$ \n $0 \n $
	s(
		{
			trig = "(%S%s*)dm",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_text,
			wordTrig = true,
			priority = 1,
		},
		fmta("<>\n$\n<>\n$", {
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			i(0),
		})
	),

	-- beg — multi-line
	s(
		{ trig = "([^\\%w])beg", trigEngine = "ecma", snippetType = "autosnippet", condition = in_math },
		fmta("<><>(\n<>\n)", {
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			i(0),
			i(1),
		})
	),

	-- beg — inline (note the missing "(" in the previous version is now fixed)
	s(
		{
			trig = "([^\\]%w)beg",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("<><>( <> )", {
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			i(0),
			i(1),
		})
	),

	-- ----------------------------------------------------------
	-- Dashes
	-- ----------------------------------------------------------
	s({ trig = "--", snippetType = "autosnippet", condition = in_text }, { t("–") }),
	s({ trig = "–-", snippetType = "autosnippet", condition = in_text }, { t("—") }),
	s({ trig = "—-", snippetType = "autosnippet", condition = in_text }, { t("---") }),

	-- ----------------------------------------------------------
	-- Greek letters
	-- ----------------------------------------------------------
	s({ trig = "@a", snippetType = "autosnippet", condition = in_math }, { t("alpha") }),
	s({ trig = "@b", snippetType = "autosnippet", condition = in_math }, { t("beta") }),
	s({ trig = "@g", snippetType = "autosnippet", condition = in_math }, { t("gamma") }),
	s({ trig = "@G", snippetType = "autosnippet", condition = in_math }, { t("Gamma") }),
	s({ trig = "@d", snippetType = "autosnippet", condition = in_math }, { t("delta") }),
	s({ trig = "@D", snippetType = "autosnippet", condition = in_math }, { t("Delta") }),
	s({ trig = "@e", snippetType = "autosnippet", condition = in_math }, { t("epsilon") }),
	s({ trig = ":e", snippetType = "autosnippet", condition = in_math }, { t("epsilon.alt") }),
	s({ trig = "@z", snippetType = "autosnippet", condition = in_math }, { t("zeta") }),
	s({ trig = "@t", snippetType = "autosnippet", condition = in_math }, { t("theta") }),
	s({ trig = "@T", snippetType = "autosnippet", condition = in_math }, { t("Theta") }),
	s({ trig = ":t", snippetType = "autosnippet", condition = in_math }, { t("theta.alt") }),
	s({ trig = "@i", snippetType = "autosnippet", condition = in_math }, { t("iota") }),
	s({ trig = "@k", snippetType = "autosnippet", condition = in_math }, { t("kappa") }),
	s({ trig = "@l", snippetType = "autosnippet", condition = in_math }, { t("lambda") }),
	s({ trig = "@L", snippetType = "autosnippet", condition = in_math }, { t("Lambda") }),
	s({ trig = "@s", snippetType = "autosnippet", condition = in_math }, { t("sigma") }),
	s({ trig = "@S", snippetType = "autosnippet", condition = in_math }, { t("Sigma") }),
	s({ trig = "@u", snippetType = "autosnippet", condition = in_math }, { t("upsilon") }),
	s({ trig = "@U", snippetType = "autosnippet", condition = in_math }, { t("Upsilon") }),
	s({ trig = "@o", snippetType = "autosnippet", condition = in_math }, { t("omega") }),
	s({ trig = "@O", snippetType = "autosnippet", condition = in_math }, { t("Omega") }),
	s({ trig = "ome", snippetType = "autosnippet", condition = in_math }, { t("omega") }),
	s({ trig = "Ome", snippetType = "autosnippet", condition = in_math }, { t("Omega") }),

	-- ----------------------------------------------------------
	-- Text environment
	-- ----------------------------------------------------------
	s(
		{ trig = '\\n%s*\\"', trigEngine = "ecma", snippetType = "autosnippet", condition = in_math, wordTrig = false },
		fmta('\n"<> " <>', { i(0), i(1) })
	),

	s(
		{ trig = "text", snippetType = "autosnippet", condition = in_math, priority = -1 },
		{ t('"'), i(0), t('"'), i(1) }
	),

	s({ trig = '"', snippetType = "autosnippet", condition = in_math, priority = -1 }, { t('"'), i(0), t('"'), i(1) }),

	-- ----------------------------------------------------------
	-- Basic operations
	-- ----------------------------------------------------------
	s({ trig = "sr", snippetType = "autosnippet", condition = in_math }, { t("^2") }),
	s({ trig = "cb", snippetType = "autosnippet", condition = in_math }, { t("^3") }),
	s({ trig = "rd", snippetType = "autosnippet", condition = in_math }, { t("^("), i(0), t(")"), i(1) }),
	s({ trig = "_", snippetType = "autosnippet", condition = in_math }, { t("_("), i(0), t(")"), i(1) }),
	s({ trig = "sts", snippetType = "autosnippet", condition = in_math }, { t('_"'), i(0), t('"') }),
	s({ trig = "sq", snippetType = "autosnippet", condition = in_math }, { t("sqrt("), i(0), t(")"), i(1) }),
	s(
		{ trig = "(%d)rt", trigEngine = "ecma", snippetType = "autosnippet", condition = in_math },
		fmta("root(<>, <>)<>", {
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			i(0),
			i(1),
		})
	),
	s(
		{ trig = "//", snippetType = "autosnippet", condition = in_math },
		{ t("frac("), i(0), t(", "), i(1), t(")"), i(2) }
	),
	s({ trig = "ee", snippetType = "autosnippet", condition = in_math }, { t("e^("), i(0), t(")"), i(1) }),
	s({ trig = "invs", snippetType = "autosnippet", condition = in_math }, { t("^(-1)") }),

	s(
		{
			trig = "([^\\])(exp|log|ln)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		f(function(_, parent)
			return (parent.captures[1] or "") .. (parent.captures[2] or "")
		end, {})
	),

	s({ trig = "conj", snippetType = "autosnippet", condition = in_math }, { t("^*") }),
	s({ trig = "Re", snippetType = "autosnippet", condition = in_math }, { t('op("Re")') }),
	s({ trig = "Im", snippetType = "autosnippet", condition = in_math }, { t('op("Im")') }),
	s({ trig = "bf", snippetType = "autosnippet", condition = in_math }, { t("bold("), i(0), t(")") }),
	s({ trig = "rm", snippetType = "autosnippet", condition = in_math }, { t("upright("), i(0), t(")"), i(1) }),

	-- ----------------------------------------------------------
	-- Linear algebra
	-- ----------------------------------------------------------
	s(
		{
			trig = "([^\\])(det)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		f(function(_, parent)
			return (parent.captures[1] or "") .. (parent.captures[2] or "")
		end, {})
	),

	s({ trig = "trace", snippetType = "autosnippet", condition = in_math }, { t('op("Tr")') }),

	-- ----------------------------------------------------------
	-- Accents on letters
	-- ----------------------------------------------------------
	s(
		{
			trig = "([a-zA-Z])hat",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("hat(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z])bar",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("macron(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z])dot",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = -1,
		},
		fmta("dot(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z])ddot",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = 1,
		},
		fmta("dot.double(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z])tilde",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("tilde(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z])und",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("underline(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z])vec",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("arrow(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z]),\\.",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("bold(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "([a-zA-Z])\\.,",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("bold(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\" .. GREEK .. ",\\.",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("bold(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\" .. GREEK .. "\\.,",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("bold(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	-- pmod
	s({ trig = "pmod", snippetType = "autosnippet", condition = in_math }, { t("mod("), i(1, "n"), t(")"), i(2) }),

	-- Auto letter subscript / space after macros
	s(
		{
			trig = "([\\]?)([A-Za-z]+)(%d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = -1,
		},
		f(function(_, parent)
			local isMacro = parent.captures[1] == "\\"
			local digit = parent.captures[3]
			local var = parent.captures[2]
			if not isMacro then
				return var .. "_(" .. digit .. ")"
			end
			if var:match("^" .. GREEK .. "$") then
				return var .. "_(" .. digit .. ")"
			else
				return var .. " " .. digit
			end
		end, {})
	),

	s(
		{
			trig = "(\\\\" .. GREEK .. "|[A-Za-z])_((\\d+))(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = -1,
		},
		f(function(_, parent)
			return (parent.captures[1] or "") .. "_(" .. (parent.captures[2] or "") .. (parent.captures[3] or "") .. ")"
		end, {})
	),

	s(
		{
			trig = "\\\\(" .. ACCENT .. ")\\(((\\\\" .. GREEK .. "|[A-Za-z]))\\)(?:_\\((\\d+)\\))?(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = -1,
		},
		f(function(_, parent)
			local a = parent.captures[1] or ""
			local l = parent.captures[2] or ""
			local s2 = parent.captures[3] or ""
			local d = parent.captures[4] or ""
			return a .. "(" .. l .. ")_(" .. s2 .. d .. ")"
		end, {})
	),

	s(
		{
			trig = "\\\\("
				.. ACCENT
				.. ")\\(\\\\("
				.. ACCENT
				.. ")\\(((\\\\"
				.. GREEK
				.. "|[A-Za-z]))\\)\\)(?:_\\((\\d+)\\))?(\\d)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = -1,
		},
		f(function(_, parent)
			local a1 = parent.captures[1] or ""
			local a2 = parent.captures[2] or ""
			local l = parent.captures[3] or ""
			local s2 = parent.captures[4] or ""
			local d = parent.captures[5] or ""
			return a1 .. "(" .. a2 .. "(" .. l .. "))_(" .. s2 .. d .. ")"
		end, {})
	),

	-- Subscript shortcuts
	s({ trig = "xnn", snippetType = "autosnippet", condition = in_math }, { t("x_(n)") }),
	s({ trig = "\\xii", snippetType = "autosnippet", condition = in_math, priority = 1 }, { t("x_(i)") }),
	s({ trig = "xjj", snippetType = "autosnippet", condition = in_math }, { t("x_(j)") }),
	s({ trig = "xp1", snippetType = "autosnippet", condition = in_math }, { t("x_(n+1)") }),
	s({ trig = "ynn", snippetType = "autosnippet", condition = in_math }, { t("y_(n)") }),
	s({ trig = "yii", snippetType = "autosnippet", condition = in_math }, { t("y_(i)") }),
	s({ trig = "yjj", snippetType = "autosnippet", condition = in_math }, { t("y_(j)") }),

	-- ----------------------------------------------------------
	-- Symbols
	-- ----------------------------------------------------------
	s({ trig = "ooo", snippetType = "autosnippet", condition = in_math }, { t("oo") }),
	s({ trig = "prod", snippetType = "autosnippet", condition = in_math }, { t("product") }),
	s(
		{ trig = "\\sum", snippetType = "autosnippet", condition = in_math },
		{ t("sum_("), i(1, "i"), t("="), i(2, "1"), t(")^("), i(3, "N"), t(") "), i(4) }
	),
	s(
		{ trig = "\\prod", snippetType = "autosnippet", condition = in_math },
		{ t("product_("), i(1, "i"), t("="), i(2, "1"), t(")^("), i(3, "N"), t(") "), i(4) }
	),
	s(
		{ trig = "lim", snippetType = "autosnippet", condition = in_math },
		{ t("lim_("), i(1, "n"), t(" -> "), i(2, "oo"), t(") "), i(3) }
	),
	s({ trig = "+-", snippetType = "autosnippet", condition = in_math }, { t("plus.minus") }),
	s({ trig = "-+", snippetType = "autosnippet", condition = in_math }, { t("minus.plus") }),
	s({ trig = "...", snippetType = "autosnippet", condition = in_math }, { t("dots") }),
	s({ trig = "xx", snippetType = "autosnippet", condition = in_math }, { t("times") }),
	s({ trig = "**", snippetType = "autosnippet", condition = in_math }, { t("dot") }),
	s({ trig = "para", snippetType = "autosnippet", condition = in_math }, { t("parallel") }),
	s({ trig = "deg", snippetType = "autosnippet", condition = in_math }, { t("degree") }),

	s({ trig = "integ", snippetType = "autosnippet", condition = in_math }, { t("integral") }),
	s({ trig = "integc", snippetType = "autosnippet", condition = in_math }, { t("integral.cont") }),
	s({ trig = "integd", snippetType = "autosnippet", condition = in_math }, { t("integral.double") }),
	s({ trig = "integdd", snippetType = "autosnippet", condition = in_math }, { t("integral.triple") }),
	s({ trig = "bb", snippetType = "autosnippet", condition = in_math }, { t("bb("), i(0), t(")"), i(1) }),
	s({ trig = "cal", snippetType = "autosnippet", condition = in_math }, { t("cal("), i(0), t(")"), i(1) }),

	s({ trig = "===", snippetType = "autosnippet", condition = in_math }, { t("equiv") }),
	s({ trig = "!=", snippetType = "autosnippet", condition = in_math }, { t("neq") }),
	s({ trig = ">=", snippetType = "autosnippet", condition = in_math }, { t("gt.eq") }),
	s({ trig = "<=", snippetType = "autosnippet", condition = in_math }, { t("lt.eq") }),
	s({ trig = ">>", snippetType = "autosnippet", condition = in_math }, { t("gt.double") }),
	s({ trig = "<<", snippetType = "autosnippet", condition = in_math }, { t("lt.double") }),
	s({ trig = "simm", snippetType = "autosnippet", condition = in_math }, { t("tilde.op") }),
	s({ trig = "sim=", snippetType = "autosnippet", condition = in_math }, { t("tilde.eq") }),
	s({ trig = "prop", snippetType = "autosnippet", condition = in_math }, { t("prop") }),

	s({ trig = "<->", snippetType = "autosnippet", condition = in_math }, { t("arrow.l.r") }),
	s({ trig = "->", snippetType = "autosnippet", condition = in_math }, { t("arrow.r") }),
	s({ trig = "!>", snippetType = "autosnippet", condition = in_math }, { t("arrow.r.bar") }),
	s({ trig = "=>", snippetType = "autosnippet", condition = in_math }, { t("arrow.r.double") }),
	s({ trig = "=<", snippetType = "autosnippet", condition = in_math }, { t("arrow.l.double") }),

	s({ trig = "and", snippetType = "autosnippet", condition = in_math, wordTrig = true }, { t("sect") }),
	s({ trig = "orr", snippetType = "autosnippet", condition = in_math }, { t("union") }),
	s({ trig = "inn", snippetType = "autosnippet", condition = in_math }, { t("in") }),
	s({ trig = "notin", snippetType = "autosnippet", condition = in_math }, { t("in.not") }),
	s({ trig = "\\\\\\", snippetType = "autosnippet", condition = in_math }, { t("without") }),
	s({ trig = "sub=", snippetType = "autosnippet", condition = in_math }, { t("subset.eq") }),
	s({ trig = "sup=", snippetType = "autosnippet", condition = in_math }, { t("supset.eq") }),
	s({ trig = "eset", snippetType = "autosnippet", condition = in_math }, { t("emptyset") }),
	s(
		{ trig = "set", snippetType = "autosnippet", condition = in_math, wordTrig = true },
		{ t("{ "), i(0), t(" }"), i(1) }
	),
	s(
		{ trig = "(n?)e\\xi sts", trigEngine = "ecma", snippetType = "autosnippet", condition = in_math, priority = 1 },
		fmta("<><>exists", {
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			t(""), -- placeholder to keep positions simple
		})
	),

	s({ trig = "LL", snippetType = "autosnippet", condition = in_math }, { t("cal(L)") }),
	s({ trig = "HH", snippetType = "autosnippet", condition = in_math }, { t("cal(H)") }),
	s({ trig = "CC", snippetType = "autosnippet", condition = in_math }, { t("bb(C)") }),
	s({ trig = "RR", snippetType = "autosnippet", condition = in_math }, { t("bb(R)") }),
	s({ trig = "ZZ", snippetType = "autosnippet", condition = in_math }, { t("bb(Z)") }),
	s({ trig = "NN", snippetType = "autosnippet", condition = in_math }, { t("bb(N)") }),
	s({ trig = "QQ", snippetType = "autosnippet", condition = in_math }, { t("bb(Q)") }),

	-- Greek accents
	s(
		{
			trig = "\\\\(" .. GREEK .. ") tilde",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("tilde(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\(" .. GREEK .. ") und",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("underline(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\(" .. GREEK .. ") hat",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("hat(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\(" .. GREEK .. ") dot",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("dot(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\(" .. GREEK .. ") bar",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("macron(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\(" .. GREEK .. ") vec",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("arrow(<>)", { f(function(_, parent)
			return parent.captures[1] or ""
		end, {}) })
	),

	s(
		{
			trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") sr",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("<><>^(2)", {
			t(""),
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
		})
	),

	-- (The two above are simpler as plain function nodes — let's rewrite the three Greek+suffix ones:)

	s(
		{
			trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") cb",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		f(function(_, parent)
			return (parent.captures[1] or "") .. "^(3)"
		end, {})
	),

	s(
		{
			trig = "\\\\(" .. GREEK .. "|" .. SYMBOL .. ") rd",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta("<><>^(<>)<>", {
			t(""),
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			i(0),
			i(1),
		})
	),

	-- ----------------------------------------------------------
	-- Derivatives and integrals
	-- ----------------------------------------------------------
	s(
		{ trig = "par", snippetType = "autosnippet", condition = in_math },
		{ t("frac( diff "), i(1, "y"), t(", diff "), i(2, "x"), t(" ) "), i(3) }
	),

	s(
		{ trig = "par([0-9])", trigEngine = "ecma", snippetType = "autosnippet", condition = in_math },
		fmta("frac( diff^<> <>, diff <>^<> ) <>", {
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			i(1, "y"),
			i(2, "x"),
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			i(3),
		})
	),

	s({ trig = "parn", snippetType = "autosnippet", condition = in_math, priority = 1 }, {
		t("frac( diff^("),
		i(1, "n"),
		t(") "),
		i(2, "y"),
		t(", diff "),
		i(3, "x"),
		t("^("),
		i(1, "n"),
		t(") ) "),
		i(4),
	}),

	s(
		{ trig = "pa([A-Za-z])([A-Za-z])", trigEngine = "ecma", snippetType = "snippet", condition = in_math },
		fmta("frac( diff <>, diff <> ) ", {
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
			f(function(_, parent)
				return parent.captures[2] or ""
			end, {}),
		})
	),

	s({ trig = "ddt", snippetType = "autosnippet", condition = in_math }, { t("frac(d, d t) ") }),

	s(
		{ trig = "([^\\])int", trigEngine = "ecma", snippetType = "autosnippet", condition = in_math, priority = -1 },
		f(function(_, parent)
			return (parent.captures[1] or "") .. "integral"
		end, {})
	),

	s(
		{ trig = "\\int", snippetType = "autosnippet", condition = in_math },
		{ t("integral "), i(0), t(" , dif "), i(1, "x"), t(" "), i(2) }
	),

	s(
		{ trig = "dint", snippetType = "autosnippet", condition = in_math },
		{ t("integral_("), i(1, "0"), t(")^("), i(2, "1"), t(") "), i(3), t(" , dif "), i(4, "x"), t(" "), i(5) }
	),

	s({ trig = "oint", snippetType = "autosnippet", condition = in_math }, { t("integral.cont") }),
	s({ trig = "iint", snippetType = "autosnippet", condition = in_math }, { t("integral.double") }),
	s({ trig = "iiint", snippetType = "autosnippet", condition = in_math }, { t("integral.triple") }),

	s(
		{ trig = "oinf", snippetType = "autosnippet", condition = in_math },
		{ t("integral_(0)^(oo) "), i(0), t(" , dif "), i(1, "x"), t(" "), i(2) }
	),

	s(
		{ trig = "infi", snippetType = "autosnippet", condition = in_math },
		{ t("integral_(-oo)^(oo) "), i(0), t(" , dif "), i(1, "x"), t(" "), i(2) }
	),

	-- Trigonometry
	s(
		{
			trig = "(arccsc|arcsec|arccot)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			priority = 1,
		},
		fmta('op("<><>")', {
			t(""), -- intentional empty first slot for clarity
			f(function(_, parent)
				return parent.captures[1] or ""
			end, {}),
		})
	),

	-- ----------------------------------------------------------
	-- Visual operations
	-- ----------------------------------------------------------
	s(
		{ trig = "U", snippetType = "snippet", condition = visual },
		{ t("underbrace("), i(1, "VISUAL"), t(", "), i(0), t(")") }
	),
	s(
		{ trig = "O", snippetType = "snippet", condition = visual },
		{ t("overbrace("), i(1, "VISUAL"), t(", "), i(0), t(")") }
	),
	s(
		{ trig = "B", snippetType = "snippet", condition = visual },
		{ t("underset("), i(1, "VISUAL"), t(", "), i(0), t(")") }
	),
	s({ trig = "C", snippetType = "snippet", condition = visual }, { t("cancel("), i(1, "VISUAL"), t(")") }),
	s(
		{ trig = "K", snippetType = "snippet", condition = visual },
		{ t("cancel("), i(1, "VISUAL"), t(")^("), i(0), t(")") }
	),
	s({ trig = "S", snippetType = "snippet", condition = visual }, { t("sqrt("), i(1, "VISUAL"), t(")") }),

	-- ----------------------------------------------------------
	-- Physics
	-- ----------------------------------------------------------
	s({ trig = "kbt", snippetType = "autosnippet", condition = in_math }, { t("k_B T") }),
	s({ trig = "msun", snippetType = "autosnippet", condition = in_math }, { t("M_odot") }),

	-- ----------------------------------------------------------
	-- Quantum mechanics
	-- ----------------------------------------------------------
	s({ trig = "dag", snippetType = "autosnippet", condition = in_math }, { t("^dagger") }),
	s({ trig = "o+", snippetType = "autosnippet", condition = in_math }, { t("oplus") }),
	s({ trig = "ox", snippetType = "autosnippet", condition = in_math, wordTrig = true }, { t("otimes") }),
	s({ trig = "bra", snippetType = "autosnippet", condition = in_math }, { t("bra("), i(0), t(") "), i(1) }),
	s({ trig = "ket", snippetType = "autosnippet", condition = in_math }, { t("ket("), i(0), t(") "), i(1) }),
	s(
		{ trig = "brk", snippetType = "autosnippet", condition = in_math },
		{ t("braket("), i(0), t(", "), i(1), t(") "), i(2) }
	),
	s(
		{ trig = "outer", snippetType = "autosnippet", condition = in_math },
		{ t("ket("), i(1, "psi"), t(") bra("), i(1, "psi"), t(") "), i(2) }
	),

	-- ----------------------------------------------------------
	-- Chemistry
	-- ----------------------------------------------------------
	s({ trig = "pu", snippetType = "autosnippet", condition = in_math }, { t("pu("), i(0), t(")") }),
	s({ trig = "cee", snippetType = "autosnippet", condition = in_math }, { t("ce("), i(0), t(")") }),
	s({ trig = "he4", snippetType = "autosnippet", condition = in_math }, { t('""^4_2 He') }),
	s({ trig = "he3", snippetType = "autosnippet", condition = in_math }, { t('""^3_2 He') }),
	s(
		{ trig = "iso", snippetType = "autosnippet", condition = in_math },
		{ t('""^('), i(1, "4"), t(")_("), i(2, "2"), t(")"), i(3, "He") }
	),

	-- ----------------------------------------------------------
	-- Environments — matrices (multi-line, autosnippet)
	-- ----------------------------------------------------------
	s(
		{
			trig = "([pbBvV]mat)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		fmta('mat(delim: "<>",\n<>\n)', {
			f(function(_, parent)
				return mat_delim(parent.captures[1] or "")
			end, {}),
			i(0),
		})
	),

	s(
		{
			trig = "(matrix|cases|align|array)",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
		},
		d(1, function(_, parent)
			local typ = parent.captures[1] or ""
			if typ == "matrix" or typ == "array" then
				return sn(nil, fmta("mat(delim: #none,\n<>\n)", { i(1) }))
			elseif typ == "cases" then
				return sn(nil, fmta("cases(\n<>\n)", { i(1) }))
			else
				return sn(nil, { i(1) })
			end
		end, {})
	),

	-- Environments — matrices (single-line, manual)
	s(
		{ trig = "([pbBvV]mat)", trigEngine = "ecma", snippetType = "snippet", condition = in_math, wordTrig = false },
		fmta('mat(delim: "<>", <>)', {
			f(function(_, parent)
				return mat_delim(parent.captures[1] or "")
			end, {}),
			i(0),
		})
	),

	s(
		{
			trig = "(matrix|cases|align|array)",
			trigEngine = "ecma",
			snippetType = "snippet",
			condition = in_math,
			wordTrig = false,
		},
		d(1, function(_, parent)
			local typ = parent.captures[1] or ""
			if typ == "matrix" or typ == "array" then
				return sn(nil, fmta("mat(delim: #none, <>)", { i(1) }))
			elseif typ == "cases" then
				return sn(nil, fmta("cases(<>)", { i(1) }))
			else
				return sn(nil, { i(1) })
			end
		end, {})
	),

	-- ----------------------------------------------------------
	-- Brackets
	-- ----------------------------------------------------------
	s(
		{ trig = "avg", snippetType = "autosnippet", condition = in_math },
		{ t("angle.l "), i(0), t(" angle.r "), i(1) }
	),
	s(
		{ trig = "norm", snippetType = "autosnippet", condition = in_math, priority = 1 },
		{ t("abs("), i(0), t(")"), i(1) }
	),
	s(
		{ trig = "Norm", snippetType = "autosnippet", condition = in_math, priority = 1 },
		{ t("norm("), i(0), t(")"), i(1) }
	),
	s({ trig = "ceil", snippetType = "autosnippet", condition = in_math }, { t("ceil("), i(0), t(")"), i(1) }),
	s({ trig = "floor", snippetType = "autosnippet", condition = in_math }, { t("floor("), i(0), t(")"), i(1) }),
	s({ trig = "mod", snippetType = "autosnippet", condition = in_math }, { t("|"), i(0), t("|"), i(1) }),

	s({ trig = "(", snippetType = "snippet", condition = visual }, { t("("), i(1, "VISUAL"), t(")") }),
	s({ trig = "[", snippetType = "snippet", condition = visual }, { t("["), i(1, "VISUAL"), t("]") }),
	s({ trig = "{", snippetType = "snippet", condition = visual }, { t("{"), i(1, "VISUAL"), t("}") }),

	s({ trig = "(", snippetType = "autosnippet", condition = in_math }, { t("("), i(0), t(")"), i(1) }),
	s({ trig = "{", snippetType = "autosnippet", condition = in_math }, { t("{"), i(0), t("}"), i(1) }),
	s({ trig = "[", snippetType = "autosnippet", condition = in_math }, { t("["), i(0), t("]"), i(1) }),

	s({ trig = "lr(", snippetType = "autosnippet", condition = in_math }, { t("lr(("), i(0), t("))"), i(1) }),
	s({ trig = "lr{", snippetType = "autosnippet", condition = in_math }, { t("lr({"), i(0), t("})"), i(1) }),
	s({ trig = "lr[", snippetType = "autosnippet", condition = in_math }, { t("lr(["), i(0), t("])"), i(1) }),
	s({ trig = "lr|", snippetType = "autosnippet", condition = in_math }, { t("lr(|"), i(0), t("|)"), i(1) }),
	s(
		{ trig = "lra", snippetType = "autosnippet", condition = in_math },
		{ t("lr(angle.l "), i(0), t(" angle.r)"), i(1) }
	),

	-- ----------------------------------------------------------
	-- Disable snippets while typing macros
	-- ----------------------------------------------------------
	s(
		{
			trig = "\\[A-Za-z]{2,}",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = 3,
		},
		f(function(_, parent)
			local str = parent.trigger or ""
			for _, name in ipairs(ALL_MACROS) do
				if name:sub(1, #str) == str then
					return str
				end
			end
			return ""
		end, {})
	),

	s(
		{
			trig = "\\[A-Za-z]{2,}",
			trigEngine = "ecma",
			snippetType = "autosnippet",
			condition = in_math,
			wordTrig = false,
			priority = 3,
		},
		f(function(_, parent)
			local str = parent.trigger or ""
			local trig = str:sub(2)
			for _, name in ipairs(ALL_MACROS) do
				if name:sub(1, #str) == str then
					return ""
				end
			end
			local macro = trig:sub(1, -2)
			local letter = trig:sub(-1)
			return "\\" .. macro .. " " .. letter
		end, {})
	),

	-- ----------------------------------------------------------
	-- Taylor expansion
	-- ----------------------------------------------------------
	s({ trig = "tayl", snippetType = "autosnippet", condition = in_math }, {
		i(1, "f"),
		t("("),
		i(2, "x"),
		t(" + "),
		i(3, "h"),
		t(") = "),
		i(1, "f"),
		t("("),
		i(2, "x"),
		t(") + "),
		i(1, "f"),
		t("'("),
		i(2, "x"),
		t(") "),
		i(3, "h"),
		t(" + "),
		i(1, "f"),
		t("''("),
		i(2, "x"),
		t(") frac("),
		i(3, "h"),
		t("^2, 2!) + dots "),
		i(4),
	}),

	-- ----------------------------------------------------------
	-- Identity matrix
	-- ----------------------------------------------------------
	s(
		{ trig = "iden(%d)", trigEngine = "ecma", snippetType = "autosnippet", condition = in_math },
		f(function(_, parent)
			local n = tonumber(parent.captures[1]) or 2
			local rows = {}
			for j = 1, n do
				local row = {}
				for k = 1, n do
					row[k] = (k == j) and "1" or "0"
				end
				rows[j] = table.concat(row, ", ")
			end
			return "mat(" .. table.concat(rows, "; ") .. ")"
		end, {})
	),

	-- ----------------------------------------------------------
	-- Display math in a list
	-- ----------------------------------------------------------
	s({
		trig = "(?<positive_lookbehind>(?:\\n|^)[ \\t]*>*)(?<marker>\\d+[.)]|[-*+])(?<whitespace>[ \\t]+)(?<text>.*)dm",
		trigEngine = "ecma",
		snippetType = "autosnippet",
		condition = in_text,
		priority = 2,
	}, {
		f(function(_, parent)
			local lb = parent.captures[1] or ""
			local marker = parent.captures[2] or ""
			local ws = parent.captures[3] or ""
			local text = parent.captures[4] or ""
			local indent = string.rep(" ", #marker) .. ws
			return { lb .. marker .. ws .. text, indent .. "$", indent }
		end, {}),
		i(1),
		f(function(_, parent)
			local marker = parent.captures[2] or ""
			local ws = parent.captures[3] or ""
			local indent = string.rep(" ", #marker) .. ws
			return { "", indent .. "$" }
		end, {}),
	}),
}
