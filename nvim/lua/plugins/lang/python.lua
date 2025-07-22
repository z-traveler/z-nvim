return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "LspAttach" }, {
        group = vim.api.nvim_create_augroup("lsp_attach_disable_semantic", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "basedpyright" then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })
      local m_opts = {
        servers = {
          ruff = {
            enabled = false,
          },
          ruff_lsp = {
            enabled = false,
          },
          pyright = {
            settings = {
              python = {
                pythonPath = "python3",
              },
              basedpyright = {
                analysis = {
                  typeCheckingMode = "basic",
                  -- NOTE: for basedpyright
                  -- inlayHints = {
                  --   callArguments = true,
                  --   callArgumentNamesMatching = true,
                  --   variableTypes = false,
                  --   functionReturnTypes = false,
                  --   generatorTypes = false,
                  -- },
                },
              },
            },
          },
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
  {
    "stevearc/conform.nvim",
    ft = "python",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    },
  },
}
