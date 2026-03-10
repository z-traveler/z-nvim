return {
  {
    "neovim/nvim-lspconfig",
    -- stylua: ignore
    opts = function(_, opts)
      local inlay_group = vim.api.nvim_create_augroup("inlay_hints_toggle", { clear = true })
      vim.api.nvim_create_autocmd({ "InsertEnter" }, {
        group = inlay_group,
        callback = function()
          vim.lsp.inlay_hint.enable(false)
        end,
      })
      vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        group = inlay_group,
        callback = function()
          vim.lsp.inlay_hint.enable(true)
        end,
      })

      opts.servers = opts.servers or {}
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = vim.list_extend(opts.servers["*"].keys or {}, {
        -- disable LazyVim defaults
        { "K", false },
        { "gy", false },
        { "<c-k>", false },
        { "<leader>cl", false },
        { "<leader>ca", false },
        { "<leader>cA", false },
        { "<leader>cc", false },
        { "<leader>cC", false },
        { "<leader>cr", false },
        { "<leader>cR", false },
        -- custom keys
        { "gt", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", desc = "Goto Type Definition" },
        { "gp", function() return vim.lsp.buf.hover() end, desc = "Hover" },
        { "gP", function() return vim.lsp.buf.signature_help() end, desc = "Hover" },
        { "<leader>ll", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
        { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
        { "<leader>lA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
        { "<leader>lc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
        { "<leader>lC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
        { "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
        { "<leader>lR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode = { "n" }, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
      })
    end,
  },
}
