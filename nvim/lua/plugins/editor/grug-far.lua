return {
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sR",
        function()
          local grug = require("grug-far")
          grug.open({
            transient = true,
            engine = "astgrep",
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace (AST)",
      },
    },
  },
}
