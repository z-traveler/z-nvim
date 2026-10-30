local function check()
  local plugins = require("lazy.core.config").plugins
  assert(plugins["markview.nvim"] and plugins["markview.nvim"]._.loaded, "markview must load at startup")
  assert(not plugins["render-markdown.nvim"], "render-markdown must not be active alongside markview")
  assert(vim.fn.exists(":Markview") == 2, "Markview commands are unavailable")

  vim.cmd("enew")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "# Markdown rendering",
    "",
    "An **important** answer with `Map.load`.",
    "",
    "[Documentation](https://example.com)",
  })
  vim.bo[buf].filetype = "markdown"
  for _, language in ipairs({ "markdown", "markdown_inline" }) do
    assert(pcall(vim.treesitter.language.add, language), language .. " parser is unavailable")
  end
  vim.treesitter.start(buf, "markdown")
  vim.bo[buf].buftype = "nowrite"
  vim.bo[buf].readonly = true
  vim.bo[buf].modifiable = false

  vim.cmd("Markview attach")
  vim.cmd("Markview enable")
  vim.cmd("Markview hybridDisable")
  vim.cmd("Markview render")
  assert(
    vim.wait(2000, function()
      return #vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, {}) > 0
    end),
    "readonly Markdown has no rendering decorations"
  )
  assert(vim.bo[buf].readonly and not vim.bo[buf].modifiable, "rendering changed answer permissions")
  assert(vim.api.nvim_buf_get_lines(buf, 2, 3, false)[1] == "An **important** answer with `Map.load`.")
  local toggle = vim.fn.maparg("<leader>um", "n", false, true)
  assert(toggle.rhs and toggle.rhs:find("Markview toggle", 1, true), "Markdown toggle still targets the old renderer")

  local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
  assert(plugins["markview.nvim"].commit == lock["markview.nvim"].commit, "markview pin and local lock disagree")
  local prompt_editor = assert(plugins["omni-prompt-editor"], "prompt editor is missing")
  assert(prompt_editor.commit == lock["omni-prompt-editor"].commit, "prompt editor pin and lock disagree")
  assert(
    vim.fn.filereadable(prompt_editor.dir .. "/modules/prompt-editor/nvim/lua/omni-prompt-editor/omni-history.lua") == 1,
    "the installed prompt editor has no corner-history UI"
  )

  local answer_win = vim.api.nvim_get_current_win()
  vim.cmd("belowright new")
  local input_win, input_buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  vim.bo[input_buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, { "draft stays unchanged" })
  local history = dofile(prompt_editor.dir .. "/modules/prompt-editor/nvim/lua/omni-prompt-editor/omni-history.lua")
  local turns = {
    { id = "0001", updated_at = 1700000000, snippet = "first", has_final = true },
    { id = "0002", updated_at = 1700000001, snippet = "latest", has_final = true },
  }
  history.attach({ answer_win = answer_win, answer_buf = buf, input_win = input_win, input_buf = input_buf }, {
    command = "ZPromptHistoryTest",
    load = function()
      return { turns = turns }
    end,
    read = function(entry)
      return { final = entry.id == "0001" and "First answer" or "Latest answer", process = {} }
    end,
    text = function(turn)
      return turn.final
    end,
    render = function(turn)
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { turn.final })
      vim.bo[buf].modifiable = false
    end,
  })
  -- Reproduce the startup ordering: VeryLazy used to overwrite [a / ]a here.
  vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
  assert(
    vim.fn.maparg("[a", "n", false, true).desc == "上一轮回答",
    "Treesitter overwrote previous-answer navigation"
  )
  assert(vim.fn.maparg("]a", "n", false, true).desc == "下一轮回答", "Treesitter overwrote next-answer navigation")
  vim.cmd("normal [a")
  assert(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "First answer")
  vim.cmd("normal ]a")
  assert(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "Latest answer")
  assert(vim.api.nvim_get_current_win() == input_win, "history navigation stole draft focus")
  assert(vim.api.nvim_buf_get_lines(input_buf, 0, -1, false)[1] == "draft stays unchanged")

  vim.cmd("new")
  vim.bo.filetype = "lua"
  assert(
    vim.fn.maparg("[a", "n", false, true).desc == "Prev Parameter Start",
    "ordinary code lost parameter navigation"
  )
end

local ok, failure = xpcall(check, debug.traceback)
if ok then
  print("markview, Markdown parsers, toggle and prompt-editor pin verified")
  vim.cmd("cquit! 0")
else
  vim.api.nvim_err_writeln(failure)
  vim.cmd("cquit! 1")
end
