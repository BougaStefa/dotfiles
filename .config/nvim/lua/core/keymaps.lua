local set = vim.keymap.set

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable the spacebar key's default behavior in Normal and Visual modes
set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- save file
set("n", "<C-s>", "<cmd> w <CR>", { desc = "[S]ave file" })

-- delete single character without copying into register
set("n", "x", '"_x', { desc = "Delete without copying" })

-- Vertical scroll and center
set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Find and cecnter
set("n", "n", "nzzzv", { desc = "Find next and center" })
set("n", "N", "Nzzzv", { desc = "Find previous and center" })

-- Resize with arrows
set("n", "<Up>", ":resize -2<CR>", { desc = "Reduce current window height" })
set("n", "<Down>", ":resize +2<CR>", { desc = "Increase current window height" })
set("n", "<Left>", ":vertical resize -2<CR>", { desc = "Reduce current window width" })
set("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase current window width" })

-- Window management
set("n", "<leader>v", "<C-w>v", { desc = "[V]ertical split" }) -- split window vertically
set("n", "<leader>h", "<C-w>s", { desc = "[H]orizontal split" }) -- split window horizontally
set("n", "<leader>se", "<C-w>=", { desc = "Make [S]plits [E]qual" }) -- make split windows equal width & height
set("n", "<leader>xs", ":close<CR>", { desc = "E[x]it [S]plit" }) -- close current split window

-- Navigate between splits
set("n", "<C-k>", ":wincmd k<CR>", { desc = "Navigate to split above" })
set("n", "<C-j>", ":wincmd j<CR>", { desc = "Navigate to split below" })
set("n", "<C-h>", ":wincmd h<CR>", { desc = "Navigate to split left" })
set("n", "<C-l>", ":wincmd l<CR>", { desc = "Navigate to split right" })

-- Keep last yanked when pasting
set("v", "p", '"_dP', { desc = "[P]aste without yanking selection" })

-- Diagnostic keymaps
set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
set("n", "<leader>d", vim.diagnostic.open_float, { desc = "[D]iagnostic message" })
set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "[Q]uickfix list" })
