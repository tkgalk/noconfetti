local M = {}

M.light = {
	bg = "#f7f3ee",
	fg = "#605a52",

	base1 = "#605a52",
	base2 = "#93836c",
	base3 = "#b9a992",
	base4 = "#dcd3c6",
	base5 = "#e4ddd2",
	base6 = "#f1ece4",
	base7 = "#f7f3ee",

	ui_border = "#dcd3c6",
	ui_visual = "#e4ddd2",
	ui_cursorline = "#f1ece4",
	ui_statusline = "#f1ece4",
	ui_linenr = "#b9a992",
	ui_selection = "#e4ddd2",

	orange_fg = "#5b5143",
	orange_fg_sec = "#957f5f",
	orange_bg = "#f7e0c3",

	green_fg = "#525643",
	green_fg_sec = "#81895d",
	green_bg = "#e2e9c1",

	teal_fg = "#465953",
	teal_fg_sec = "#5f8c7d",
	teal_bg = "#d2ebe3",

	blue_fg = "#4c5361",
	blue_fg_sec = "#7382a0",
	blue_bg = "#dde4f2",

	purple_fg = "#614c61",
	purple_fg_sec = "#9c739c",
	purple_bg = "#f1ddf1",

	accent = "#6a4cff",
	neutral = "#605a52",
	punctuation = "#b9a992",

	error = "#ff1414",
	warning = "#f2a60d",
	info = "#52aeff",
	hint = "#93836c",

	-- Git diff colors
	diff_add_fg = "#3d5c3d",
	diff_add_bg = "#d4edd4",
	diff_change_fg = "#3d4d5c",
	diff_change_bg = "#d4e4ed",
	diff_delete_fg = "#5c3d3d",
	diff_delete_bg = "#edd4d4",
}

M.dark = {
	bg = "#1a1a1a",
	fg = "#e0e0e0",

	base1 = "#e0e0e0",
	base2 = "#b0b0b0",
	base3 = "#808080",
	base4 = "#505050",
	base5 = "#3a3a3a",
	base6 = "#242424",

	ui_border = "#3a3a3a",
	ui_visual = "#3a3a3a",
	ui_cursorline = "#242424",
	ui_statusline = "#242424",
	ui_linenr = "#808080",
	ui_selection = "#3a3a3a",

	orange_fg = "#d2a680",
	green_fg = "#a0c980",
	teal_fg = "#85c0b0",
	blue_fg = "#80b0d0",
	purple_fg = "#c090c0",

	accent = "#8080ff",
	neutral = "#e0e0e0",
	punctuation = "#808080",

	error = "#ff5252",
	warning = "#f0a040",
	info = "#80b0d0",
	hint = "#808080",

	-- Git diff colors
	diff_add_fg = "#90c090",
	diff_change_fg = "#90b0d0",
	diff_delete_fg = "#d09090",
}

return M
