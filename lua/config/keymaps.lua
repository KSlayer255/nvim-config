local keymap = vim.keymap.set

-- Better up/down (arrow keys version of your existing j/k maps)
keymap({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Resize window using <ctrl> arrow keys
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Enhanced Move Lines (improved versions of your existing ones)
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

-- Quick save
keymap("n", "<C-s>", "<cmd>w<CR>")

-- Buffer navigation
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Buffer deletion (simplified without LazyVim dependencies)
keymap("n", "<leader>bd", function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.cmd("bdelete" .. bufnr)
end, { desc = "Delete Buffer" })

keymap("n", "<leader>bo", function()
	local current_buf = vim.api.nvim_get_current_buf()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if bufnr ~= current_buf and vim.api.nvim_buf_is_loaded(bufnr) then
			vim.cmd("bdelete " .. bufnr)
		end
	end
end, { desc = "Delete Other Buffers" })

keymap("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete Buffer and Window" })

keymap({ "n" }, "<leader>hh", function()
	vim.fn.setreg("/", "") -- Alternative way to clear search register
end, { desc = "Clear search register" })

-- Explorer
-- keymap('n', '<leader>pv', ':Ex<CR>') -- netrw, commented out after getting neotree
keymap("n", "<leader>vc", ":cd ~/.config/nvim<cr>")

keymap("n", "<leader>rr", function()
	vim.cmd("split | terminal ~/.cargo/bin/cargo run")
end, { desc = "Run Rust project" })

keymap("n", "<leader>ha", ":lua vim.diagnostic.open_float()<cr>")

keymap("n", "<leader>y", '"+y')

-- Expand snippet
keymap({ "i", "s" }, "<C-k>", function()
	require("luasnip").expand()
end, { desc = "Expand snippet" })

-- Jump forward/backward in snippet
keymap({ "i", "s" }, "<C-j>", function()
	require("luasnip").jump(1)
end, { desc = "Jump forward" })
keymap({ "i", "s" }, "<C-k>", function()
	require("luasnip").jump(-1)
end, { desc = "Jump backward" })
