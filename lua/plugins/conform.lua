return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			lua = { "stylua" },
			python = {
				"ruff_format",
				"ruff_organize_imports",
			},
			javascript = { "prettierd", "prettier", stop_after_first = true },
			tex = { "latexindent" },
			rust = { "rustfmt" },
		},
		-- Set default options
		default_format_opts = {
			lsp_format = "fallback",
		},
		-- Set up format-on-save
		format_on_save = { timeout_ms = 2000 },
		-- Customize formatters
		formatters = {
			shfmt = {
				append_args = { "-i", "2" },
			},
		},
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
