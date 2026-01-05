local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	return ""
end)

return {
	default_prog = { "zsh", "-l", "-c", "tmux attach -t default || tmux new -s default" },

	-- set_environment_variables = {
	-- 	TERM = "xterm-256color",
	-- },

	enable_tab_bar = false,
	force_reverse_video_cursor = true,

	-- window_background_image = "/Users/miraxsage/Downloads/unnamed.jpg",

	window_padding = {
		left = 5,
		right = 5,
		top = 7,
		bottom = 0,
	},
	window_decorations = "TITLE | RESIZE",
	macos_window_background_blur = 20,
	window_background_opacity = 0.96,

	color_scheme = "Catppuccin Mocha",
	colors = {
		selection_bg = "#1e1e2e",
		selection_fg = "#cdd6f4",
		ansi = {
			"#45475a",
			"#f38ba8",
			"#a6e3a1",
			"#f9e2af",
			"#89b4fa",
			"#f5c2e7",
			"#94e2d5",
			"#bac2de",
		},
		brights = {
			"#585b70",
			"#f38ba8",
			"#a6e3a1",
			"#f9e2af",
			"#89b4fa",
			"#f5c2e7",
			"#94e2d5",
			"#a6adc8",
		},
	},

	foreground_text_hsb = {
		hue = 1,
		saturation = 1,
		brightness = 1,
	},

	font = wezterm.font({
		family = "CaskaydiaCove Nerd Font",
		weight = 400,
	}),
	font_size = 16.3,
	font_rules = {
		{
			italic = true,
			intensity = "Normal",
			font = wezterm.font("Victor Mono", { style = "Italic", weight = 700 }),
		},
		{
			italic = true,
			intensity = "Bold",
			font = wezterm.font("Victor Mono", { style = "Italic", weight = 700 }),
		},
	},
}
