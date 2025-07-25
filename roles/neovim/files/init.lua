require("core.options")
require("core.keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("plugins.oil"),
	require("plugins.colortheme"),
	require("plugins.lualine"),
	require("plugins.treesitter"),
	require("plugins.telescope"),
	require("plugins.lsp"),
	require("plugins.completion"),
	require("plugins.formatting"),
	require("plugins.autopairs"),
	require("plugins.git"),
	require("plugins.leetcode"),
	require("plugins.whichkey"),
	require("plugins.todo-comments"),
	require("plugins.mini"),
	require("plugins.copilot"),
	require("plugins.tmux"),
})
