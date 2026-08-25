return {
  {
    "z-traveler/omni-hooks",
    name = "omni-prompt-editor",
    commit = "2b750e5c3b97cb69635102fb5e28c9cac7a9d287",
    lazy = false,
    config = function(plugin)
      vim.opt.runtimepath:prepend(plugin.dir .. "/modules/prompt-editor/nvim")
      -- 避免旧的 site module 覆盖 lazy.nvim 固定的版本
      local module = dofile(plugin.dir .. "/modules/prompt-editor/nvim/lua/omni-prompt-editor/init.lua")
      package.loaded["omni-prompt-editor"] = module
      module.setup()

      local function attach_marksman()
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
            vim.b[buf].omni_prompt_answer = true
            vim.lsp.start(marksman, { bufnr = buf })
          end
        end
      end

      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          vim.schedule(attach_marksman)
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(event)
          if event.data == "nvim-lspconfig" then
            vim.schedule(attach_marksman)
          end
        end,
      })
    end,
  },
}
