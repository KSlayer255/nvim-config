-- Basic Neovim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.winborder = "rounded"

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.fn.system("source ~/.bashrc")
