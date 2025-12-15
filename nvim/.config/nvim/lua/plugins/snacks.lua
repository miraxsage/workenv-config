return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.picker = opts.picker or {}
    opts.picker.sources = opts.picker.sources or {}

    --relativenumbers in snacks explorer
    opts.picker.sources.explorer = vim.tbl_deep_extend("force", opts.picker.sources.explorer or {}, {
      win = {
        list = {
          wo = {
            number = true,
            relativenumber = true,
            cursorline = true,
          },
        },
      },
    })

    opts.picker.layout = opts.picker.layout or {}

    --large vertical layout for all skacks picker windows
    local vertical_layout = {
      preset = "vertical",
      fullscreen = true,
      layout = {
        backdrop = false,
        min_width = 40,
        min_height = 10,
        box = "vertical",
        border = "rounded",
        title = "{title} {live} {flags}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none", height = 0.3 },
        { win = "preview", title = "{preview}", border = "top", height = 0.7 },
      },
    }

    opts.picker.layout = function(ctx)
      if ctx.source == "explorer" then
        return nil
      end
      return vertical_layout
    end

    return opts
  end,
}
