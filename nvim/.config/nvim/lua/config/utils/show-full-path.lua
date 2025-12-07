-- Show full path in a float window that closes on any movement, like diagnostics
return function()
  local is_edit_buffer = (vim.bo.buftype == "") and vim.bo.modifiable
  if not is_edit_buffer then
    return
  end

  local path = vim.fn.expand("%:p")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { path })

  local width = vim.api.nvim_win_get_width(0) - 1
  local height = math.ceil(#path / width)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = 0,
    style = "minimal",
    row = 0,
    col = 1,
    width = width,
    height = height,
    border = "rounded",
    zindex = 50,
  })

  vim.api.nvim_win_set_option(win, "wrap", true)
  vim.api.nvim_win_set_option(win, "linebreak", true)
  vim.api.nvim_win_set_option(win, "breakindent", true)

  -- Automatic closing up on action
  local events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" }
  vim.api.nvim_create_autocmd(events, {
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    once = true,
  })
end
