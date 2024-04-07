return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    local toggleterm = require 'toggleterm'
    vim.keymap.set('n', '<A-F12>', toggleterm.toggle)

    require('toggleterm').setup {}
  end,
}
