return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	capabilities = {
		experimental = {
			commands = {
				commands = { "rust-analyzer.showReferences", "rust-analyzer.runSingle", "rust-analyzer.debugSingle" },
			},
			serverStatusNotification = true,
		},
	},
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
				extraArgs = { "--", "-W", "clippy::all" },
			},
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				runBuildScripts = true,
			},
			procMacro = {
				enable = true,
			},
		},
	},
}
