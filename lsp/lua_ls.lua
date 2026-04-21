return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	single_file_support = true,
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			diagnostics = {
				globals = {},
			},
		},
		hint = {
			enable = true,
		},
	},
}
