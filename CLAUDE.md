# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此仓库中工作时提供指引。

## 概述

基于 **LazyVim** (lazy.nvim) 的个人 Neovim 配置，所有配置位于 `nvim/` 目录下。

## 代码风格

- Lua，2 空格缩进，120 列宽（由 `nvim/stylua.toml` 约束）
- 格式化命令：`stylua nvim/`
- 模块模式：`local M = {}` ... `return M`
- 注释通常使用中文
- 插件选项通过 `vim.tbl_deep_extend("force", opts or {}, m_opts)` 合并

## 架构

### 入口

`nvim/init.lua` → `nvim/lua/config/lazy.lua` 引导 lazy.nvim 并加载 LazyVim 作为基础发行版。

### 目录结构

```
nvim/lua/
├── config/          # 核心配置（options、keymaps、autocmds）
│   ├── editor/      # 工具模块：gtag、fzf、buffer、版本控制、put、list
│   ├── lsp/         # LSP 初始化 + 自定义 DAP 断点系统
│   ├── ui/          # 调色板 + lualine 状态栏数据源
│   └── window/      # 窗口交换、quickfix 切换、浮动终端
└── plugins/         # lazy.nvim 插件规格（按类别组织）
    ├── editor/      # 导航、搜索、git、调试、多光标
    ├── lsp/         # 补全（blink.cmp）、格式化、lint、LSP 服务器
    ├── ui/          # 主题（gruvbox-material）、状态栏、bufferline、noice
    ├── window/      # quickfix、预览、tmux 导航、which-key
    └── lang/        # 语言相关：C++、Python、xmake
```

### 核心自定义模块

- **`config/editor/gtag.lua`**：异步 GNU Global 集成，支持增量更新和缓存
- **`config/editor/fzf.lua`**：FZF 工具集，含过滤搜索、grep、gtag 集成、目录选择
- **`config/editor/buffer.lua`**：窗口感知的智能 buffer 关闭，支持前一 buffer 回退
- **`config/editor/version.lua`**：Git/SVN 抽象层，统一 diff、blame、log、revert 操作
- **`config/lsp/dap.lua`**：基于 NUI 对话框和 extmark 的自定义断点管理
- **`config/ui/lualine.lua`**：条件化状态栏组件（LSP、DAP、treesitter、diff）

### 插件覆盖模式

插件扩展 LazyVim 默认配置。`plugins/` 中的自定义 spec 使用相同插件名来合并/覆盖 LazyVim 的 spec。`opts` 函数模式接收现有 opts 并进行深度扩展。

### 性能选择

- `syntax off`（依赖 treesitter）
- 禁用 matchparen
- 全局禁用动画
- Lualine 刷新防抖 666ms
