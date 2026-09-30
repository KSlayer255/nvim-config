return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = vim.fn.has("win32") == 1
			and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
		or "make install_jsregexp",
	config = function()
		local ls = require("luasnip")

		ls.config.setup({
			enable_autosnippets = true,
			update_events = "TextChanged,TextChangedI",
		})

		-- Load all snippets from ~/.config/nvim/lua/snippets/*.lua
		require("luasnip.loaders.from_lua").load({
			paths = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "snippets"),
		})

		vim.keymap.set("i", "<C-k>", function()
			ls.expand()
		end)
	end,
}
