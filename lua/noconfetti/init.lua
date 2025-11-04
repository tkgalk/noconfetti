local M = {}

M.load = function(variant)
	variant = variant or 'light'
	if variant ~= 'light' and variant ~= 'dark' then
		variant = 'light'
	end

	local palette = require('noconfetti.palette')[variant]
	local groups = require('noconfetti.groups').setup(palette)

	for group, settings in pairs(groups) do
		vim.api.nvim_set_hl(0, group, settings)
	end
end

M.setup = function() end

return M
