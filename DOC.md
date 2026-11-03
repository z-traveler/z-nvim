# Z-Nvim 配置说明文档

基于 **LazyVim** 发行版的个人 Neovim 配置。以下文档涵盖所有自定义功能与快捷键。

> `<leader>` 默认为 `<space>`，`<A-x>` 表示 `Alt+x`，`<C-x>` 表示 `Ctrl+x`

---

## 目录

- [Codex / Claude Code Prompt Editor](#codex--claude-code-prompt-editor)
- [模式切换](#模式切换)
- [光标移动与编辑](#光标移动与编辑)
- [窗口管理](#窗口管理)
- [Buffer 管理](#buffer-管理)
- [文件搜索与导航（FZF）](#文件搜索与导航fzf)
- [代码导航（Treesitter 文本对象）](#代码导航treesitter-文本对象)
- [版本控制（Git/SVN）](#版本控制gitsvn)
- [LSP 功能](#lsp-功能)
- [代码补全（Blink）](#代码补全blink)
- [重构](#重构)
- [调试（DAP）](#调试dap)
- [文件浏览器](#文件浏览器)
- [终端](#终端)
- [Quickfix / Loclist](#quickfix--loclist)
- [符号与诊断（Trouble）](#符号与诊断trouble)
- [多光标](#多光标)
- [环绕操作（Surround）](#环绕操作surround)
- [快速跳转（Flash）](#快速跳转flash)
- [GNU Global（Gtags）](#gnu-globalgtags)
- [其他工具](#其他工具)
- [FZF 内部快捷键](#fzf-内部快捷键)
- [Which-Key 分组一览](#which-key-分组一览)

---

## Codex / Claude Code Prompt Editor

`omni-prompt-editor` 由 lazy.nvim 从 `z-traveler/omni-hooks` 安装；它和 markview 的提交都固定
在版本管理中的插件规格内。本仓库的 `lazy-lock.json` 按既有规则仅保留在本机，不提交。
按 `Ctrl+G` 打开临时输入文件时，上方显示只读回答，下方保留当前输入；默认在输入区左侧
显示固定宽度的历史 pane，不抢输入焦点。回答区与输入区仅在首次打开时分配尺寸，之后
浏览历史不再根据回答长短调整布局，手动调整的尺寸也会保留。两行条目为带独立颜色的序号、时间、可用提问和
回答摘要，不再补「回答」或「未完成／过程」标签。导航标题只保留 `7/8`，不附快捷键提示。
Pi 的 Ctrl+G 使用单独安装的 omni-hooks Pi bundle，但共享 Neovim 配色与 markview 渲染配置。

导航布局读取用户 env.json 的 `omni_hooks["prompt-editor"].history`：
`view` 为 `pane` / `float`，`target` 为 `input` / `answer`，`position` 在 pane 下为
`top` / `bottom` / `left` / `right`，在 float 下为
`top-left` / `top-right` / `bottom-left` / `bottom-right`。默认 `pane` / `input` / `left`。
Pi 的文件为 `~/.pi/agent/omni-hooks/env.json`；本机使用输入区右侧 pane，对应配置：

```json
{"omni_hooks":{"prompt-editor":{"history":{"view":"pane","target":"input","position":"right"}}}}
```

只合并此 namespace，保留已有 notify/diary 配置；重开 Ctrl+G 生效。

| 快捷键 | 作用范围 | 行为 |
|--------|----------|------|
| `<leader>sa` | Ctrl+G 输入 / 回答 buffer | 搜索本 session 的回答，原 `gH` 入口已移除 |
| `[a` / `]a` | Ctrl+G 输入 / 回答 buffer | 上一轮 / 下一轮回答，到头停止；不修改当前输入 |
| `j` / `k` | 历史 pane | 每次选择一个两行条目，支持次数，到头停止，不自动打开 |
| `Enter` | 历史 pane | 打开光标所在条目，两行均可；保留 pane 焦点以便继续浏览 |
| `Enter` | 历史搜索 picker | 在原回答窗口打开选中轮次，保持现有预览与接受方式 |
| `<leader>um` | Markdown buffer | 切换 markview 渲染 |

历史只模糊搜索回答正文，提问仅用于两行列表的辨认。正常代码 buffer 中的 `[a` / `]a` 仍为
Treesitter 参数导航。列表需要 fzf-lua 与 fzf >= 0.53；Markdown 渲染使用 markview.nvim，
不再启用 render-markdown.nvim。需要 `markdown`、`markdown_inline` Tree-sitter parser。
本配置在配色方案之后加载 markview；只读回答和搜索预览都会渲染 Markdown，关闭 hybrid 模式。
预览保留完整正文，并复用模糊匹配位置高亮、定位首个命中，不额外扫描历史。

新机器拉取配置后执行：

```bash
nvim --headless "+Lazy! update omni-prompt-editor markview.nvim" +qa
~/.codex/switch-config.sh <profile>
~/.claude/switch-settings.sh <profile> --force
```

后两条命令将各自的 static hook 配置重新生成到当前运行配置。运行时还需要 `bash`、`jq` 和 `ps`。
验证本机渲染器、parser、开关与 prompt-editor 固定版本：

```bash
nvim --headless '+lua dofile("scripts/test-markdown.lua")'
```

---

## 模式切换

在任何场景下快速退回 Normal 模式：

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `jk` / `Jk` / `JK` / `KJ` / `Kj` | Insert | 退出插入模式 |
| `v` | Visual | 退出可视模式 |
| `<Esc>` | Terminal | 退出终端模式 |

---

## 光标移动与编辑

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `H` | n/v | 跳到行首非空字符（等同 `^`） |
| `L` | n/v | 跳到行尾（等同 `$`） |
| `T` | n | 合并行（等同原生 `J`） |
| `` ` `` | n | 跳到标记行列（与 `'` 互换） |
| `'` | n | 跳到标记行（与 `` ` `` 互换） |
| `U` | n | 重做（等同 `<C-r>`） |
| `<Backspace>` | n | 清除搜索高亮 + 停止 snippet + 刷新 diff |
| `<` / `>` | v | 缩进后保持选区 |
| `;;` | n | 在行尾追加 `;` |
| `;;` | i | 在行尾追加 `;` 并换行 |
| `<C-l>` | i | 光标右移一个字符 |
| `,` / `.` / `;` | i | 输入字符并创建 undo 断点 |

---

## 窗口管理

### 窗口导航（vim-tmux-navigator）

与 tmux 无缝切换，在 Neovim 窗口和 tmux pane 之间统一使用：

| 快捷键 | 说明 |
|--------|------|
| `<A-h>` | 切换到左侧窗口 |
| `<A-j>` | 切换到下方窗口 |
| `<A-k>` | 切换到上方窗口 |
| `<A-l>` | 切换到右侧窗口 |
| `<A-w>` | 循环切换窗口 |

### 窗口操作

| 快捷键 | 说明 |
|--------|------|
| `<leader>wv` | 垂直分屏（左右） |
| `<leader>ws` | 水平分屏（上下） |
| `<leader>wj` | 三分屏 3:4:3 布局，聚焦中间 |
| `<leader>wH` | 将当前 buffer 移到最左窗口 |
| `<leader>wL` | 将当前 buffer 移到最右窗口 |
| `Q` | 关闭当前窗口（保存并退出） |

### 窗口大小调整

| 快捷键 | 说明 |
|--------|------|
| `<A-Up>` | 增加窗口高度 |
| `<A-Down>` | 减少窗口高度 |
| `<A-Left>` | 减少窗口宽度 |
| `<A-Right>` | 增加窗口宽度 |

---

## Buffer 管理

智能 buffer 关闭：自动回退到前一个 buffer，多窗口场景下只从当前窗口卸载而不删除 buffer。

| 快捷键 | 说明 |
|--------|------|
| `J` | 前一个 buffer |
| `K` | 后一个 buffer |
| `[b` / `]b` | 前/后一个 buffer（同上） |
| `q` | 智能关闭当前 buffer |
| `<leader>bd` | 删除其他所有 buffer |
| `<leader>bs` | 选择 scratch buffer |
| `<leader>bS` | 按目录排序 buffer |
| `<leader><space>` | FZF 切换 buffer（MRU 排序） |

---

## 文件搜索与导航（FZF）

### 文件查找

| 快捷键 | 说明 |
|--------|------|
| `<leader>ff` | 查找文件（排除 build/cache 等目录） |
| `<leader>fF` | 查找文件（项目根目录，不排除） |
| `<leader>fr` | 最近打开的文件 |

### 内容搜索（Grep）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>sg` | n | Grep 搜索（排除 build/cache 等目录） |
| `<leader>sg` | v | 选中文本 Grep 搜索（排除目录） |
| `<leader>sG` | n | Grep 搜索（项目根目录） |
| `<leader>sG` | v | 选中文本 Grep 搜索（项目根目录） |
| `<leader>sP` | n | 先选目录，再在选中目录中 Grep |

### 标签搜索（GNU Global）

| 快捷键 | 说明 |
|--------|------|
| `gh` | Gtags 符号搜索（支持定义/引用/上下文模式切换） |

Gtags 搜索打开后，可在 FZF 内用以下快捷键切换查询模式：
- `Ctrl-H`：切换 `--from-here`（从当前上下文搜索）
- `Ctrl-D`：切换 `-d`（仅定义）
- `Ctrl-R`：切换 `-r`（仅引用）

模式指示：🟢 激活 / ⚪ 未激活

### 其他

| 快捷键 | 说明 |
|--------|------|
| `<leader>sj` / `<leader>fj` | 恢复上次搜索（Resume） |
| `<leader>sH` | 帮助文档搜索 |
| `<leader>sK` | 快捷键搜索 |
| `<leader>sR` | AST 搜索替换（grug-far） |

---

## 代码导航（Treesitter 文本对象）

### 文本对象选择（Visual / Operator-pending 模式）

| 快捷键 | 说明 |
|--------|------|
| `af` / `if` | 选中函数（外部/内部） |
| `ac` / `ic` | 选中类（外部/内部） |
| `aa` / `ia` | 选中参数（外部/内部） |

示例：`daf` 删除整个函数，`via` 选中参数内部，`cic` 修改类内部。

### 代码间跳转

| 快捷键 | 说明 |
|--------|------|
| `<Down>` / `]m` | 跳到下一个函数/类 |
| `<Up>` / `[m` | 跳到上一个函数/类 |
| `<Right>` | 跳到下一个代码块/条件/循环/参数 |
| `<Left>` | 跳到上一个代码块/条件/循环/参数 |
| `]a` | 跳到下一个参数 |

### 增量选择

| 快捷键 | 说明 |
|--------|------|
| `vv` | 初始化增量选择 |
| `J`（增量选择中） | 扩大选区（节点递增） |
| `K`（增量选择中） | 缩小选区（节点递减） |
| `L`（增量选择中） | 扩大选区（作用域递增） |

示例：按 `vv` 开始，反复按 `J` 逐级扩大选区（单词 → 表达式 → 语句 → 函数体）。

### 浮窗预览

| 快捷键 | 说明 |
|--------|------|
| `gl` | 浮窗预览定义 |
| `gq` | 关闭所有预览浮窗 |

---

## 版本控制（Git/SVN）

自动检测 Git 或 SVN，统一操作接口。

### Hunk 导航与操作

| 快捷键 | 说明 |
|--------|------|
| `]v` | 跳到下一个变更块（Hunk） |
| `[v` | 跳到上一个变更块 |
| `<leader>vd` | 查看当前 Hunk 的 diff |
| `<leader>vD` | 查看整个文件的 diff |
| `<leader>vr` | 撤销当前 Hunk |
| `<leader>vR` | 撤销整个文件的修改 |

### Git 工具

| 快捷键 | 说明 |
|--------|------|
| `<leader>vg` | 打开 Lazygit |
| `<leader>vs` | Git Status（FZF） |
| `<leader>vc` | VCStatus 提交界面 |
| `<leader>vl` | 查看当前文件的提交历史 |
| `<leader>vb` | 查看当前文件的 blame |

FZF Git Status 内部快捷键：
- `Ctrl-F`：暂存/取消暂存文件
- `Ctrl-W`：重置文件修改

---

## LSP 功能

Inlay hints 在编辑时自动隐藏（InsertEnter 禁用，InsertLeave 恢复）。

### 代码导航

| 快捷键 | 说明 |
|--------|------|
| `gd` | 跳转到定义（LazyVim 默认） |
| `gr` | 查看引用（LazyVim 默认） |
| `gt` | 跳转到类型定义 |
| `gp` | 悬浮文档（Hover） |
| `gP` | 函数签名帮助 |

### LSP 操作

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>la` | n/v | 代码操作（Code Action） |
| `<leader>lA` | n | 源代码操作（Source Action） |
| `<leader>lc` | n/v | 运行 Codelens |
| `<leader>lC` | n | 刷新 Codelens |
| `<leader>lr` | n | 重命名符号 |
| `<leader>lR` | n | 重命名文件 |
| `<leader>lf` | n/v | 格式化代码 |
| `<leader>ld` | n | 显示行内诊断浮窗 |
| `<leader>ll` | n | 查看 LSP 信息 |
| `<leader>lm` | n | 打开 Mason（LSP 服务器管理） |

### C/C++ 专属

| 快捷键 | 说明 |
|--------|------|
| `<leader>lc` | 切换源文件/头文件 |

---

## 代码补全（Blink）

基于 blink.cmp 的 Rust 高性能补全引擎，集成 Minuet AI (Claude) 补全。

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<C-n>` | i | 选择下一项 / 显示补全菜单 |
| `<C-p>` | i | 选择上一项 |
| `<C-j>` | i | 确认选择 / snippet 跳转下一占位 |
| `<C-k>` | i | snippet 跳转上一占位 |
| `<C-e>` | i | 取消补全 |
| `<Enter>` | i | snippet 跳转下一占位 / 回车 |
| `<Tab>` | i | snippet 跳转下一占位 |
| `<S-Tab>` | i | snippet 跳转上一占位 |
| `<A-y>` | i | 触发 Minuet AI 补全（Claude） |

---

## 重构

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<leader>ri` | n/x | 内联变量（Inline Variable） |
| `<leader>rI` | n | 内联函数（Inline Function） |
| `<leader>re` | x | 提取函数（Extract） |
| `<leader>rv` | x | 提取变量（Extract Variable） |
| `vS` | n | 交换文本对象（ISwap） |

---

## 调试（DAP）

调试时自动启用鼠标，退出时自动禁用。断点使用 🐤 emoji 内联显示。

| 快捷键 | 说明 |
|--------|------|
| `<leader>dl` | 添加日志断点（输入日志消息） |
| `<leader>dk` | KK 条件断点 |
| `<leader>ds` | SS 条件断点 |
| `<leader>dS` | SSS 条件断点 |

> 断点类型 KK/SS/SSS 为自定义 GDB 断点命令，通过 NUI 对话框输入条件表达式。在已有断点的行再次操作将移除断点。

---

## 文件浏览器

基于 Snacks.explorer，显示隐藏文件和被忽略文件。

| 快捷键 | 说明 |
|--------|------|
| `<A-e>` | 打开文件浏览器（项目根目录） |
| `<A-E>` | 打开文件浏览器（当前工作目录） |

---

## 终端

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `<A-t>` | n | 打开终端（项目根目录） |
| `<A-t>` | t | 隐藏终端 |

---

## Quickfix / Loclist

仅 agent 产出的改动列表按文件聚合成树：文件名和改动数量只显示一次，下方保留每次修改的
行号与当前代码行，不再显示 write / edit 操作名；相同行重复修改也保留。代码预览优先读取
未保存的修改缓冲区，否则读取磁盘最新内容，并非历史 diff。空行或不可读取的源码有明确占位；
长行按窗口宽度裁切，完整上下文仍可通过 bqf 预览。文件名、数量、行号、层级线分别采用主题色，
代码保持正文色，选中项用背景强调。默认展开，文件组支持 `za` / `zo` / `zc` / `zM` / `zR`。
父节点是虚拟行，不占用真实 quickfix 索引，Enter、`[q` / `]q` 和 bqf 预览继续定位实际改动。
发送端按 agent/hook 的工作目录将真实目标解析为绝对路径；树节点仍尽可能显示相对编辑器
工作目录的路径，项目外文件保留完整路径，不用展示路径推断跳转目标。

普通搜索、诊断 quickfix 与 location list 不树化；离开 agent 列表时恢复原来的折叠选项和映射。
新改动会回到 producer 标记的原列表，不会追加进正在查看的普通列表。升级前未标记的列表
不会按标题猜测迁移；新一轮 agent 改动会创建树状列表。

本机配置与实际 nvim-bqf 的回归检查：

```bash
nvim --headless '+lua dofile("scripts/test-agent-quickfix.lua")'
```

| 快捷键 | 说明 |
|--------|------|
| `<leader>sQ` | 搜索 Quickfix 列表栈（原 `<leader>fQ` 已移除，其他 `<leader>f…` 不变） |
| `<A-q>` | 切换 Quickfix 窗口 |
| `<A-o>` | 切换 Location List 窗口 |
| `]q` / `[q` | Quickfix 下一项/上一项 |

---

## 符号与诊断（Trouble）

| 快捷键 | 说明 |
|--------|------|
| `<A-s>` | 切换符号大纲面板（Trouble Symbols） |

---

## 多光标

| 快捷键 | 说明 |
|--------|------|
| `<A-]>` | 添加光标到下一个匹配处 |
| `<A-[>` | 跳过当前匹配，回到上一个 |
| `<Esc>`（多光标激活时） | 启用/清除多光标 |

---

## 环绕操作（Surround）

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `gsa` | n/v | 添加环绕符号 |
| `gsd` | n/v | 删除环绕符号 |
| `gsc` | n/v | 替换环绕符号 |
| `gsh` | n/v | 高亮环绕符号 |

示例：`gsaiw"` 给单词加双引号，`gsd"` 删除最近的双引号，`gsc"'` 将双引号换成单引号。

---

## 快速跳转（Flash）

按 `s` 进入 Flash 跳转模式（LazyVim 默认），输入目标字符后按高亮标签直达。

> 此配置禁用了 Flash 的 `r`、`R`、`<C-s>` 映射。

---

## GNU Global（Gtags）

自动化的代码索引系统，支持 Python、JS/TS、C/C++、Rust、Go、Java。

- **自动更新**：保存文件时自动增量更新 Gtags 数据库（500ms 防抖）
- **缓存目录**：`~/.local/share/nvim/gtags/`（按项目隔离）
- **标签引擎**：`native-pygments`

| 命令 | 说明 |
|------|------|
| `:GtagsGenerate` | 强制重建整个 Gtags 数据库 |
| `:GtagsUpdate` | 手动增量更新 |
| `:GtagsInfo` | 显示 Gtags 配置和状态 |
| `:GtagsDebugToggle` | 开关调试日志 |

---

## 其他工具

### SSH / Windows 剪贴板

默认使用 `lemonade` 作为 SSH 到 Windows 场景的双向剪贴板 provider。启动时不探测 tunnel，因此先启动 Neovim、后建立或重建 tunnel 都不需要重启 Neovim。复制异步执行；粘贴最多等待 500ms。连接失败后进入 5 秒冷却期，冷却期间直接失败，下次操作再自动重试。

推荐链路：

```text
Windows clipboard <-> Windows lemonade server <-> SSH reverse tunnel <-> remote lemonade client <-> Neovim
```

Windows 侧启动 Lemonade server，并通过 SSH reverse tunnel 暴露给远端：

```powershell
lemonade.exe server
ssh -R 2489:127.0.0.1:2489 <remote>
```

远端需要有 `lemonade` client；`z-bootstrap` 会安装到 `~/.local/bin`：

```bash
command -v lemonade
lemonade paste
```

需要使用 `xsel + X11` 时，通过 `Z_NVIM_CLIPBOARD=xsel` 显式选择。`z-bootstrap` 的 `.bashrc.user` 会在 SSH 场景下从 `SSH_CLIENT` 派生 `DISPLAY`。

覆盖开关：

| 环境变量 | 说明 |
|----------|------|
| `Z_NVIM_CLIPBOARD=lemonade` | 显式选择 Lemonade |
| `Z_NVIM_CLIPBOARD=xsel` | 强制使用 `xsel + X11` |
| `Z_NVIM_CLIPBOARD=off` | 不设置自定义 clipboard provider |
| `Z_NVIM_LEMONADE_HOST=127.0.0.1` | Lemonade tunnel host |
| `Z_NVIM_LEMONADE_PORT=2489` | Lemonade tunnel port |

Neovim 内验证：

```vim
:checkhealth vim.provider
```

### 位置复制与跳转

| 快捷键 | 说明 |
|--------|------|
| `<leader>py` | 复制当前位置到剪贴板（格式：`File "path", line 123`） |
| `<leader>pp` | 从剪贴板解析 Python traceback 并跳转 |

`<leader>pp` 工作流程：复制一段 Python traceback → 按 `<leader>pp` → 自动解析所有 `File "...", line ...` → 单条直接跳转，多条进入 Quickfix 列表。

### 宏录制

| 快捷键 | 说明 |
|--------|------|
| `<leader>q` | 录制宏（原 `q` 被 buffer 关闭占用） |

### 性能分析

| 快捷键 | 说明 |
|--------|------|
| `<F1>` | 切换 Snacks Profiler |

### 插件管理

| 快捷键 | 说明 |
|--------|------|
| `<leader>P` | 打开 Lazy 插件管理界面 |

---

## FZF 内部快捷键

在 FZF 搜索窗口内使用：

| 快捷键 | 说明 |
|--------|------|
| `Ctrl-E` | 切换当前项选中状态 |
| `Ctrl-A` | 全选/全不选 |
| `Ctrl-P` / `Ctrl-N` | 上/下选择 |
| `Up` / `Down` | 翻阅搜索历史 |
| `Ctrl-B` / `Ctrl-F` | 预览区上/下翻页 |

---

## Which-Key 分组一览

按 `<leader>` 后等待 666ms 显示快捷键提示面板：

| 前缀 | 分组 | 图标 |
|------|------|------|
| `<leader>l` | LSP | 󱚡 |
| `<leader>v` | 版本控制 | |
| `<leader>p` | Put（位置工具） | |
| `<leader>c` | 自定义 | |
| `<leader>b` | Buffer | |
| `<leader>d` | 调试 | |
| `<leader>f` | 文件 | |
| `<leader>s` | 搜索 | |
| `<leader>r` | 重构 | |
| `<leader>w` | 窗口 | |
