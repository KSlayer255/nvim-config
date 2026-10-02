-- ~/.config/nvim/lua/snippets/typst.lua
-- LuaSnip port of Obsidian LaTeX Suite snippets for Typst
--
-- Notes
--  * Regex triggers use trigEngine = "ecma" (needs jsregexp: `make install_jsregexp`).
--    They are written in ECMAScript syntax (\d \s \w ...), NOT Lua-pattern syntax (%d %s ...).
--  * LuaSnip's `wordTrig` defaults to true, which blocks a snippet when the character
--    before the trigger is [%w_]  ->  "x" .. "sr" would not expand without a space.
--    All math snippets below therefore set wordTrig = false (see make() below).
--  * mini.pairs: snippets never use `(`, `[`, `{`, `"` as autosnippet triggers anymore
--    (mini.pairs already handles those), and the few triggers that end in an opening
--    bracket (`lr(`, `lr[`, `lr{`) swallow the closing bracket mini.pairs inserted.
--  * Requires `enable_autosnippets = true` in luasnip's setup().

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta
local warned = {}

-- ============================================================
-- Helpers
-- ============================================================
-- Math-mode detection via treesitter.
-- In uben0/tree-sitter-typst, both inline ($x$) and display ($ x $) math are
-- wrapped in a node of type "math".
local function in_math()
	local bufnr = vim.api.nvim_get_current_buf()

	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "typst")
	if not ok or not parser then
		if not warned[bufnr] then
			warned[bufnr] = true
			vim.notify(
				"typst.lua: no treesitter parser for 'typst' — math snippets will not fire.\n"
					.. "Fix: :TSInstall typst   (then :edit to reload this buffer)",
				vim.log.levels.WARN
			)
		end
		return false
	end

	local ok2, trees = pcall(parser.parse, parser)
	if not ok2 or not trees or not trees[1] then
		return false
	end

	-- nvim_win_get_cursor: row 1-indexed, col 0-indexed bytes. Treesitter wants 0-indexed row.
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

-- Snippet factories -----------------------------------------
-- make(condition, trigEngine, wordTrig) -> function(trig, nodes, opts)
local function make(cond, engine, word)
	return function(trig, nodes, opts)
		local ctx = {
			trig = trig,
			snippetType = "autosnippet",
			condition = cond,
			wordTrig = word,
		}
		if engine then
			ctx.trigEngine = engine
		end
		for k, v in pairs(opts or {}) do
			ctx[k] = v
		end
		-- LuaSnip's default priority is 1000 and higher wins, so the small
		-- LaTeX-Suite-style numbers below (-1, 1, 2) are treated as offsets.
		ctx.priority = 1000 + ((opts and opts.priority) or 0)
		return s(ctx, nodes)
	end
end

local ms = make(in_math, nil, false) -- math, plain trigger
local mr = make(in_math, "ecma", false) -- math, regex trigger
local ts = make(in_text, nil, true) -- text, plain trigger
local tr = make(in_text, "ecma", false) -- text, regex trigger

-- n-th capture group of a regex trigger (empty string if absent)
local function cap(n)
	return f(function(_, parent)
		return parent.captures[n] or ""
	end, {})
end

-- "open" <cursor> "close" <exit>
local function wrap(open, close)
	return { t(open), i(1), t(close), i(0) }
end

-- Visual-selection node: inserts the selection if one was cut with
-- `cut_selection_keys`, otherwise an empty insert node.
local function selection_or_insert(idx)
	return d(idx, function(_, parent)
		local env = (parent.snippet or parent).env
		local sel = env and env.LS_SELECT_RAW
		if type(sel) == "table" and #sel > 0 then
			return sn(nil, { t(sel) })
		elseif type(sel) == "string" and sel ~= "" then
			return sn(nil, { t(sel) })
		end
		return sn(nil, { i(1) })
	end, {})
end

