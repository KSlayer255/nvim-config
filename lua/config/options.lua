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

local home = vim.env.HOME or vim.env.USERPROFILE -- HOME on Linux, USERPROFILE on Windows
local is_windows = vim.fn.has("win32") == 1

local path_sep = is_windows and ";" or ":"
local ghcup_bin = home .. (is_windows and "\\.ghcup\\bin" or "/.ghcup/bin")
local cabal_bin = home .. (is_windows and "\\.cabal\\bin" or "/.cabal/bin")
vim.env.PATH = ghcup_bin .. path_sep .. cabal_bin .. path_sep .. vim.env.PATH

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
