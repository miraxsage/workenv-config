return {
  "folke/snacks.nvim",
  opts = function(_, _)
    -- add relativenumber for files explorer
    vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")

        if ft == "snacks_picker_list" or ft == "snacks_explorer" then
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_set_option_value("number", true, { win = win })
              vim.api.nvim_set_option_value("relativenumber", true, { win = win })
              vim.api.nvim_set_option_value("cursorline", true, { win = win })
            end
          end, 30)
        end
      end,
    })
  end,
}
