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
		opts = function()
			local tools = {
				-- Non-LSP tools only (formatters/linters)
				"stylua",
				"latexindent",
				"selene",
				"ruff",
				"prettypst",
				"mdformat",
			}
			if vim.fn.executable("termux-setup-storage") == 1 then
				-- Installed via Termux pkg/cargo instead
				local skip = { stylua = true, latexindent = true, selene = true }
				tools = vim.tbl_filter(function(t)
					return not skip[t]
				end, tools)
			end
			return {
				ensure_installed = tools,
				run_on_start = true,
			}
		end,
	},
}
