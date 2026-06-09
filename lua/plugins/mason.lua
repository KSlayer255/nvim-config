return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"lua_ls",
				"pyright",
				"texlab",
				"verible",
				"tinymist",
			},
			automatic_enable = true, -- automatically calls vim.lsp.enable() for installed servers
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				-- Non-LSP tools only (formatters/linters)
				"stylua",
				"latexindent",
				"selene",
				"ruff",
				"prettypst",
				"mdformat",
			},
			run_on_start = true,
		},
	},
}
