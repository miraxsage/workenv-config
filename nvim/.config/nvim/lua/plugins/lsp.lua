return {
  {
    "neovim/nvim-lspconfig",
    opts = {

      diagnostics = {
        virtual_text = false,
      },

      servers = {
        -- Vue volar
        volar = {
          filetypes = { "vue" },
          init_options = {
            vue = { hybridMode = false },
          },
        },

        -- VTSLS: TypeScript + Vue over plugin
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

        -- Turn off deprecated vue_ls
        vue_ls = false,
      },
    },
  },
}
