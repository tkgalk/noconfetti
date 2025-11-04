-- Development helper for hot reloading the noconfetti theme
-- Add this to your Neovim config during development

-- Hot reload function
local function reload_theme()
  -- Clear all loaded noconfetti modules
  for module_name, _ in pairs(package.loaded) do
    if module_name:match('^noconfetti') then
      package.loaded[module_name] = nil
    end
  end

  -- Reload the colorscheme
  local current_colorscheme = vim.g.colors_name
  if current_colorscheme and current_colorscheme:match('^noconfetti') then
    vim.cmd('colorscheme ' .. current_colorscheme)
    vim.notify('Theme reloaded: ' .. current_colorscheme, vim.log.levels.INFO)
  else
    vim.notify('No noconfetti theme currently loaded', vim.log.levels.WARN)
  end
end

-- Set up keybinding
vim.keymap.set('n', '<leader>tr', reload_theme, {
  desc = 'Reload noconfetti theme',
  silent = true
})

-- Also create a command for convenience
vim.api.nvim_create_user_command('ThemeReload', reload_theme, {
  desc = 'Reload noconfetti theme'
})

print('Noconfetti dev mode loaded. Use <leader>tr or :ThemeReload to reload the theme.')
