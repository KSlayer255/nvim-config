local opts = {}

if vim.fn.executable("termux-setup-storage") == 1 then
	opts.dependencies_bin = {
		tinymist = "tinymist",
		websocat = "websocat",
	}
end

return {
	"chomosuke/typst-preview.nvim",
	lazy = false,
	version = "1.*",
	opts = opts,
}
