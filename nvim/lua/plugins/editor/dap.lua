local cfg = require("config.lsp.dap")

return {
  {
    "rcarriga/nvim-dap-ui",
    config = function(_, opts)
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
        vim.opt.mouse = "a"
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
        vim.opt.mouse = ""
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
        vim.opt.mouse = ""
      end
    end,
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>dl", function() require("dap").toggle_breakpoint("", "", vim.fn.input('Log: ')) end, desc = "Breakpoint Log" },
      { "<leader>dd", function()  end, desc = "Breakpoint Log" },
      { "<leader>dk", function() cfg.custom_breakpoint("KK") end, desc = "KK" },
      { "<leader>ds", function() cfg.custom_breakpoint("SS") end, desc = "SS" },
      { "<leader>ds", function() cfg.custom_breakpoint("SS") end, desc = "SS" },
      { "<leader>dS", function() cfg.custom_breakpoint("SSS") end, desc = "SSS" },
    }
  },
}
