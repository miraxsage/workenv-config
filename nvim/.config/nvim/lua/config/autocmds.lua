-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- make Snacks picker preview focusable & scrollable
--
-- TODO: it looks like this autocmd doesnt work as should
vim.api.nvim_create_user_command("ClearSwp", function()
  local swp_files = vim.fn.systemlist("find . -type f -name '*.swp'")
  if #swp_files == 0 then
    vim.notify("No swp-files", vim.log.levels.INFO)
    return
  end
  vim.fn.system("find .type -f -name '*.swp' -delete")
  vim.notify("Deleted swp-files: " .. #swp_files, vim.log.levels.INFO)
end, {})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "kanagawa*",
  callback = function()
    vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "moonlight*",
  callback = function()
    vim.defer_fn(function()
      local color = "#403a57"
      -- all groups for word under cursor highlighting having reference
      vim.api.nvim_set_hl(0, "IlluminatedWord", { bg = color })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = color })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = color })
      vim.api.nvim_set_hl(0, "LspReferenceText", { bg = color })
      vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = color })
      vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = color })
      -- selected text
      vim.api.nvim_set_hl(0, "Visual", { bg = "#3d2f78" })
    end, 50)
  end,
})

-- Autocmd for universal making keywords as italic
-- to get actual group name stand on a word and do command:
-- :lua print(vim.inspect(vim.treesitter.get_captures_at_cursor()))
-- for another group just look for it by color at :highlight
local function apply_italic_to_keywords()
  local italic_groups = {
    -- Tree-sitter
    "@keyword",
    "@keyword.function",
    "@keyword.return",
    "@keyword.export",
    "@keyword.import",
    "@keyword.declaration",
    "@keyword.conditional",
    "@keyword.repeat",
    "@conditional",
    "@repeat",
    "@boolean",
    "@statement",
    "@comment",
    -- Anogher
    "DiagnosticVirtualTextWarn",
    "DiagnosticVirtualTextError",
    -- "GitSignsCurrentLineBlame",
  }
  -- Supressing groups
  local no_italic_groups = {
    "string",
    "WhichKeyDesc",
  }

  for _, group in ipairs(italic_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl_by_name, group, true)
    if ok then
      vim.api.nvim_set_hl(0, group, {
        italic = true,
        fg = hl.foreground,
        bg = hl.background,
      })
    end
  end

  for _, group in ipairs(no_italic_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl_by_name, group, true)
    if ok then
      vim.api.nvim_set_hl(0, group, {
        italic = false,
        fg = hl.foreground,
        bg = hl.background,
      })
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Launch setting up italic styles with different delays for reliability
    vim.defer_fn(apply_italic_to_keywords, 150)
    vim.defer_fn(apply_italic_to_keywords, 500)
    vim.defer_fn(apply_italic_to_keywords, 1500)
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.defer_fn(apply_italic_to_keywords, 100)
    vim.defer_fn(apply_italic_to_keywords, 300)
    vim.defer_fn(apply_italic_to_keywords, 1500)
  end,
})
