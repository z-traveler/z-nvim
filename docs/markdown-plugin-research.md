# Markdown 文件体验插件调研

> 调研日期：2026-08-13；范围：仅采用插件上游仓库 README/docs、GitHub 官方 API 与 LazyVim 官方文档。本文是选型和最小接入建议，**没有修改任何 `nvim/` 配置**。

## 结论先行

推荐按需求逐层增加，而不是安装“全家桶”：

1. **首选渲染：`render-markdown.nvim`。** 它负责当前缓冲区的可读渲染和编辑时的原文回退；这是唯一应默认新增的 Markdown UI 插件。
2. **大纲先走零新增 UI 插件路线：启用 Marksman，复用已有 Trouble symbols（`<A-s>`）与 LazyVim/FzfLua 的当前 buffer symbol picker（`<leader>ss`）。** 当前 Markdown buffer 没有 LSP client，且 `marksman` 不在 PATH/Mason bin，故现状缺少这两项所需的 `documentSymbol` 来源。
3. **若不想依赖 LSP，或希望原生 Markdown 的独立侧栏，再选 `aerial.nvim`。** 它可从 Markdown/Tree-sitter 建立大纲；这是与第二项互斥的“新增侧栏”路线，而非 P0 前置项。
4. **需要面包屑时再加 `dropbar.nvim`。** 它是当前标题层级的 winbar，不替代上述任一完整目录。当前配置关闭了 `mouse`，因此应以键盘 pick/drop-down 为主，不能把鼠标交互当作必要能力。
5. **确实需要浏览器中查看 Mermaid/KaTeX/最终网页排版时再加 `markdown-preview.nvim`。** LazyVim 的 Markdown extra 已集成它，但该项目最近一次代码推送早于其他候选，且安装需要下载其前端产物；不应因“有预览”而默认启用。
6. **Markdown 笔记库才考虑 `mkdnflow.nvim`。** 它的链接、表格、待办和跨文件导航很完整，但默认键位会覆盖常用键；必须先禁用默认 mappings，再按本配置的 `<leader>m…` 约定显式添加少数键位。

**不要与 `render-markdown.nvim` 同时安装** `markview.nvim` 或 `headlines.nvim`：前两者是相同渲染层的替代方案；`headlines.nvim` 的维护者也明确建议改用 `render-markdown.nvim`。

## 当前配置基线与适配约束

本仓库没有既有调研文档或 `docs/` 目录；因此本报告放在 `docs/`，不混入运行时 `nvim/` 配置。

| 已核对项 | 证据 | 对选型的影响 |
| --- | --- | --- |
| Neovim 为 `v0.12.4` | `nvim --version`（本机） | 满足本文所有候选的最低版本；Aerial/Dropbar 所需的 0.11 亦满足。 |
| 当前锁定 `nvim-treesitter`、`mini.icons`、`blink.cmp`、`fzf-lua`、`lualine.nvim`、`conform.nvim`、`nvim-lint`、`trouble.nvim` | `nvim/lazy-lock.json` | 渲染、大纲和补全的核心依赖大多已存在；无需为了图标新增 `nvim-web-devicons`。 |
| 自定义插件入口只导入 `plugins.ui/window/editor/lsp/lang` | `nvim/lua/plugins/init.lua` | 建议将将来的 Markdown spec 放在既有分类下（视觉放 `plugins/ui/`，编辑放 `plugins/editor/`），而不是新增平行的配置体系。 |
| 已锁定 `trouble.nvim`，并将 `<A-s>` 映射为 `Trouble symbols toggle` | `nvim/lua/plugins/ui/trouble.lua` | 已有可复用的大纲 UI；其 `symbols` mode 是 LSP document symbols，因此只需补上能提供该能力的 Markdown LSP。 |
| `wrap=true`、`mouse=""`，Lualine 自定义状态栏但未在该 spec 中配置 `winbar` | `nvim/lua/config/options.lua`、`nvim/lua/plugins/ui/lualine.lua` | Dropbar 会占用 winbar；鼠标特性不应作为其主要使用方式。Markview 上游偏好 `nowrap`，所以它不是此配置的默认推荐。 |
| Blink 在插入模式使用 `<Tab>`/`<S-Tab>` | `nvim/lua/plugins/lsp/blink.lua` | Mkdnflow 的默认插入模式表格跳转会与之竞争；禁用其默认 mappings 后仅保留显式映射。 |

