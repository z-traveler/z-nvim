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
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "K", false }
      keys[#keys + 1] = { "gy", false }
      keys[#keys + 1] = { "<c-k>", false }
      keys[#keys + 1] = { "<leader>cl", false }
      keys[#keys + 1] = { "<leader>ca", false }
      keys[#keys + 1] = { "<leader>cA", false }
      keys[#keys + 1] = { "<leader>cc", false }
      keys[#keys + 1] = { "<leader>cC", false }
      keys[#keys + 1] = { "<leader>cr", false }
      keys[#keys + 1] = { "<leader>cR", false }
      keys[#keys + 1] = { "gt", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", desc = "Goto Type Definition" }
      keys[#keys + 1] = { "gp", function() return vim.lsp.buf.hover() end, desc = "Hover", }
      keys[#keys + 1] = { "gP", function() return vim.lsp.buf.signature_help() end, desc = "Hover", }

      keys[#keys + 1] = { "<leader>ll", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" }
      keys[#keys + 1] = { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
      keys[#keys + 1] = { "<leader>lA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" }
      keys[#keys + 1] = { "<leader>lc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" }
      keys[#keys + 1] = { "<leader>lC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens", }
      keys[#keys + 1] = { "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
      keys[#keys + 1] = { "<leader>lR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode = { "n" }, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" }, }
    end,
  },
}
