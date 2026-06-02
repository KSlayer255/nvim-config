return {
	"ajbucci/ipynb.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"folke/snacks.nvim", -- optional, for inline images
		"neovim/nvim-lspconfig",
		-- "nvim-tree/nvim-web-devicons", -- optional, for language icons
	},
	config = function()
		local is_win = vim.fn.has("win32") == 1
		local python_path = is_win and "C:/Python313/python.exe" or nil
		local opts = {
			-- Only documented options go here (all optional)
			kernel = {
				auto_connect = true, -- or true if you want kernel on open
				python_path = python_path,
			},
			images = {
				enabled = true, -- requires snacks.nvim
			},
			-- format = { enabled = true },  -- default true, wraps lsp formatting
		}
		require("ipynb").setup(opts)
	end,
}
