-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local kset = vim.keymap.set
local kdel = vim.keymap.del

-- Launch full project linting and open touble with results
local lint = require("config.utils.lint-project")
kset("n", "<leader>xl", lint.run_lint, { desc = "Project errors (Trouble)" })

local show_full_path = require("config.utils.show-full-path")
kset("n", "<leader>fP", show_full_path, { desc = "Full file path popup" })

kdel("n", "<leader>.")
kset("n", "<leader>.", function()
  require("snacks.picker").recent()
end, { desc = "Recent Files" })

kset("n", "<leader>m", function()
  require("snacks").scratch()
end, { desc = "Open file scratch" })

local path = require("config.utils.paths")
vim.keymap.set("n", "<leader>fC", function()
  local rel = path.get_project_relative_path(0)
  if path.copy(rel) then
    print("Copied project-relative path")
  else
    print("No file")
  end
end, { desc = "Copy project-relative file path" })

vim.keymap.set("n", "<leader>fA", function()
  local abs = path.get_absolute_path()
  if path.copy(abs) then
    print("Copied absolute path")
  else
    print("No file")
  end
end, { desc = "Copy absolute file path" })
