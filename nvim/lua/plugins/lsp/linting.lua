return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      if vim.fn.executable("codespell") == 1 then
        opts.linters_by_ft["*"] = vim.list_extend(opts.linters_by_ft["*"] or {}, { "codespell" })
      else
        vim.notify(
          "codespell not found, linting disabled.\nInstall: pip install codespell",
          vim.log.levels.WARN,
          { title = "nvim-lint", once = true }
        )
      end
      return opts
    end,
  },
}
