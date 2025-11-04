vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then
	vim.cmd('syntax reset')
end

vim.o.termguicolors = true
vim.g.colors_name = 'noconfetti-light'

require('noconfetti').load('light')
