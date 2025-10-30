return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Volar: только шаблоны и Vue-файлы
        volar = {
          filetypes = { "vue" },
          init_options = {
            vue = { hybridMode = false },
          },
        },

        -- VTSLS: TypeScript + Vue через плагин
        vtsls = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.expand(
                      "~/.local/share/nvim/mason/packages/vue-language-server/node_modules/@vue/language-server"
                    ),
                    languages = { "vue" },
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
          },
        },

        -- Отключаем устаревший vue_ls
        vue_ls = false,
      },
    },
  },
}
