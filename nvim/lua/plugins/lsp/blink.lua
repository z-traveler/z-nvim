return {
  {
    "saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LazyLoad",
        callback = function()
          vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { bold = true })
        end,
      })
      local m_opts = {
        completion = {
          ghost_text = {
            enabled = false,
          },
          menu = {
            draw = {
              columns = { { "kind_icon" }, { "label", gap = 1 } },
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
              },
            },
          },
        },
        keymap = {
          preset = "none",
          ["<C-e>"] = { "cancel", "hide", "fallback" },
          ["<enter>"] = { "snippet_forward", "fallback" },
          ["<C-j>"] = { "select_and_accept", "snippet_forward", "fallback" },
          ["<C-k>"] = { "snippet_backward", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
          ["<C-n>"] = { "select_next", "show", "fallback_to_mappings" },
          ["<Tab>"] = { "snippet_forward", "fallback" },
          ["<S-Tab>"] = { "snippet_backward", "fallback" },
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
}
