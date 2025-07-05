local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 外观设置
config.color_scheme = 'Guezwhoz'
config.colors = {
  background = '#000000',
}
-- 图片背景有bug
config.window_background_image = './res/wall.jpg'
config.window_background_opacity = 0.99
config.window_background_image_hsb = {
  hue = 1.0,
  saturation = 0.8,
  brightness = 0.005,  -- 降低亮度以免影响文字阅读
}

-- 光标配置
config.default_cursor_style = 'SteadyBlock'
config.force_reverse_video_cursor = true

-- 字体设置
config.font = wezterm.font('FiraCodeNerdFontCompleteMonoWindowsCompatible Nerd Font', { weight = 'Light' })
config.font_size = 11

-- 窗口设置
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = 'RESIZE'

-- 标签页设置
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- 滚动设置
config.enable_scroll_bar = false

-- 响铃设置
config.audible_bell = "Disabled"

-- 鼠标行为设置
config.mouse_bindings = {
  -- 右键单击粘贴剪贴板内容
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  }
}

-- 默认启动程序
-- config.default_prog = { 'ssh', 'dev-15' }

return config