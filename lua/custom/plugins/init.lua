-- You can add your own plugins here or in other files in this directory! I promise not to create any merge conflicts in this directory :) See the kickstart.nvim README for more information
if vim.loop.os_uname().sysname == 'Windows_NT' then
  -- Windows-specific shell (PowerShell)
  vim.opt.shell = 'powershell'
  vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.opt.shellquote = ''
  vim.opt.shellxquote = ''
end
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.keymap.set('n', 'grq', vim.lsp.buf.hover, { desc = 'Show Documentation' })

return {
  -- Git integration with fugitive
  {
    'tpope/vim-fugitive',
  },
  -- Git file history (using snacks picker git log)
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gh', function()
        Snacks.picker.git_log { current_file = true }
      end, { desc = '[G]it File [H]istory' })
    end,
  },
  -- Diffview for comprehensive git diff viewing
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('diffview').setup {
        use_icons = true,
        watch_index = false,
      }

      -- Keymaps for diffview
      vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff View' })
      vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory %<CR>', { desc = '[G]it File [H]istory (Diffview)' })
      vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<CR>', { desc = '[G]it Diffview [Q]uit' })
    end,
  },
  {
    'artemave/workspace-diagnostics.nvim',
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>xw', '', {
        noremap = true,
        callback = function()
          for _, client in ipairs(vim.lsp.get_clients()) do
            require('workspace-diagnostics').populate_workspace_diagnostics(client, 0)
          end
        end,
      })
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('spectre').setup()

      -- Optional: Map <leader>fg to open Spectre
      vim.keymap.set('n', '<leader>fg', function()
        require('spectre').open()
      end, { desc = 'Open Spectre - Find and Replace' })
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode= { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  },
  -- NOTE: File explorer provided by snacks.nvim explorer (see snacks config above)
  -- NOTE: Terminal provided by snacks.nvim (see snacks config above)
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },
  {
    'folke/zen-mode.nvim',
    config = function()
      require('zen-mode').setup {
        vim.keymap.set('n', '<leader>zen', '<cmd>ZenMode<CR>'),
        window = {
          width = 120, -- width of the focused code area
          options = {
            number = true,
            relativenumber = true,
          },
        },
      }
    end,
  },
  -- Better vim.ui.input (replaces default input prompt with a nice floating window)
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      input = { enabled = true },
      picker = { enabled = true },
      explorer = { enabled = true },
      scroll = { enabled = true },
      dashboard = {
        preset = {
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ':lua Snacks.picker.files()' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ':lua Snacks.picker.grep()' },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ':lua Snacks.picker.recent()' },
            { icon = ' ', key = 'c', desc = 'Config', action = ':lua Snacks.picker.files({ cwd = vim.fn.stdpath("config") })' },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
            { icon = ' ', key = 'm', desc = 'Mason', action = ':Mason' },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
        sections = {
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          { section = 'recent_files', title = 'Recent Files', limit = 5, padding = 1 },
          { section = 'startup' },
        },
      },
      terminal = {
        shell = vim.fn.executable 'fish' == 1 and 'fish' or vim.o.shell,
        win = { style = 'float' },
      },
    },
    keys = {
      { '<leader>sh', function() Snacks.picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sf', function() Snacks.picker.files() end, desc = '[S]earch [F]iles' },
      { '<leader>sa', function() Snacks.picker.files({ hidden = true, ignored = true }) end, desc = '[S]earch [A]ll files (hidden + ignored)' },
      { '<leader>ss', function() Snacks.picker.pickers() end, desc = '[S]earch [S]elect Picker' },
      { '<leader>sw', function() Snacks.picker.grep_word() end, desc = '[S]earch current [W]ord' },
      { '<leader>sg', function() Snacks.picker.grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() Snacks.picker.resume() end, desc = '[S]earch [R]esume' },
      { '<leader>s.', function() Snacks.picker.recent() end, desc = '[S]earch Recent Files' },
      { '<leader><leader>', function() Snacks.picker.buffers() end, desc = '[ ] Find existing buffers' },
      { '<leader>/', function() Snacks.picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', function() Snacks.picker.grep_buffers() end, desc = '[S]earch [/] in Open Files' },
      { '<leader>sn', function() Snacks.picker.files({ cwd = vim.fn.stdpath 'config' }) end, desc = '[S]earch [N]eovim files' },
      -- LSP pickers
      { 'grd', function() Snacks.picker.lsp_definitions() end, desc = '[G]oto [D]efinition' },
      { 'grr', function() Snacks.picker.lsp_references() end, desc = '[G]oto [R]eferences' },
      { 'gri', function() Snacks.picker.lsp_implementations() end, desc = '[G]oto [I]mplementation' },
      { 'grt', function() Snacks.picker.lsp_type_definitions() end, desc = '[G]oto [T]ype Definition' },
      { 'gO', function() Snacks.picker.lsp_symbols() end, desc = 'Open Document Symbols' },
      { 'gW', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Open Workspace Symbols' },
      { '<leader>tf', function() Snacks.explorer() end, desc = '[T]oggle File Tree' },
      { '<leader>ff', function() Snacks.explorer.reveal() end, desc = '[F]ind current buffer in FileTree' },
      { '<leader>tt', function() Snacks.terminal.toggle() end, desc = '[T]oggle [T]erminal', mode = { 'n', 't' } },
    },
  },
  -- Diagnostics list
  {
    'folke/trouble.nvim',
    opts = {},
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle focus=false win.size=0.3<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions/References (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
    },
  },
  -- Code folding with nvim-ufo
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
    },
    config = function()
      -- Custom fold text display - shows first line with fold indicator
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d lines'):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      require('ufo').setup {
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          -- Use treesitter as primary fold provider, LSP as fallback
          return { 'treesitter', 'indent' }
        end,
      }

      -- Using ufo provider need remap `zR` and `zM`.
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds (one level)' })
      vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Close folds (one level)' })
    end,
  },
}
