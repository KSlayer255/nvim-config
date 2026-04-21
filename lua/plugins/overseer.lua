return {
	{
		"stevearc/overseer.nvim",
		cmd = {
			"OverseerOpen",
			"OverseerClose",
			"OverseerToggle",
			"OverseerSaveBundle",
			"OverseerLoadBundle",
			"OverseerDeleteBundle",
			"OverseerRunCmd",
			"OverseerRun",
			"OverseerInfo",
			"OverseerBuild",
			"OverseerQuickAction",
			"OverseerTaskAction",
			"OverseerClearCache",
		},
		strategy = "terminal",
		opts = {
			dap = false,
			task_list = {
				bindings = {
					["<C-h>"] = false,
					["<C-j>"] = false,
					["<C-k>"] = false,
					["<C-l>"] = false,
				},
			},
			form = {
				win_opts = {
					winblend = 0,
				},
			},
			confirm = {
				win_opts = {
					winblend = 0,
				},
			},
			task_win = {
				win_opts = {
					winblend = 0,
				},
			},
		},
		config = function(_, opts)
			require("overseer").setup(opts)

			-- Register C build task
			require("overseer").register_template({
				name = "Build and Run C File",
				desc = "Compile C file with gcc and run it",
				condition = {
					filetype = "c",
				},
				builder = function()
					local file = vim.fn.expand("%:p")
					local output = vim.fn.expand("%:r")
					return {
						cmd = "sh",
						args = {
							"-c",
							string.format('gcc -Wall -Wextra -std=c17 "%s" -o "%s" && "%s"', file, output, output),
						},
						components = {
							{ "on_output_quickfix", open = true }, -- Parse errors into quickfix
							"on_exit_set_status",
							"default",
						},
					}
				end,
			})
			require("overseer").register_template({
				name = "Run Python File",
				desc = "Execute current Python file (auto venv detection)",
				condition = {
					filetype = "python",
				},
				builder = function()
					local file = vim.fn.expand("%:p")
					local current_dir = vim.fn.fnamemodify(file, ":h")
					-- Look for venv in current directory or parent directories
					local venv_python = vim.fs.find(
						{ "venv/bin/python", ".venv/bin/python" },
						{ upward = true, path = current_dir, type = "file" }
					)[1]
					local python_cmd = venv_python or "python3"
					return {
						cmd = python_cmd,
						args = { file },
						components = {
							{ "on_output_quickfix", open = true },
							"on_exit_set_status",
							"default",
						},
						env = {
							VIRTUAL_ENV = vim.fn.fnamemodify(python_cmd, ":h:h"),
						},
					}
				end,
			})
			require("overseer").register_template({
				name = "Build and Run Rust File",
				desc = "Compile Rust file with cargo and run it",
				condition = {
					filetype = "rust",
				},
				builder = function()
					local cargo_path = vim.fn.expand("~/.cargo/bin/cargo")
					local cargo_toml = vim.fs.find("Cargo.toml", { upward = true })[1]

					if not cargo_toml then
						return {
							cmd = "echo",
							args = { "Error: No Cargo.toml found" },
						}
					end

					local project_dir = vim.fn.fnamemodify(cargo_toml, ":h")

					return {
						cmd = "sh",
						args = {
							"-c",
							string.format('"%s" run --quiet --manifest-path "%s/Cargo.toml"', cargo_path, project_dir),
						},
						components = {
							{ "on_output_quickfix", open = true },
							"on_exit_set_status",
							"default",
						},
					}
				end,
			})
		end,
    -- stylua: ignore
    keys = {
      { "<leader>ow", "<cmd>OverseerToggle<cr>",      desc = "Task list" },
      { "<leader>oo", "<cmd>OverseerRun<cr>",         desc = "Run task" },
      { "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Action recent task" },
      { "<leader>oi", "<cmd>OverseerInfo<cr>",        desc = "Overseer Info" },
      { "<leader>ob", "<cmd>OverseerBuild<cr>",       desc = "Task builder" },
      { "<leader>ot", "<cmd>OverseerTaskAction<cr>",  desc = "Task action" },
      { "<leader>oc", "<cmd>OverseerClearCache<cr>",  desc = "Clear cache" },
      -- C-specific build keymaps
      { "<leader>bb", "<cmd>OverseerBuild<cr>", desc = "Build C File" },
      { "<leader>br", "<cmd>OverseerRun cmd=./" .. vim.fn.expand("%:r") .. "<cr>", desc = "Run C Program" },
      -- Python-specific keymaps
      { "<leader>pr", "<cmd>OverseerRun Run Python File<cr>", desc = "Run Python File" },
    },
	},
}
