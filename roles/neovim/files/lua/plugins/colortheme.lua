--return {
--  "catppuccin/nvim",
--  name = "catppuccin",
--  lazy = false,
--  priority = 1000,
--  config = function()
--    require("catppuccin").setup {
--      flavour = "mocha",
--      transparent_background = true,
--    }
--    vim.cmd.colorscheme "catppuccin"
--  end,
--}

return {
	"ellisonleao/gruvbox.nvim",
	priority = 1000,
	config = function()
		require("gruvbox").setup({
			undercurl = true,
			underline = true,
			bold = true,
			italic = {
				strings = true,
				emphasis = true,
				comments = true,
				operators = false,
				folds = false,
			},
			strikethrough = true,
			invert_selection = false,
			contrast = "hard",
			overrides = {},
			terminal_colors = true,
			dim_inactive = false,
		})
		vim.cmd("colorscheme gruvbox")
	end,
}
