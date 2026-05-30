return {
	cmd = { "verible-verilog-ls" },
	filetypes = { "verilog", "systemverilog" },
	single_file_support = true,
	root_markers = { "verible.filelist", ".git" },
	settings = {
		verible = {
			analysis = {
				ruleset = "default",
				rules_config_search = true,
			},
		},
	},
}
