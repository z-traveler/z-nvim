return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      if not require("lspconfig.configs").cspell_lsp then
        require("lspconfig.configs").cspell_lsp = {
          default_config = {
            cmd = { "cspell-lsp", "--stdio" },
            root_dir = LazyVim.root(),
            single_file_support = true,
          },
        }
      end
      local m_opts = {
        servers = {
          cspell_lsp = {},
        },
      }
      -- NOTE: too sensitive, use lint: codespell instead
      -- return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
}
