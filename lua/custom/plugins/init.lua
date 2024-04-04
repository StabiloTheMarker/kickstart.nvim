-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

return { nvim_tree = require 'custom.plugins.nvim-tree', nvim_jdtls = require 'custom.plugins.nvim-jdtls', terminal = require 'custom.plugins.terminal' }
