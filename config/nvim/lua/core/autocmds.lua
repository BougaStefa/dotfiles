vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "copilot-chat",
	callback = function()
		vim.b.completion = false
	end,
})
