-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local lint = require("config.utils.lint")
-- Launch full project linting and open touble with results
vim.keymap.set("n", "<leader>xl", lint.run_lint, { desc = "Project errors (Trouble)" })

local show_full_path = require("config.utils.show-full-path")
vim.keymap.set("n", "<leader>fP", show_full_path, { desc = "Full file path popup" })
