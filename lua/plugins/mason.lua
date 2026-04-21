return {
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				-- Formatters
				"stylua",
				"latexindent",
				"rustfmt",
				-- Linter
				"selene",
				"chktex",
				-- LSP
				"lua_ls",
				"texlab",
				"pyright",
				"rust-analyzer",
				-- All for one
				"ruff",
			},
		},
	},
}