-- mini.pairs compatibility: when a snippet's trigger ends in an opening bracket,
-- mini.pairs has already inserted the closing one right after the cursor.
-- Extend LuaSnip's clear_region by one char so that closer is removed too.
local function eat_closer(closer)
	return function(_, _, matched_trigger)
		local cursor = vim.api.nvim_win_get_cursor(0)
		local row, col = cursor[1] - 1, cursor[2]
		local line = vim.api.nvim_get_current_line()
		local to_col = col
		if line:sub(col + 1, col + 1) == closer then
			to_col = col + 1
		end
		return {
			clear_region = {
				from = { row, col - #matched_trigger },
				to = { row, to_col },
			},
		}
	end
end

-- Typst names (regex fragments, ECMAScript syntax) ------------
local GREEK_NAMES =
	"alpha|beta|gamma|Gamma|delta|Delta|epsilon|zeta|eta|theta|Theta|iota|kappa|lambda|Lambda|mu|nu|xi|Xi|omicron|pi|Pi|rho|sigma|Sigma|tau|upsilon|Upsilon|phi|Phi|chi|psi|Psi|omega|Omega"
local GREEK = "(?:" .. GREEK_NAMES .. ")(?:\\.alt)?"
local SYMBOL = "(?:nabla|diff|ell|infinity|parallel|perp|forall|exists|emptyset|dagger|star|square)"
local ACCENT = "hat|tilde|macron|arrow|underline|overline|bold|bb|cal|upright|dot\\.double|dot"

-- Matrix delimiter lookup
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

-- Letter + accent (x hat -> hat(x)): "xhat", "xbar", ...
local function letter_accent(suffix, typst_fn, prio)
	return mr("([a-zA-Z])" .. suffix, { t(typst_fn .. "("), cap(1), t(")") }, { priority = prio })
end

-- Greek + accent ("alpha hat" -> hat(alpha))
local function greek_accent(suffix, typst_fn)
	return mr("(" .. GREEK .. ") " .. suffix, { t(typst_fn .. "("), cap(1), t(")") }, { priority = 2 })
end

-- ============================================================
return {

	-- ----------------------------------------------------------
	-- Math mode entry
	-- ----------------------------------------------------------
	ts("mk", { t("$"), i(1), t("$"), i(0) }),

	ts("dm", fmta("$\n<>\n$", { i(1) })),

	-- text before `dm` on the same line: put the display math on its own lines
	tr([[(\S)\s+dm]], fmta("<>\n$\n<>\n$", { cap(1), i(1) }), { priority = 1 }),

	-- `dm` at the end of a list item: display math nested under the item
	tr([[^([ \t]*>*)(\d+[.)]|[-*+])([ \t]+)(.*\s|)dm]], {
		f(function(_, parent)
			local lb = parent.captures[1] or ""
			local marker = parent.captures[2] or ""
			local ws = parent.captures[3] or ""
			local text = (parent.captures[4] or ""):gsub("%s+$", "")
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
		i(0),
	}, { priority = 2 }),

	-- beg: multi-line when alone at the start of a line ...
	mr([[^(\s*)beg]], {
		f(function(_, parent)
			local ind = parent.captures[1] or ""
			return { ind .. "(", ind .. "  " }
		end, {}),
		i(1),
		f(function(_, parent)
			local ind = parent.captures[1] or ""
			return { "", ind .. ")" }
		end, {}),
		i(0),
	}, { priority = 2 }),

	-- ... inline otherwise
	mr([[(\s|[^\w\s])beg]], { cap(1), t("( "), i(1), t(" )"), i(0) }),

	-- ----------------------------------------------------------
	-- Dashes (text mode)
	-- ----------------------------------------------------------
	make(in_text, nil, false)("--", { t("–") }),
	make(in_text, nil, false)("–-", { t("—") }),
	make(in_text, nil, false)("—-", { t("---") }),

	-- ----------------------------------------------------------
	-- Text inside math
	-- (the `"` autosnippet was removed: mini.pairs already closes quotes)
	-- ----------------------------------------------------------
	ms("text", wrap('"', '"'), { priority = -1 }),

	-- ----------------------------------------------------------
	-- Basic operations
	-- ----------------------------------------------------------
	ms("sr", { t("^2") }),
	ms("cb", { t("^3") }),
	ms("rd", wrap("^(", ")")),
	ms("_", wrap("_(", ")")),
	ms("sts", wrap('_"', '"')),
	ms("sq", wrap("sqrt(", ")")),
	mr([[(\d)rt]], { t("root("), cap(1), t(", "), i(1), t(")"), i(0) }),
	ms("//", { t("frac("), i(1), t(", "), i(2), t(")"), i(0) }),
	ms("ee", wrap("e^(", ")")),
	ms("invs", { t("^(-1)") }),

	ms("conj", { t("^*") }),
	ms("Re", { t('op("Re")') }),
	ms("Im", { t('op("Im")') }),
	ms("bf", wrap("bold(", ")")),
	ms("rm", wrap("upright(", ")")),

	-- ----------------------------------------------------------
	-- Linear algebra
	-- ----------------------------------------------------------
	ms("trace", { t('op("Tr")') }),

	-- ----------------------------------------------------------
	-- Accents on letters
	-- ----------------------------------------------------------
	letter_accent("hat", "hat"),
	letter_accent("bar", "macron"),
	letter_accent("dot", "dot", -1),
	letter_accent("ddot", "dot.double", 1),
	letter_accent("tilde", "tilde"),
	letter_accent("und", "underline"),
	letter_accent("vec", "arrow"),

	-- bold letters: x,.  /  x.,
	mr([[([a-zA-Z]),\.]], { t("bold("), cap(1), t(")") }),
	mr([[([a-zA-Z])\.,]], { t("bold("), cap(1), t(")") }),
	-- bold Greek letters: alpha,.  /  alpha.,
	mr("(" .. GREEK .. [[),\.]], { t("bold("), cap(1), t(")") }, { priority = 2 }),
	mr("(" .. GREEK .. [[)\.,]], { t("bold("), cap(1), t(")") }, { priority = 2 }),

	-- pmod
	ms("pmod", { t("mod("), i(1, "n"), t(")"), i(0) }, { priority = 2 }),

	-- Auto letter subscript: x2 -> x_2   (single letters only, not "log2", "alpha2")
	mr([[(^|[^A-Za-z_])([A-Za-z])(\d)]], { cap(1), cap(2), t("_"), cap(3) }, { priority = -1 }),

	-- Extend a subscript: x_12 -> x_(12)
	mr([[([A-Za-z])_(\d)(\d)]], { cap(1), t("_("), cap(2), cap(3), t(")") }, { priority = -1 }),
	mr([[([A-Za-z])_\((\d+)\)(\d)]], { cap(1), t("_("), cap(2), cap(3), t(")") }, { priority = -1 }),

	-- Accent(letter) + digit: hat(x)2 -> hat(x)_2
	mr(
		"(" .. ACCENT .. [[)\(([A-Za-z]|]] .. GREEK .. [[)\)(\d)]],
		{ cap(1), t("("), cap(2), t(")_"), cap(3) },
		{ priority = -1 }
	),

	-- Subscript shortcuts
	ms("xnn", { t("x_(n)") }),
	ms("xii", { t("x_(i)") }, { priority = 1 }),
	ms("xjj", { t("x_(j)") }),
	ms("xp1", { t("x_(n+1)") }),
	ms("ynn", { t("y_(n)") }),
	ms("yii", { t("y_(i)") }),
	ms("yjj", { t("y_(j)") }),

	-- ----------------------------------------------------------
	-- Symbols
	-- ----------------------------------------------------------
	ms("ooo", { t("oo") }),
	ms("sum", { t("sum_("), i(1, "i"), t("="), i(2, "1"), t(")^("), i(3, "N"), t(") "), i(4) }),
	ms("prod", { t("product_("), i(1, "i"), t("="), i(2, "1"), t(")^("), i(3, "N"), t(") "), i(4) }),
	ms("lim", { t("lim_("), i(1, "n"), t(" -> "), i(2, "oo"), t(") "), i(3) }),
	ms("+-", { t("plus.minus") }),
	ms("-+", { t("minus.plus") }),
	ms("...", { t("dots") }),
	ms("xx", { t("times") }),
	ms("**", { t("dot") }),
	ms("para", { t("parallel") }),
	ms("deg", { t("degree") }),

	ms("integ", { t("integral") }),
	ms("integc", { t("integral.cont") }),
	ms("integd", { t("integral.double") }),
	ms("integdd", { t("integral.triple") }),
	ms("bb", wrap("bb(", ")")),
	ms("cal", wrap("cal(", ")")),

	ms("===", { t("equiv") }),
	ms("!=", { t("neq") }),
	ms(">=", { t("gt.eq") }),
	ms("<=", { t("lt.eq") }),
	ms(">>", { t("gt.double") }),
	ms("<<", { t("lt.double") }),
	ms("simm", { t("tilde.op") }),
	ms("sim=", { t("tilde.eq") }),
	ms("prop", { t("prop") }),

	ms("<->", { t("arrow.l.r") }, { priority = 2 }),
	ms("->", { t("arrow.r") }),
	ms("!>", { t("arrow.r.bar") }),
	ms("=>", { t("arrow.r.double") }),
	ms("=<", { t("arrow.l.double") }),

	ms("and", { t("sect") }, { wordTrig = true }),
	ms("orr", { t("union") }),
	ms("inn", { t("in") }),
	ms("notin", { t("in.not") }),
	ms("\\\\\\", { t("without") }),
	ms("sub=", { t("subset.eq") }),
	ms("sup=", { t("supset.eq") }),
	ms("eset", { t("emptyset") }),
	ms("set", { t("{ "), i(1), t(" }"), i(0) }, { wordTrig = true }),

	ms("LL", { t("cal(L)") }),
	ms("HH", { t("cal(H)") }),
	ms("CC", { t("bb(C)") }),
	ms("RR", { t("bb(R)") }),
	ms("ZZ", { t("bb(Z)") }),
	ms("NN", { t("bb(N)") }),
	ms("QQ", { t("bb(Q)") }),

	-- Greek + accent ("alpha tilde" -> tilde(alpha))
	greek_accent("tilde", "tilde"),
	greek_accent("und", "underline"),
	greek_accent("hat", "hat"),
	greek_accent("dot", "dot"),
	greek_accent("bar", "macron"),
	greek_accent("vec", "arrow"),

	-- Greek / symbol + power ("alpha sr" -> alpha^(2))
	mr("(" .. GREEK .. "|" .. SYMBOL .. ") sr", { cap(1), t("^(2)") }, { priority = 2 }),
	mr("(" .. GREEK .. "|" .. SYMBOL .. ") cb", { cap(1), t("^(3)") }, { priority = 2 }),
	mr("(" .. GREEK .. "|" .. SYMBOL .. ") rd", { cap(1), t("^("), i(1), t(")"), i(0) }, { priority = 2 }),

	-- ----------------------------------------------------------
	-- Derivatives and integrals
	-- ----------------------------------------------------------
	ms("par", { t("frac( diff "), i(1, "y"), t(", diff "), i(2, "x"), t(" ) "), i(3) }),

	mr([[par(\d)]], {
		t("frac( diff^"),
		cap(1),
		t(" "),
		i(1, "y"),
		t(", diff "),
		i(2, "x"),
		t("^"),
		cap(1),
		t(" ) "),
		i(3),
	}),

	ms("parn", {
		t("frac( diff^("),
		i(1, "n"),
		t(") "),
		i(2, "y"),
		t(", diff "),
		i(3, "x"),
		t("^("),
		rep(1),
		t(") ) "),
		i(4),
	}, { priority = 1 }),

	-- manual (not auto) snippet: pa<letter><letter>  e.g. paxy
	mr(
		[[pa([A-Za-z])([A-Za-z])]],
		{ t("frac( diff "), cap(1), t(", diff "), cap(2), t(" ) "), i(0) },
		{ snippetType = "snippet" }
	),

	ms("ddt", { t("frac(d, d t) ") }),

	ms("int", { t("integral") }, { priority = -1 }),

	ms("dint", {
		t("integral_("),
		i(1, "0"),
		t(")^("),
		i(2, "1"),
		t(") "),
		i(3),
		t(" , dif "),
		i(4, "x"),
		t(" "),
		i(5),
	}),

	ms("oint", { t("integral.cont") }),
	ms("iint", { t("integral.double") }),
	ms("iiint", { t("integral.triple") }),

	ms("oinf", { t("integral_(0)^(oo) "), i(1), t(" , dif "), i(2, "x"), t(" "), i(3) }),
	ms("infi", { t("integral_(-oo)^(oo) "), i(1), t(" , dif "), i(2, "x"), t(" "), i(3) }),

	-- Trigonometry
	mr(
		[[(arccsc|arcsec|arccot)]],
		{ f(function(_, parent)
			return 'op("' .. (parent.captures[1] or "") .. '")'
		end, {}) },
		{ priority = 1 }
	),

	-- ----------------------------------------------------------
	-- Visual operations (select text, press your `cut_selection_keys`,
	-- type the trigger, expand with your expand key)
	-- ----------------------------------------------------------
	s(
		{ trig = "U", snippetType = "snippet", condition = in_math },
		{ t("underbrace("), selection_or_insert(1), t(", "), i(2), t(")"), i(0) }
	),
	s(
		{ trig = "O", snippetType = "snippet", condition = in_math },
		{ t("overbrace("), selection_or_insert(1), t(", "), i(2), t(")"), i(0) }
	),
	-- Typst has no \underset; limits(x)_(y) places y underneath x
	s(
		{ trig = "B", snippetType = "snippet", condition = in_math },
		{ t("limits("), selection_or_insert(1), t(")_("), i(2), t(")"), i(0) }
	),
	s(
		{ trig = "C", snippetType = "snippet", condition = in_math },
		{ t("cancel("), selection_or_insert(1), t(")"), i(0) }
	),
	s(
		{ trig = "K", snippetType = "snippet", condition = in_math },
		{ t("cancel("), selection_or_insert(1), t(")^("), i(2), t(")"), i(0) }
	),
	s(
		{ trig = "S", snippetType = "snippet", condition = in_math },
		{ t("sqrt("), selection_or_insert(1), t(")"), i(0) }
	),

	-- ----------------------------------------------------------
	-- Physics
	-- ----------------------------------------------------------
	ms("kbt", { t("k_B T") }),
	ms("msun", { t("M_(dot.circle)") }),

	-- ----------------------------------------------------------
	-- Quantum mechanics
	-- ----------------------------------------------------------
	ms("dag", { t("^dagger") }),
	ms("o+", { t("plus.circle") }),
	ms("ox", { t("times.circle") }, { wordTrig = true }),
	ms("bra", wrap("bra(", ") ")),
	ms("ket", wrap("ket(", ") ")),
	ms("brk", { t("braket("), i(1), t(", "), i(2), t(") "), i(0) }),
	ms("outer", { t("ket("), i(1, "psi"), t(") bra("), rep(1), t(") "), i(0) }),

	-- ----------------------------------------------------------
	-- Chemistry
	-- ----------------------------------------------------------
	ms("pu", wrap("pu(", ")")),
	ms("cee", wrap("ce(", ")")),
	ms("he4", { t('""^4_2 He') }),
	ms("he3", { t('""^3_2 He') }),
	ms("iso", { t('""^('), i(1, "4"), t(")_("), i(2, "2"), t(")"), i(3, "He") }),

	-- ----------------------------------------------------------
	-- Environments: matrices (multi-line, auto)
	-- ----------------------------------------------------------
	mr(
		[[([pbBvV]mat)]],
		fmta('mat(delim: "<>",\n<>\n)', {
			f(function(_, parent)
				return mat_delim(parent.captures[1] or "")
			end, {}),
			i(1),
		})
	),

	mr(
		[[(matrix|cases|align|array)]],
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

	-- Environments: matrices (single-line, manual)
	mr(
		[[([pbBvV]mat)]],
		fmta('mat(delim: "<>", <>)', {
			f(function(_, parent)
				return mat_delim(parent.captures[1] or "")
			end, {}),
			i(1),
		}),
		{ snippetType = "snippet" }
	),

	mr(
		[[(matrix|cases|align|array)]],
		d(1, function(_, parent)
			local typ = parent.captures[1] or ""
			if typ == "matrix" or typ == "array" then
				return sn(nil, fmta("mat(delim: #none, <>)", { i(1) }))
			elseif typ == "cases" then
				return sn(nil, fmta("cases(<>)", { i(1) }))
			else
				return sn(nil, { i(1) })
			end
		end, {}),
		{ snippetType = "snippet" }
	),

	-- ----------------------------------------------------------
	-- Brackets
	-- (the plain `(`, `[`, `{` autosnippets were removed: mini.pairs handles them)
	-- ----------------------------------------------------------
	ms("avg", { t("angle.l "), i(1), t(" angle.r "), i(0) }),
	ms("norm", wrap("abs(", ")"), { priority = 1 }),
	ms("Norm", wrap("norm(", ")"), { priority = 1 }),
	ms("ceil", wrap("ceil(", ")")),
	ms("floor", wrap("floor(", ")")),
	ms("mod", wrap("|", "|")),

	-- Visual-selection brackets (manual snippets; eat the closer mini.pairs adds)
	s(
		{ trig = "(", snippetType = "snippet", resolveExpandParams = eat_closer(")") },
		{ t("("), selection_or_insert(1), t(")"), i(0) }
	),
	s(
		{ trig = "[", snippetType = "snippet", resolveExpandParams = eat_closer("]") },
		{ t("["), selection_or_insert(1), t("]"), i(0) }
	),
	s(
		{ trig = "{", snippetType = "snippet", resolveExpandParams = eat_closer("}") },
		{ t("{"), selection_or_insert(1), t("}"), i(0) }
	),

	-- lr(...) auto-sizing delimiters. Triggers ending in `(` `[` `{` get the
	-- mini.pairs closer removed so brackets are not doubled.
	ms("lr(", { t("lr(("), i(1), t("))"), i(0) }, { resolveExpandParams = eat_closer(")") }),
	ms("lr{", { t("lr({"), i(1), t("})"), i(0) }, { resolveExpandParams = eat_closer("}") }),
	ms("lr[", { t("lr(["), i(1), t("])"), i(0) }, { resolveExpandParams = eat_closer("]") }),
	ms("lr|", { t("lr(|"), i(1), t("|)"), i(0) }),
	ms("lra", { t("lr(angle.l "), i(1), t(" angle.r)"), i(0) }),

	-- ----------------------------------------------------------
	-- Taylor expansion
	-- ----------------------------------------------------------
	ms("tayl", {
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
		t(") "),
		rep(3),
		t(" + "),
		rep(1),
		t("''("),
		rep(2),
		t(") frac("),
		rep(3),
		t("^2, 2!) + dots "),
		i(4),
	}),

	-- ----------------------------------------------------------
	-- Identity matrix: iden3 -> mat(1, 0, 0; 0, 1, 0; 0, 0, 1)
	-- ----------------------------------------------------------
	mr(
		[[iden(\d)]],
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
}
