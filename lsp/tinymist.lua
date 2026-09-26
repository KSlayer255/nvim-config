return {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	root_markers = { "typst.toml", ".git" },
	settings = {
		exportPdf = "onSave",
		outputPath = "$root/build/$dir/$name",
		-- You can add more tinymist options here
	},
}
