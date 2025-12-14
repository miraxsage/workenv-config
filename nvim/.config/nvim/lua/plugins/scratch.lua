return {
  "ericrswanny/chkn.nvim",
  config = function()
    require("chkn").setup({
      width = 130,
      height = 36,
      border = "rounded",
      persistent = true,
    })
  end,
  lazy = false,
  keys = {
    {
      "<leader>fs",
      function()
        vim.cmd("silent! ChknToggle")
      end,
      desc = "Open global scratch",
    },
  },
}
