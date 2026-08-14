-- General opts
vim.opt.swapfile = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.confirm = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.winborder = "rounded"
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.smoothscroll = true
vim.opt.numberwidth = 2
vim.opt.undofile = true
vim.opt.wildoptions:append { "fuzzy" }

vim.g.mapleader = " "

-- Packages
vim.pack.add({
	'https://github.com/stevearc/oil.nvim',
	'https://github.com/nvim-mini/mini.icons',
	'https://github.com/neovim/nvim-lspconfig',
	'https://github.com/ellisonleao/gruvbox.nvim',
	'https://github.com/nvim-telescope/telescope.nvim',
	'https://github.com/nvim-lua/plenary.nvim',
	'https://github.com/nvim-treesitter/nvim-treesitter',
	'https://github.com/christoomey/vim-tmux-navigator',
})

vim.cmd.colorscheme("gruvbox")

-- Package setup
require("mini.icons").mock_nvim_web_devicons()

require("oil").setup(
	{
		lsp_file_methods = { enabled = true, timeout_ms = 1000, autosave_changes = true },
		columns = { "icon" },
		float = { max_width = 0.3, max_height = 0.6, border = "rounded" }
	})

require("telescope").setup({
	defaults = {
		preview = { treesitter = true },
		color_devicons = true,
		sorting_strategy = "ascending",
		borderchars = { "", "", "", "", "", "", "", "" },
		path_displays = { "smart" },
		layout_config = { height = 100, width = 400, prompt_position = "top", preview_cutoff = 40 }
	}
})

require("nvim-treesitter").install { "lua", "go", "javascript", "markdown", "rust", "c" , "c_sharp"}

-- LSPs
vim.lsp.enable({ "lua_ls", "gopls", "clangd", "roslyn_ls" })

-- Autocmds
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup("start-ts", { clear = true }),
	-- pattern = {'go', 'lua', 'markdown', 'rust', 'javascript'},
	callback = function() pcall(vim.treesitter.start) end,
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup("lsp-attatch", { clear = true }),
	callback = function(args)
		vim.o.signcolumn = 'yes:1'
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method('textDocument/completion') then
			vim.o.complete = 'o,.,w,b,u'
			vim.o.completeopt = 'menu,menuone,popup,noinsert'
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
	end
})

-- General mappings
vim.keymap.set('n', "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set('n', "<leader>e", "<cmd>Oil<CR>", { desc = "Open Oil" })
vim.keymap.set({ "n", "v", "x" }, "<leader>lf", vim.lsp.buf.format, { desc = "Format with LSP" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete to black hole register" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Search jump centers and unfolds" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Search jump centers and unfolds" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("v", "<", "<gv", { desc = "Stay in visual after indenting" })
vim.keymap.set("v", ">", ">gv", { desc = "Stay in visual after indenting" })
vim.keymap.set({ "n", "v", "x" }, "<CR>", ":", { desc = "Enter command mode" })
vim.keymap.set({ "n", "v", "x" }, "<leader>v", "<Cmd>edit $MYVIMRC<CR>", { desc = "Edit " .. vim.fn.expand("$MYVIMRC") })
vim.keymap.set({ "n", "v", "x" }, "<C-s>", [[:s/\V]], { desc = "Very nomagic sub mode" })
vim.keymap.set("n", "<leader>c", "1z=", { desc = "Accept first spelling suggestion" })
vim.keymap.set("n", "<Up>", ":resize -2<CR>", { desc = "Reduce current window height" })
vim.keymap.set("n", "<Down>", ":resize +2<CR>", { desc = "Increase current window height" })
vim.keymap.set("n", "<Left>", ":vertical resize -5<CR>", { desc = "Reduce current window width" })
vim.keymap.set("n", "<Right>", ":vertical resize +5<CR>", { desc = "Increase current window width" })
vim.keymap.set("n", "<C-q>", ":copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>a", ":edit #<CR>", { desc = "Switch to the alternate buffer" })

-- Diagnostics
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "View diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics quickfix list" })

-- Telescope
local builtin = require "telescope.builtin"
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Search files" })
vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Ripgrep project" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search buffers" })
vim.keymap.set("n", "<leader>si", builtin.grep_string, { desc = "Search word on cursor" })
vim.keymap.set("n", "<leader>so", builtin.oldfiles, { desc = "Search recent files" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search help" })
vim.keymap.set("n", "<leader>sm", builtin.man_pages, { desc = "Search man pages" })
vim.keymap.set("n", "<leader>G", builtin.git_commits, { desc = "Search git commits" })
vim.keymap.set("n", "<leader>sr", builtin.lsp_references, { desc = "Search references for symbol on cursor" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search diagnostics in project" })
vim.keymap.set("n", "<leader>sT", builtin.lsp_type_definitions, { desc = "Jump to type definition" })
vim.keymap.set("n", "<leader>ss", builtin.current_buffer_fuzzy_find, { desc = "Search current buffer" })
vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "Search all telescope builtins" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })
