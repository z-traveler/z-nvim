return {
  {
    "z-traveler/omni-hooks",
    name = "omni-prompt-editor",
    commit = "bd282d9832d8e079c240361292815b27b8bbc513",
    lazy = false,
    config = function(plugin)
      vim.opt.runtimepath:prepend(plugin.dir .. "/modules/prompt-editor/nvim")
      -- 避免旧的 site module 覆盖 lazy.nvim 固定的版本
      local module = dofile(plugin.dir .. "/modules/prompt-editor/nvim/lua/omni-prompt-editor/init.lua")
      package.loaded["omni-prompt-editor"] = module
      module.setup()

      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          vim.schedule(function()
            local marksman = vim.lsp.config.marksman
            if not marksman then
              return
            end
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if
                vim.api.nvim_buf_is_loaded(buf)
                and vim.bo[buf].filetype == "markdown"
                and vim.bo[buf].buftype == "nowrite"
                and vim.bo[buf].bufhidden == "wipe"
                and vim.bo[buf].readonly
                and not vim.bo[buf].modifiable
                and vim.api.nvim_buf_get_name(buf) == ""
              then
                local name = ("omni-prompt-answer-%d.md"):format(vim.fn.getpid())
                vim.api.nvim_buf_set_name(buf, vim.fs.joinpath(vim.fn.stdpath("run"), name))
                vim.lsp.start(marksman, { bufnr = buf })
              end
            end
          end)
        end,
      })
    end,
  },
}
