return {
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      local fzf = require("fzf-lua")
      local config = fzf.config
      local actions = fzf.actions

      config.defaults.keymap.builtin["<c-f>"] = "none"
      config.defaults.git.status.actions = {}

      config.defaults.keymap.fzf["ctrl-e"] = "toggle"
      config.defaults.keymap.fzf["ctrl-a"] = "toggle-all"
      config.defaults.keymap.fzf["ctrl-p"] = "up"
      config.defaults.keymap.fzf["ctrl-n"] = "down"
      config.defaults.keymap.fzf["up"] = "prev-history"
      config.defaults.keymap.fzf["down"] = "next-history"
      config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
      config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"

      local m_opts = {
        fzf_opts = {
          ["--layout"] = "default",
        },
        winopts = {
          preview = {
            layout = "flex",
            wrap = "wrap",
          },
        },
        files = {
          cwd_header = true,
          fzf_opts = {
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
          },
          actions = {
            ["alt-i"] = false,
            ["alt-h"] = false,
          },
        },
        grep = {
          path_shorten = 6, -- eg. abcedfgh/xx.py -> abcedf/xx.py
          fzf_opts = {
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-grep-history",
          },
          actions = {
            ["alt-i"] = false,
            ["alt-h"] = false,
          },
        },
        git = {
          status = {
            actions = {
              ["ctrl-f"] = { fn = actions.git_stage_unstage, reload = true },
              ["ctrl-w"] = { fn = actions.git_reset, reload = true },
            },
          },
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
    keys = {
      { "<leader>,", false },
      { "<leader>:", false },
      { "<leader>fb", false },
      { "<leader>fc", false },
      { "<leader>fF", false },
      { "<leader>fg", false },
      { "<leader>sa", false },
      { "<leader>sc", false },
      { "<leader>sh", false },
      { "<leader>sj", false },
      { "<leader>sk", false },
      { "<leader>sl", false },
      { "<leader>sq", false },
      { "<leader>sR", false },
      { "<leader>uC", false },
      { "<leader>sw", false },
      { "<leader>sW", false },
      { "<leader>fR", false },
      -- files
      {
        "<leader>ff",
        function()
          require("config.editor.fzf").files_excluded()
        end,
        desc = "Find Files (Excluded)",
      },
      { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader>fr", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (Root Dir)" },
      -- search
      {
        "<leader>sg",
        function()
          require("config.editor.fzf").rg_excluded()
        end,
        desc = "Grep (Excluded)",
      },
      {
        "<leader>sg",
        function()
          require("config.editor.fzf").rg_excluded({ visual = true })
        end,
        mode = "v",
        desc = "Selection Grep (Excluded)",
      },
      {
        "<leader>sG",
        function()
          require("config.editor.fzf").live_grep()
        end,
        desc = "Grep (Root Dir)",
      },
      {
        "<leader>sG",
        function()
          require("config.editor.fzf").live_grep({ visual = true })
        end,
        mode = "v",
        desc = "Selection Grep (Root Dir)",
      },
      {
        "<leader>sP",
        function()
          require("config.editor.fzf").select_and_grep()
        end,
        desc = "Grep (Special Dir)",
      },
      { "<leader>st", "<cmd>FzfLua tags_live_grep<cmd>", desc = "Tags" },
      -- fast
      { "<leader>sj", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader>fj", "<cmd>FzfLua resume<cr>", desc = "Resume" },
      { "<leader><space>", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
      -- help
      { "<leader>sH", "<cmd>FzfLua help_tags<cr>", desc = "Help Pages" },
      { "<leader>sK", "<cmd>FzfLua keymaps<cr>", desc = "Key Maps" },
    },
  },
  {
    "folke/todo-comments.nvim",
    keys = {
      { "<leader>st", false },
      { "<leader>sT", false },
    },
  },
}
