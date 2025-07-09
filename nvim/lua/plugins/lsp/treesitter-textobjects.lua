-- HACK: treesitter-textobjects config should write in nvim-treesitter
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["<down>"] = { query = { "@function.outer", "@class.outer" } },
            ["<right>"] = { query = { "@block.outer", "@conditional.outer", "@loop.outer", "@parameter.inner" } },
            ["]m"] = { query = { "@function.outer", "@class.outer" } },
            ["]a"] = { query = { "@parameter.inner" } },
          },
          goto_previous_start = {
            ["<up>"] = { query = { "@function.outer", "@class.outer" } },
            ["<left>"] = { query = { "@block.outer", "@conditional.outer", "@loop.outer", "@parameter.inner" } },
            ["[m"] = { query = { "@function.outer", "@class.outer" } },
            ["]a"] = { query = { "@parameter.inner" } },
          },
        },
        include_surrounding_whitespace = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "vv",
          node_incremental = "J",
          node_decremental = "K",
          scope_incremental = "L",
        },
      },
    },
  },
}
