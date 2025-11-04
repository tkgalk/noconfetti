local M = {}

M.setup = function(palette)
	local groups = {}

	-- Base
	groups.Normal = { fg = palette.fg, bg = palette.bg }
	groups.NormalFloat = { fg = palette.base1, bg = palette.base6 }
	groups.FloatBorder = { fg = palette.base1, bg = palette.base6 }
	groups.FloatTitle = { fg = palette.base1, bg = palette.base6, bold = true }
	groups.Title = { fg = palette.base1, bold = true }
	groups.NonText = { fg = palette.base2 }
	groups.Whitespace = { fg = palette.base4 }
	groups.Conceal = { fg = palette.base2 }

	-- UI
	groups.Cursor = { fg = palette.bg, bg = palette.fg }
	groups.CursorLine = { bg = palette.ui_cursorline }
	groups.LineNr = { fg = palette.ui_linenr }
	groups.Visual = { bg = palette.ui_visual }
	groups.StatusLine = { fg = palette.fg, bg = palette.ui_statusline }
	groups.StatusLineNC = { fg = palette.ui_linenr, bg = palette.ui_statusline }
	groups.WinSeparator = { fg = palette.ui_border }
	groups.Pmenu = { fg = palette.fg, bg = palette.ui_statusline }
	groups.PmenuSel = { fg = palette.fg, bg = palette.ui_visual }
	groups.PmenuSbar = { bg = palette.ui_border }
	groups.PmenuThumb = { bg = palette.ui_linenr }
	groups.TabLine = { fg = palette.ui_linenr, bg = palette.ui_statusline }
	groups.TabLineFill = { bg = palette.ui_statusline }
	groups.TabLineSel = { fg = palette.fg, bg = palette.bg }
	groups.Search = { fg = palette.bg, bg = palette.warning }
	groups.Folded = { fg = palette.ui_linenr, bg = palette.ui_cursorline }

	-- Syntax
	groups.Comment = { fg = palette.orange_fg, bg = palette.orange_bg, italic = false }
	groups.String = { fg = palette.green_fg, bg = palette.green_bg }
	groups.Constant = { fg = palette.teal_fg, bg = palette.teal_bg }
	groups.Number = { link = "Constant" }
	groups.Boolean = { link = "Constant" }
	groups.Identifier = { fg = palette.neutral }
	groups.Statement = { fg = palette.neutral }
	groups.Operator = { fg = palette.neutral }
	groups.Type = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups.Delimiter = { fg = palette.punctuation }
	groups.PreProc = { fg = palette.orange_fg, bg = palette.orange_bg }
	groups.Error = { fg = palette.error }

	-- Treesitter
	groups["@comment"] = { link = "Comment" }
	groups["@comment.error"] = { fg = palette.error, bold = true }
	groups["@comment.warning"] = { fg = palette.warning, bold = true }
	groups["@string.documentation"] = { link = "Comment" }
	groups["@keyword.jsdoc"] = { link = "Comment" }

	groups["@string"] = { link = "String" }
	groups["@string.special.symbol"] = { fg = palette.neutral }

	groups["@constant"] = { link = "Constant" }
	groups["@constant.builtin"] = { fg = palette.neutral }
	groups["@number"] = { link = "Constant" }
	groups["@boolean"] = { link = "Constant" }

	groups["@function"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@function.builtin"] = { fg = palette.neutral }
	groups["@function.call"] = { fg = palette.neutral }
	groups["@function.method"] = { link = "@function" }
	groups["@function.method.call"] = { fg = palette.neutral }

	groups["@variable"] = { fg = palette.neutral }
	groups["@variable.parameter.declaration"] = { fg = palette.blue_fg, bg = palette.blue_bg }

	groups["@keyword"] = { fg = palette.neutral }
	groups["@operator"] = { fg = palette.neutral }

	groups["@punctuation.delimiter"] = { fg = palette.punctuation }
	groups["@punctuation.bracket"] = { fg = palette.punctuation }

	groups["@type"] = { link = "Type" }
	groups["@type.python"] = { fg = palette.neutral }
	groups["@type.builtin.python"] = { fg = palette.neutral }
	groups["@type.rust"] = { fg = palette.neutral }
	groups["@type.builtin.rust"] = { fg = palette.neutral }

	groups["@constructor"] = { fg = palette.neutral }
	groups["@namespace"] = { fg = palette.neutral }
	groups["@module"] = { fg = palette.neutral }
	groups["@property"] = { fg = palette.neutral }

	groups["@tag"] = { link = "Type" }
	groups["@tag.attribute"] = { fg = palette.neutral }
	groups["@tag.delimiter"] = { fg = palette.punctuation }

	-- LSP
	groups["@lsp"] = { fg = palette.neutral }
	groups["@lsp.type.function"] = { fg = palette.neutral }
	groups["@lsp.typemod.function.declaration"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.method.declaration"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.variable.declaration"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.parameter.declaration"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.struct.declaration.rust"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.type.declaration.rust"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.typeAlias.declaration.rust"] = { fg = palette.purple_fg, bg = palette.purple_bg }

	-- Diagnostics
	groups.DiagnosticUnnecessary = { fg = palette.punctuation }
	groups.DiagnosticUnderlineUnnecessary = { sp = palette.bg, undercurl = false }

	-- Git
	groups.DiffAdd = { fg = palette.info }
	groups.DiffChange = { fg = palette.warning }
	groups.DiffDelete = { fg = palette.error }
	groups.GitSignsAdd = { fg = palette.info }
	groups.GitSignsChange = { fg = palette.warning }
	groups.GitSignsDelete = { fg = palette.error }

	return groups
end

return M
