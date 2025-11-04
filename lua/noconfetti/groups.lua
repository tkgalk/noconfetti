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
	groups.WinBar = { fg = palette.fg, bg = palette.bg }
	groups.WinBarNC = { fg = palette.ui_linenr, bg = palette.bg }
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
	groups.Type = { fg = palette.neutral }
	groups.Special = { fg = palette.neutral }
	groups.Delimiter = { fg = palette.punctuation }
	groups.PreProc = { fg = palette.orange_fg, bg = palette.orange_bg }
	groups.Error = { fg = palette.error }

	-- Treesitter
	groups["@comment"] = { link = "Comment" }
	groups["@comment.error"] = { fg = palette.error, bold = true }
	groups["@comment.warning"] = { fg = palette.warning, bold = true }
	groups["@string.documentation"] = { link = "Comment" }
	groups["@keyword.jsdoc"] = { link = "Comment" }
	groups["@spell"] = { link = "Comment" }
	groups["@nospell"] = { link = "Comment" }

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

	groups["@constructor"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@namespace"] = { fg = palette.neutral }
	groups["@module"] = { fg = palette.neutral }
	groups["@property"] = { fg = palette.neutral }

	groups["@tag"] = { link = "Type" }
	groups["@tag.attribute"] = { fg = palette.neutral }
	groups["@tag.delimiter"] = { fg = palette.punctuation }

	-- Language-specific: Go
	groups["@type.definition.go"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@variable.parameter.go"] = { fg = palette.blue_fg, bg = palette.blue_bg }

	-- Language-specific: JavaScript/JSDoc
	groups["@punctuation.bracket.jsdoc"] = { link = "Comment" }
	groups["@lsp.typemod.class.declaration.javascript"] = { fg = palette.purple_fg, bg = palette.purple_bg }

	-- Language-specific: CSS
	groups["@function.css"] = { fg = palette.neutral }

	-- Language-specific: HTML
	groups["@markup.heading.html"] = { fg = palette.base1, bold = false }
	groups["@markup.heading.1.html"] = { fg = palette.base1, bold = false }
	groups["@markup.heading.2.html"] = { fg = palette.base1, bold = false }
	groups["@markup.heading.3.html"] = { fg = palette.base1, bold = false }
	groups["@markup.heading.4.html"] = { fg = palette.base1, bold = false }
	groups["@markup.heading.5.html"] = { fg = palette.base1, bold = false }
	groups["@markup.heading.6.html"] = { fg = palette.base1, bold = false }

	-- Language-specific: Markdown
	-- Headings (purple background like function definitions)
	groups["@markup.heading.markdown"] = { fg = palette.purple_fg, bg = palette.purple_bg, bold = true }
	groups["@markup.heading.1.markdown"] = { fg = palette.purple_fg, bg = palette.purple_bg, bold = true }
	groups["@markup.heading.2.markdown"] = { fg = palette.purple_fg, bg = palette.purple_bg, bold = true }
	groups["@markup.heading.3.markdown"] = { fg = palette.purple_fg, bg = palette.purple_bg, bold = true }
	groups["@markup.heading.4.markdown"] = { fg = palette.purple_fg, bg = palette.purple_bg, bold = true }
	groups["@markup.heading.5.markdown"] = { fg = palette.purple_fg, bg = palette.purple_bg, bold = true }
	groups["@markup.heading.6.markdown"] = { fg = palette.purple_fg, bg = palette.purple_bg, bold = true }

	-- Emphasis (keep neutral, just styled)
	groups["@markup.strong.markdown_inline"] = { fg = palette.fg, bold = true }
	groups["@markup.italic.markdown_inline"] = { fg = palette.fg, italic = true }
	groups["@markup.strikethrough.markdown_inline"] = { fg = palette.fg, strikethrough = true }

	-- Code (inline and blocks)
	groups["@markup.raw.markdown_inline"] = { fg = palette.teal_fg, bg = palette.teal_bg }
	groups["@markup.raw.block.markdown"] = { fg = palette.green_fg, bg = palette.green_bg }

	-- Links (blue background)
	groups["@markup.link.label.markdown_inline"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@markup.link.url.markdown_inline"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@markup.link.markdown_inline"] = { fg = palette.blue_fg, bg = palette.blue_bg }

	-- Lists (keep neutral)
	groups["@markup.list.markdown"] = { fg = palette.fg }
	groups["@markup.list.checked.markdown"] = { fg = palette.info }
	groups["@markup.list.unchecked.markdown"] = { fg = palette.fg }

	-- Quotes (green background like strings)
	groups["@markup.quote.markdown"] = { fg = palette.green_fg, bg = palette.green_bg, italic = true }

	-- Regular text should be neutral
	groups["@none.markdown"] = { fg = palette.fg }
	groups["@text.literal.markdown_inline"] = { fg = palette.fg }

	-- Spell checking in markdown should be neutral
	groups["@spell.markdown"] = { fg = palette.fg }

	-- Language-specific: C++ (LSP semantic tokens disabled due to inconsistency)
	-- Language-specific: Go (LSP semantic tokens disabled due to inconsistency)

	-- Language-specific: C
	groups["@lsp.typemod.macro.declaration.c"] = { fg = palette.teal_fg, bg = palette.teal_bg }
	groups["@lsp.typemod.macro.globalScope.c"] = { fg = palette.teal_fg, bg = palette.teal_bg }
	groups["@lsp.typemod.class.declaration.c"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.class.globalScope.c"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.function.declaration.c"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.function.definition.c"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.function.globalScope.c"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.type.parameter.c"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.parameter.declaration.c"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.parameter.definition.c"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.parameter.functionScope.c"] = { fg = palette.blue_fg, bg = palette.blue_bg }

	-- Language-specific: Python
	groups["@type.python"] = { fg = palette.neutral }
	groups["@type.builtin.python"] = { fg = palette.neutral }
	groups["@lsp.typemod.variable.readonly.python"] = { fg = palette.teal_fg, bg = palette.teal_bg }
	groups["@lsp.typemod.class.declaration.python"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.type.decorator.python"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.type.parameter.python"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.parameter.declaration.python"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.parameter.parameter.python"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.function.declaration.python"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.method.declaration.python"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.method.classMember.python"] = { fg = palette.purple_fg, bg = palette.purple_bg }

	-- Language-specific: Rust
	groups["@type.rust"] = { fg = palette.neutral }
	groups["@type.builtin.rust"] = { fg = palette.neutral }
	groups["@lsp.type.method.rust"] = { fg = palette.neutral }

	-- Language-specific: Ruby
	groups["@variable.parameter.ruby"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.class.declaration.ruby"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.namespace.declaration.ruby"] = { fg = palette.purple_fg, bg = palette.purple_bg }

	-- LSP
	groups["@lsp"] = { fg = palette.neutral }
	groups["@lsp.type.function"] = { fg = palette.neutral }
	groups["@lsp.typemod.function.declaration"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.method.declaration"] = { fg = palette.purple_fg, bg = palette.purple_bg }
	groups["@lsp.typemod.variable.declaration"] = { fg = palette.blue_fg, bg = palette.blue_bg }
	groups["@lsp.typemod.parameter.declaration"] = { fg = palette.blue_fg, bg = palette.blue_bg }

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

	-- mini.diff
	groups.MiniDiffSignAdd = { fg = palette.diff_add_fg, bg = palette.diff_add_bg }
	groups.MiniDiffSignChange = { fg = palette.diff_change_fg, bg = palette.diff_change_bg }
	groups.MiniDiffSignDelete = { fg = palette.diff_delete_fg, bg = palette.diff_delete_bg }
	groups.MiniDiffOverAdd = { link = "DiffAdd" }
	groups.MiniDiffOverChange = { link = "DiffChange" }
	groups.MiniDiffOverDelete = { link = "DiffDelete" }
	groups.MiniDiffOverContext = { link = "DiffText" }

	-- mini.pick
	groups.MiniPickBorder = { link = "FloatBorder" }
	groups.MiniPickBorderBusy = { link = "FloatBorder" }
	groups.MiniPickBorderText = { link = "FloatTitle" }
	groups.MiniPickIconDirectory = { link = "Directory" }
	groups.MiniPickIconFile = { fg = palette.fg }
	groups.MiniPickHeader = { link = "FloatTitle" }
	groups.MiniPickMatchCurrent = { fg = palette.fg, bg = palette.ui_visual }
	groups.MiniPickMatchMarked = { fg = palette.fg, bg = palette.purple_bg }
	groups.MiniPickMatchRanges = { fg = palette.accent, bold = true }
	groups.MiniPickNormal = { link = "NormalFloat" }
	groups.MiniPickPreviewLine = { link = "CursorLine" }
	groups.MiniPickPreviewRegion = { link = "Visual" }
	groups.MiniPickPrompt = { link = "FloatTitle" }

	-- File explorer
	groups.Directory = { fg = palette.fg }

	return groups
end

return M
