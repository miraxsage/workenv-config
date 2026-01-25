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

-- Force transparent background for all colorschemes
local function apply_transparent_bg()
  local groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "LineNr",
    "CursorLineNr",
    "CursorLine",
    "EndOfBuffer",
    "FloatBorder",
    -- Snacks
    "SnacksNormal",
    "SnacksNormalNC",
    "SnacksPicker",
    "SnacksPickerBorder",
    "SnacksPickerInput",
    "SnacksPickerInputBorder",
    "SnacksPickerList",
    "SnacksPickerListBorder",
    "SnacksPickerPreview",
    "SnacksPickerPreviewBorder",
    "SnacksPickerBox",
    "SnacksInputNormal",
    "SnacksInputBorder",
    "FloatTitle",
    "SnacksPickerTitle",
    "SnacksTitle",
    -- Status line base background
    "StatusLine",
    "StatusLineNC",
    "TabLineFill",
    "NoicePopupBorder",
    "NoicePopup",
    "NoiceCmdlinePopupBorder",
    "NoiceCmdlinePopup",
    "NoiceCmdline",
    -- Lualine middle section (base background)
    "lualine_c_normal",
    "lualine_c_insert",
    "lualine_c_visual",
    "lualine_c_replace",
    "lualine_c_command",
    "lualine_c_inactive",
    "lualine_c_terminal",
    "lualine_transparent",
  }
  for _, group in ipairs(groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    if ok and hl then
      hl.bg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

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
    -- Force transparent background with delays for plugins that set highlights after
    apply_transparent_bg()
    vim.defer_fn(apply_transparent_bg, 50)
    vim.defer_fn(apply_transparent_bg, 150)
  end,
})

-- Apply immediately for current session (colorscheme already loaded before VeryLazy)
apply_transparent_bg()
vim.defer_fn(apply_transparent_bg, 100)
vim.defer_fn(apply_transparent_bg, 500)
vim.defer_fn(apply_transparent_bg, 1000)

-- Apply when dashboard loads (snacks dashboard sets highlights late)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_dashboard",
  callback = function()
    apply_transparent_bg()
    vim.defer_fn(apply_transparent_bg, 100)
    vim.defer_fn(apply_transparent_bg, 300)
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.defer_fn(apply_italic_to_keywords, 100)
    vim.defer_fn(apply_italic_to_keywords, 300)
    vim.defer_fn(apply_italic_to_keywords, 1500)
  end,
})
