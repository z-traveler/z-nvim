return {
  {
    "mason-org/mason.nvim",
    keys = {
      { "<leader>cm", false },
      { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- tree-sitter-cli from mason requires GLIBC_2.39 but system has 2.36.
      -- Replace with a compatible binary (v0.25.1, max GLIBC_2.34) after every install.
      local compat_ts = vim.fn.expand("~/.local/share/nvim-compat/tree-sitter")
      local mason_ts = vim.fn.expand("~/.local/share/nvim/mason/packages/tree-sitter-cli/tree-sitter-linux-x64")
      local function replace_ts_binary()
        if vim.fn.filereadable(compat_ts) == 1 and vim.fn.filereadable(mason_ts) == 1 then
          vim.fn.system({ "cp", compat_ts, mason_ts })
        end
      end
      vim.api.nvim_create_autocmd("User", {
        pattern = "MasonPackageInstalled",
        callback = function(ev)
          if ev.data and ev.data.pkg_name == "tree-sitter-cli" then
            replace_ts_binary()
          end
        end,
      })
      replace_ts_binary()
    end,
  },
}
