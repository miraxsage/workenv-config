return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      {
        compile = false, -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false, -- do not set background color
        dimInactive = false, -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = { -- add/modify theme and palette colors
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors)
          return {
            LineNr = { fg = colors.fujiGray, bg = "NONE" },
            CursorLineNr = { fg = colors.peach, bg = "NONE", bold = true },
            CursorLine = { bg = "NONE" },
            Normal = { bg = "NONE" },
          }
        end,
        theme = "wave", -- Load "wave" theme
        background = { -- map the value of 'background' option to a theme
          dark = "wave", -- try "dragon" !
          light = "lotus",
        },
      },
    },
  },
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup({
        groups = {
          all = {
            FloatBorder = { bg = "bg0" },
          },
        },
      })
    end,
  },
  {
    "shaunsingh/moonlight.nvim",
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
  },
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("onedark").setup({
        style = "deep",
        transparent = true,
        highlights = {
          SnacksPicker = { bg = "#141a24" },
          SnacksPickerBoxCursorLine = { bg = "#141a24" },
          SnacksPickerBorder = { bg = "#141a24" },
        },
      })
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- require("github-theme").setup({
      --   -- ...
      -- })
      -- vim.cmd("colorscheme github_dark")
    end,
  },
  {
    "kyza0d/xeno.nvim",
    lazy = false,
    priority = 1000, -- Load colorscheme early
    config = function()
      -- Create your custom theme here
      require("xeno").new_theme("my-theme", {
        base = "#1E1E1E",
        accent = "#ff0000",
        contrast = 0.05,
      })
    end,
  },
  { "oonamo/ef-themes.nvim" },
  {
    "craftzdog/solarized-osaka.nvim",
    branch = "osaka",
    lazy = true,
    priority = 1000,
    opts = function()
      return {
        transparent = true,
      }
    end,
  },
  {
    "eldritch-theme/eldritch.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  { "Everblush/nvim", name = "everblush" },
  { "sainnhe/edge" },
  {
    "kartikp10/noctis.nvim",
    dependencies = { "rktjmp/lush.nvim" },
  },
  {
    "marko-cerovac/material.nvim",
  },
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    -- Optional; default configuration will be used if setup isn't called.
    config = function()
      require("everforest").setup({
        -- Your config here
        background = "hard",
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- transparent = true,
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- sidebars = "transparent",
        -- floats = "transparent",
      },
    },
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "vague-theme/vague.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other plugins
  },
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "MartelleV/kaimandres.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kaimandres").setup({
        -- leave empty to use default setup!
      })
      -- Some tweaks
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "kaimandres",
        callback = function()
          -- Remove annoying darker blocks in Lualine (if this happens to you)
          vim.api.nvim_set_hl(0, "StatusLine", { bg = "#16161e" })
        end,
      })
    end,
  },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
  {
    "oxidescheme/oxide.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("oxide").setup()
    end,
  },
  {
    "jpwol/thorn.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "folksoftware/nvim",
    name = "folk",
    priority = 1000,
    config = function()
      require("folk").setup({ flavour = "abraxas" })
    end,
  },
  {
    "rijulpaul/nightblossom.nvim",
    name = "nightblossom",
    lazy = false,
    priority = 1000,
  },
  { "vyrx-dev/void.nvim", lazy = false, priority = 1000 },
  {
    "2giosangmitom/nightfall.nvim",
    lazy = false,
    priority = 1000,
    opts = {}, -- Add custom configuration here
    config = function(_, opts)
      require("nightfall").setup(opts)
    end,
  },
}
