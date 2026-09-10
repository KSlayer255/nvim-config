return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		if vim.fn.executable("termux-setup-storage") == 1 then
			vim.g.vimtex_view_method = "general"
			vim.g.vimtex_view_general_viewer = "termux-open"
			vim.g.vimtex_view_general_options = "@pdf"
		elseif vim.fn.has("win32") == 1 then
			vim.g.vimtex_view_method = "general"
		else
			vim.g.vimtex_view_method = "zathura"
		end
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			out_dir = "build",
			continuous = 1,
			callback = 1,
		}
	end,
}
