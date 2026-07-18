return {
	"ibhagwan/fzf-lua",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	build = "make", -- optional for fzf-native
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({
			defaults = {
				file_ignore_patterns = {
					"build/",
					"install/",
					"devel/",
					"log/",
					".git/",
					"__pycache__/",
					"CMakeFiles/",
					"*.bag",
					"*.db",
					"*.pcap",
					"*.pyc",
				},
				preview = {
					cmd = "bat",
					args = "--style=plain --paging=never --wrap=never --line-range=1:200",
				},
			},
			files = {
				fd_opts = "--type f --hidden --exclude .git --exclude build --exclude install --exclude devel --exclude log",
			},
			grep = {
				rg_opts = "--max-columns=200 --max-filesize=10M --glob '!build/*' --glob '!install/*' --glob '!devel/*' --glob '!log/*' --glob '!*.bag' --glob '!*.db'",
				preview = {
					cmd = "bat",
					args = "--style=plain --paging=never --wrap=never --line-range=1:100",
				},
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>fg", fzf.grep, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
		vim.keymap.set("n", "<leader>fl", function()
			fzf.grep({ cwd = vim.fn.expand("%:p:h") })
		end, { desc = "Live grep in current file's directory" })
	end,
}