本机已在 Markdown buffer 实测 `markdown_parser=true`；故 `markdown` parser 已安装可用。`markdown_inline` 是 Render Markdown 的另一项必需 parser，接入前仍应以 `:checkhealth render-markdown` 核对；其他主机也不得只依据 `lazy-lock.json` 或 `example.lua` 推断 parser 状态。

LazyVim 官方的 [Markdown extra](https://www.lazyvim.org/extras/lang/markdown) 同时包含 `marksman`、`markdownlint-cli2`、`markdown-toc`、浏览器预览、`render-markdown.nvim`，并为 Conform/nvim-lint 提供对应配置。它适合作为完整语言工具链的参考；对于本任务的“体验插件”，一次性导入它会超出最小改动范围。

本机同次实测的 Markdown LSP clients 为 `0`，并确认 `marksman` 不在 PATH 或 Mason bin。Trouble 上游将 `symbols` 定义为 LSP document symbols；而当前启用的 FzfLua/LazyVim `<leader>ss` 也调用 `lsp_document_symbols`。因此二者在 Markdown 上都应先安装并启用 Marksman，不能把“已有 Trouble”误解为“现状已有可用 Markdown 大纲”。[Trouble 官方文档](https://github.com/folke/trouble.nvim#readme)、[Marksman 的标题 document symbols 说明](https://github.com/artempyanykh/marksman/blob/main/docs/features.md) 和其 [Mason/nvim-lspconfig 集成 README](https://github.com/artempyanykh/marksman#readme) 支持这一路线。

## 分层推荐

### P0：缓冲区内渲染 — `MeanderingProgrammer/render-markdown.nvim`（推荐）

- **用途**：在 Neovim 内渲染标题、代码块、列表、任务框、表格、链接、引用和 callout；默认仅在普通/命令/终端模式显示渲染，光标附近保留原始 Markdown，适合“阅读与编辑同一 buffer”。上游还提供侧边预览命令。
- **官方依据**：[README](https://github.com/MeanderingProgrammer/render-markdown.nvim#readme)；其功能、`lazy.nvim` 安装方式和命令见 [Features/Requirements/Install](https://github.com/MeanderingProgrammer/render-markdown.nvim#features)。上游明确支持 Blink 的 checkbox/callout completion，且已有 Blink。
- **依赖**：必需 `markdown` 与 `markdown_inline` Tree-sitter parser；`html`、`latex`、`yaml` parser 可选。图标可用 `mini.icons` 或 `nvim-web-devicons`；当前已有前者。LaTeX 文本转换另有可选系统工具，未需要公式时不要为它安装。
- **维护状态**：2026-08-13 通过 [GitHub 官方仓库 API](https://api.github.com/repos/MeanderingProgrammer/render-markdown.nvim) 核对：未归档，最近推送为 2026-08-11；最近 release 为 [v8.13.0（2026-06-18）](https://github.com/MeanderingProgrammer/render-markdown.nvim/releases/tag/v8.13.0)。
- **适配风险**：它会调整渲染窗口的 conceal 相关选项；先在本配置的全局 `wrap=true` 文档、表格和长引用上实测。不要再启用 Markview/Headlines 的 Markdown 渲染；上游也单独提示其与 Obsidian UI 不应并用。

**最小 spec（示意，未写入配置）**：

```lua
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    opts = {},
  },
}
```

安装后先验证：打开含标题、表格、任务框、代码块的 `.md`，运行 `:checkhealth render-markdown`；确认 `markdown` 与 `markdown_inline` parser 均为 OK，再决定是否添加 `yaml`/`latex`。

### P0（路线 A）：复用现有大纲 UI — Marksman + Trouble/FzfLua（最小）

- **用途**：不新增 Neovim UI 插件。安装并启用 Marksman 后，继续用已映射的 `<A-s>` 打开 `Trouble symbols`，或用 `<leader>ss` 调用 FzfLua 的当前 buffer LSP symbols；两者均可承担 Markdown 标题大纲与跳转。
- **当前缺口**：本机实测该 Markdown buffer 的 LSP client 为 0，`marksman` 也不在 PATH/Mason bin；所以现在按 `<A-s>` 或 `<leader>ss` 很可能没有可用 document symbols。这不是 Trouble 的 Markdown/Tree-sitter 大纲功能。
- **官方依据**：[LazyVim Markdown extra](https://www.lazyvim.org/extras/lang/markdown) 的 `marksman = {}` server spec；[Marksman features](https://github.com/artempyanykh/marksman/blob/main/docs/features.md) 明确列出“Document symbols from headings”，其 [README](https://github.com/artempyanykh/marksman#readme) 说明 Mason/nvim-lspconfig 集成；[Trouble README](https://github.com/folke/trouble.nvim#readme) 将 `symbols` mode 明确定义为 LSP document symbols。
- **维护状态**：2026-08-13 [GitHub 官方 API](https://api.github.com/repos/artempyanykh/marksman) 显示未归档、最近推送 2026-02-08；最新 release 为 [2026-02-08](https://github.com/artempyanykh/marksman/releases/tag/2026-02-08)。
- **依赖与风险**：这不是零依赖，而是“零新增 UI 插件”：仍需通过现有 Mason/nvim-lspconfig 安装并启动 Marksman。它同时带来补全、诊断、跳转和重命名，范围比“目录”更宽；若只要标题侧栏且不希望引入 Markdown LSP，应选路线 B。
- **最小验证**：启用后重新打开 `.md`，确认 `:LspInfo` 有 Marksman client，再分别验证 `<A-s>` 与 `<leader>ss` 能列出标题。对于跨文件链接，Marksman 上游说明应有 Git 仓库根或 `.marksman.toml`。

### P0（路线 B）：无需 LSP 的 Markdown 原生侧栏 — `stevearc/aerial.nvim`（按需）

- **用途**：可开关的大纲窗口，支持跳转、前后符号导航。上游的 Tree-sitter 支持列表包含 `markdown`；默认 backend 优先 Tree-sitter，Markdown backend 也可显式指定。
- **官方依据**：[README 的 requirements、安装和 Markdown 支持](https://github.com/stevearc/aerial.nvim#readme)；[backend 与 `AerialToggle!` 命令](https://github.com/stevearc/aerial.nvim#commands)。
- **依赖**：Neovim ≥0.11，且需有效 LSP 或 Tree-sitter parser；`nvim-web-devicons` 只是可选。本配置满足前两项并已有 Tree-sitter；不需要为图标添加新依赖。
- **维护状态**：2026-08-13 [官方 API](https://api.github.com/repos/stevearc/aerial.nvim) 显示未归档、最近推送 2026-06-02；最近 release 为 [v4.0.0（2026-05-24）](https://github.com/stevearc/aerial.nvim/releases/tag/v4.0.0)。
- **适配风险**：它只需使用现有 Markdown parser，不必引入 `marksman`。这是路线 A 的替代方案；不要因为已有 Trouble 就同时新增 Aerial，除非实测后确实需要 Tree-sitter 无 LSP 的独立侧栏。其官方示例的 `{`/`}` 和 `<leader>a` 不是本配置的既有约定，建议只加一个 Markdown 专用的 `<leader>m…` 键位，避免全局改动。

**最小 spec（示意）**：

```lua
return {
  {
    "stevearc/aerial.nvim",
    ft = { "markdown" },
    opts = {
      backends = { "markdown", "treesitter" },
    },
    keys = {
      { "<leader>mo", "<cmd>AerialToggle!<cr>", ft = "markdown", desc = "Markdown Outline" },
    },
  },
}
```

### P1：当前标题面包屑 — `Bekaboo/dropbar.nvim`（按需）

- **用途**：为 winbar 提供可点击/键盘选择的层级面包屑；内置的 Markdown source 专门读取标题，也可回退到 path/Tree-sitter/LSP source。
- **官方依据**：[README](https://github.com/Bekaboo/dropbar.nvim#readme) 的 [Markdown source 与功能](https://github.com/Bekaboo/dropbar.nvim#features)、[requirements 与 lazy.nvim 示例](https://github.com/Bekaboo/dropbar.nvim#requirements)。
- **依赖**：Neovim ≥0.11；无强制第三方依赖。Tree-sitter/LSP 和 `nvim-web-devicons` 都是可选增强；fuzzy menu 才需要 `telescope-fzf-native`。本配置使用 `fzf-lua` 而不是 Telescope，故不要为了该可选功能添加 Telescope。
- **维护状态**：2026-08-13 [官方 API](https://api.github.com/repos/Bekaboo/dropbar.nvim)：未归档、最近推送 2026-05-31；最近 release 为 [v14.2.1（2025-08-02）](https://github.com/Bekaboo/dropbar.nvim/releases/tag/v14.2.1)。
- **适配风险**：插件占用 `winbar`，必须在与 Lualine/LazyVim 运行时组合后检查实际窗口；本仓库设置 `mouse=""`，上游所述点击和 hover（后者还要求 `mousemoveevent`）不应视为可用主流程。用 `require("dropbar.api").pick()` 的键位进入选择模式即可。

若只想“看完整标题目录”，优先复用路线 A；没有 LSP 依赖需求时选择 Aerial。只有经常需要当前章节路径时再加 Dropbar；它与任一大纲路线互补，不取代目录侧栏。

### P1：浏览器预览 — `iamcco/markdown-preview.nvim`（按需）

- **用途**：浏览器实时预览与同步滚动；上游列出 KaTeX、Mermaid、TOC、任务列表和本地图片等渲染能力，适合确认最终网页化效果。
- **官方依据**：[README](https://github.com/iamcco/markdown-preview.nvim#readme)；其 [lazy.nvim 安装与 build 方式](https://github.com/iamcco/markdown-preview.nvim#installation--usage)。LazyVim 官方 extra 也给出 `:MarkdownPreviewToggle` 和 `<leader>cp` 的 spec：[LazyVim Markdown extra](https://www.lazyvim.org/extras/lang/markdown)。
- **依赖**：浏览器；插件安装时需执行其 build。上游给出预构建安装路径，若走 Node 路径则需要 Node.js 与 yarn/npm。它不是纯 Lua/Tree-sitter 插件。
- **维护状态**：2026-08-13 [官方 API](https://api.github.com/repos/iamcco/markdown-preview.nvim) 显示未归档，但最近代码推送为 **2024-07-23**，最新 [v0.0.10（2022-05-13）](https://github.com/iamcco/markdown-preview.nvim/releases/tag/v0.0.10)。这不是“不可用”的证据，但维护节奏明显低于 P0 候选；仅在浏览器渲染确有价值时接入。
- **适配风险**：其预览与 Render Markdown 的 buffer 内渲染不同，可以共存；代价是外部浏览器和前端依赖。当前配置未占用 `<leader>cp`，但新增前仍应在运行中的 which-key/keymap 中复查。

### P2：笔记库编辑增强 — `jakewvincent/mkdnflow.nvim`（仅笔记库）

- **用途**：标题/链接跳转、目录窗口、跨文件回退、链接创建与跟随、表格编辑、待办操作、折叠及 YAML front matter。不是单篇 README 编辑所必需。
- **官方依据**：[README](https://github.com/jakewvincent/mkdnflow.nvim#readme) 的 [功能与最低版本](https://github.com/jakewvincent/mkdnflow.nvim#features)、[默认键位及禁用方法](https://github.com/jakewvincent/mkdnflow.nvim#custom-mappings)。
- **依赖**：Neovim ≥0.9.5；README 未列出必需第三方 Neovim 插件。本配置版本足够。
- **维护状态**：2026-08-13 [官方 API](https://api.github.com/repos/jakewvincent/mkdnflow.nvim)：未归档、最近推送 2026-07-03；最新 [v2.22.3（2026-07-03）](https://github.com/jakewvincent/mkdnflow.nvim/releases/tag/v2.22.3)。
- **适配风险（高）**：默认 `maps` 模块会绑定普通/可视模式 `<CR>`、普通模式 `<BS>`/`<Del>`/`<Tab>`/`<S-Tab>`、普通模式 `o`/`O`，以及插入模式表格 `<Tab>`/`<S-Tab>`。即使部分范围与 Blink 不同，也不符合当前配置明确维护键位的做法。上游支持 `modules = { maps = false }` 及 `ft` scoped lazy.nvim keys；应先完全关闭默认键位，再只添加需要的 buffer-local 映射。

## 渲染替代项与明确排除项

### `OXY2DEV/markview.nvim`：功能更宽的渲染替代项，不与 P0 同装

- 可在 Neovim 内预览 Markdown/HTML/LaTeX/Typst/YAML，提供 hybrid editing 和 splitview；其 README 明说 lazy.nvim 下应 `lazy = false`，并要求在配色后加载。
- 要求 Neovim ≥0.10.3 与 `markdown`/`markdown_inline` parser；支持 wrap，但上游推荐 `nowrap`。本配置全局 `wrap=true`，故应先单独试用，不适合作为默认低风险选择。
- 维护状态：2026-08-13 [官方 API](https://api.github.com/repos/OXY2DEV/markview.nvim) 显示未归档、最近推送 2026-07-13；最新 [v28.3.0（2026-05-16）](https://github.com/OXY2DEV/markview.nvim/releases/tag/v28.3.0)。
- 官方来源：[README/requirements/installation](https://github.com/OXY2DEV/markview.nvim#readme)。**选择它时不要再安装 Render Markdown**，二者都管理 Markdown 的虚拟文本、conceal 和预览。

### `lukas-reineke/headlines.nvim`：不新增

它仅为标题、代码块、分隔线、引用加高亮，依赖 Tree-sitter；维护者在 README 中直接写明 `render-markdown.nvim` “does everything … and more”，并表示不太可能继续添加功能。[官方说明](https://github.com/lukas-reineke/headlines.nvim#readme)。因此没有独立于 P0 的收益。

## 最小落地顺序

1. 仅接入 P0 的 Render Markdown；本机 `markdown` parser 已实测可用，先以 `:checkhealth render-markdown` 核对 `markdown_inline` 并打开一份真实长文。
2. 大纲先走路线 A：通过现有 Mason/nvim-lspconfig 安装并启用 Marksman，确认 `:LspInfo` 有 client 后验证已有的 `<A-s>` Trouble symbols 与 `<leader>ss` FzfLua symbols。
3. 若明确不希望 Markdown LSP，或路线 A 的标题大纲不符合需要，再**改选**路线 B 的 Aerial；确认同一文件的标题层级和跳转正确，不与路线 A 默认叠加。
4. 确认自己确实需要“当前章节路径”后才加 Dropbar；因 `mouse=""`，同时加一个键盘 pick 映射。
5. 只有 Mermaid/KaTeX/网页最终排版成为日常需求时加浏览器预览。
6. 只有管理跨文件笔记库时加 Mkdnflow，并先关掉默认 mappings；不要在没有真实笔记工作流时引入它。

每步安装后都应运行插件提供的 healthcheck（若有）、打开实际 Markdown 样本，并通过 `:map <buffer>` 检查键位。若导入 LazyVim Markdown extra，则它会额外接入 LSP、lint 和 formatter；应把它作为另一项有意识的语言工具链决策，而非上述 P0/P1 体验插件的前置条件。

## 来源与可复核性

- [LazyVim Markdown extra（官方）](https://www.lazyvim.org/extras/lang/markdown)
- [Trouble（上游）](https://github.com/folke/trouble.nvim)
- [Marksman（上游）](https://github.com/artempyanykh/marksman)
- [render-markdown.nvim（上游）](https://github.com/MeanderingProgrammer/render-markdown.nvim)
- [aerial.nvim（上游）](https://github.com/stevearc/aerial.nvim)
- [dropbar.nvim（上游）](https://github.com/Bekaboo/dropbar.nvim)
- [markdown-preview.nvim（上游）](https://github.com/iamcco/markdown-preview.nvim)
- [mkdnflow.nvim（上游）](https://github.com/jakewvincent/mkdnflow.nvim)
- [markview.nvim（上游）](https://github.com/OXY2DEV/markview.nvim)
- [headlines.nvim（上游）](https://github.com/lukas-reineke/headlines.nvim)

维护状态日期均由相应仓库的 GitHub 官方 API 和 release 页面于 2026-08-13 核对；外部项目的后续提交或发布会使该部分随时间变化。
