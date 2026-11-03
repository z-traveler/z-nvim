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
    "",
    "- first item",
    "- second item",
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
  local padding
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, { 6, 0 }, { 7, 0 }, { details = true })) do
    local text = ""
    for _, chunk in ipairs(mark[4].virt_text or {}) do
      text = text .. chunk[1]
    end
    if mark[2] == 6 and mark[4].virt_text_pos == "inline" and text:match("^ +$") then
      padding = vim.fn.strdisplaywidth(text)
    end
  end
  assert(padding == 1, "Markdown list markers should have only one cell of extra padding")
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
  local source = vim.env.OMNI_HOOKS_TEST_SOURCE or prompt_editor.dir
  local history = dofile(source .. "/modules/prompt-editor/nvim/lua/omni-prompt-editor/omni-history.lua")
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
      return {
        prompt = entry.id == "0001" and "First question" or "Latest question",
        final = entry.id == "0001" and "First answer" or "Latest answer",
        process = {},
      }
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

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.b[vim.api.nvim_win_get_buf(win)].omni_prompt_history and vim.api.nvim_win_get_config(win).relative == "" then
      local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
      assert(#lines % 3 == 0 and lines[2] == "  Latest question", "history prompt needs its own row")
      local question = vim.api.nvim_get_hl(0, { name = "OmniHistoryQuestion", link = false })
      local summary = vim.api.nvim_get_hl(0, { name = "OmniHistoryAnswer", link = false })
      local selection = vim.api.nvim_get_hl(0, { name = "OmniHistorySelected", link = false })
      assert(question.bold and question.fg ~= summary.fg, "history questions and summaries need distinct emphasis")
      assert(not selection.fg and not selection.ctermfg, "selection must not flatten the history text colors")
      vim.api.nvim_set_current_win(win)
      vim.cmd("normal j")
      assert(vim.api.nvim_win_get_cursor(win)[1] % 3 == 1, "j did not skip the prompt and summary rows")
      assert(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "Latest answer", "j opened an answer before Enter")
      vim.api.nvim_feedkeys(vim.keycode("<CR>"), "mx", false)
      assert(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "First answer", "Enter did not open the selected turn")
      assert(vim.api.nvim_get_current_win() == win, "Enter left the history pane")
    end
  end

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
