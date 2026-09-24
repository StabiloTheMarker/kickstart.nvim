# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration based on kickstart.nvim. Core settings, keymaps, autocommands and most plugin definitions live in `init.lua`; additional plugins live in `lua/custom/plugins/`, with optional kickstart examples in `lua/kickstart/plugins/`. This is **not** a Neovim distribution but a starting point for personal configuration.

Line numbers drift as the config changes, so this file refers to sections by name — grep for them.

## Architecture

### Core Configuration Structure

- **`init.lua`**: Options, keymaps, autocommands, and the `require('lazy').setup({...})` plugin list (LSP, completion, formatting, treesitter, mini.nvim, which-key, colorscheme).
- **`lua/custom/plugins/*.lua`**: Plugin specs, auto-imported via `{ import = 'custom.plugins' }`. Every file here must return a lazy.nvim spec table — put plain helper modules elsewhere.
  - `init.lua`: snacks.nvim, fugitive, diffview, workspace-diagnostics, spectre, flash, autopairs, zen-mode, trouble, nvim-ufo, claudecode.nvim, csvview
  - `gitsigns.lua`: gitsigns with hunk keymaps
  - `markdown.lua`: markdown-preview.nvim
  - `lsp.lua`: commented-out leftovers, not active
- **`lua/custom/search.lua`**: Helper module (not a plugin spec) for the snacks grep/files pickers — result ranking and the filetype filter action.
- **`lua/custom/claude_changes.lua`** + **`bin/claude-nvim-hook`**: Tracks files Claude Code edits (see "Claude change tracking" below).
- **`lua/kickstart/plugins/*.lua`**: Optional kickstart examples, enabled by uncommenting their `require 'kickstart.plugins.<name>'` lines near the end of the lazy setup in `init.lua`. All are currently disabled.

### Plugin Management

- **lazy.nvim** is the plugin manager; plugins auto-install on first run.
- Versions are pinned in `lazy-lock.json`.

### LSP Configuration (Neovim 0.11+)

**IMPORTANT**: This config uses the Neovim 0.11+ `vim.lsp.config` API, not the deprecated `require('lspconfig')[name].setup()` pattern.

- Servers are configured in the `servers` table inside the `nvim-lspconfig` spec in `init.lua`, installed by **Mason** (mason.nvim v1.11.0, mason-lspconfig.nvim v1.32.0) via mason-tool-installer.
- Mason-managed servers: pyright, terraformls, tailwindcss, yamlls, intelephense, clangd, vtsls, volar, lua_ls, sqlls.
- The mason-lspconfig default handler does `vim.lsp.config[server_name] = server` + `vim.lsp.enable(server_name)`.
- Special handlers:
  - `volar` is registered as `vue_ls` (nvim-lspconfig renamed it).
  - `biome` LSP is disabled — biome is installed only as a formatter tool.
- Vue: vtsls handles TS/JS **and** `.vue` files through the `@vue/typescript-plugin` global plugin (loaded from Mason's vue-language-server package); vue_ls runs alongside for `.vue`.
- Non-Mason servers (installed externally): `nushell` (`nu --lsp`) and `rust_analyzer`.
- Completions: **blink.cmp** with **LuaSnip**.

### Search: snacks.picker (Telescope was removed)

All fuzzy finding uses `folke/snacks.nvim`'s picker (files via `fdfind`, grep via `rg`); LSP navigation keymaps are snacks pickers too. Customisations in the snacks spec in `lua/custom/plugins/init.lua`:

- **Grep ranking** (`grep`, `grep_word`, `grep_buffers`): `search.rank_grep` transform adds `score_add` per match — declarations boosted, comment lines/trailing comments and doc/lock files demoted. `matcher.sort_empty = true` is required because live grep has no fuzzy pattern; sort is `score:desc, idx` so ties keep rg's file grouping.
- **In-picker keys**: `<a-t>` filter by file type (rg `--type` for grep, extensions for files); `<a-c>` toggle `code_only` (hide comment matches) in grep. Inline rg args also work: `pattern -- -t py` or `pattern -- -g *.vue`.
- **Files**: frecency + cwd bonus enabled.

### Claude change tracking

`bin/claude-nvim-hook` is registered in `~/.claude/settings.json` as a PreToolUse/PostToolUse hook for `Edit|Write|MultiEdit|NotebookEdit`. When Claude runs in a Neovim terminal (`$NVIM` set) it calls `require('custom.claude_changes').hook(event, path, cwd)` via `nvim --server $NVIM --remote-expr`; outside Neovim it is a no-op. PreToolUse stores the file's content as the baseline (first edit only); PostToolUse reloads the buffer and, in follow mode, shows the change. Edits Claude makes through Bash (sed, scripts) are not seen — use git/Diffview for those. Test it by starting `nvim --headless --listen <sock>` and piping hook JSON into the script with `NVIM=<sock>`.

### Other Key Plugins

- **Treesitter**: syntax highlighting and code understanding
- **Conform.nvim**: formatting; format on save enabled except for C/C++
- **Mini.nvim**: statusline, surround, text objects
- **Which-key**: shows pending keybinds
- **snacks.nvim**: also provides the explorer (file tree), floating terminal (Fish when available), dashboard, `vim.ui.input`, smooth scroll
- **trouble.nvim**: diagnostics/symbols/quickfix lists
- **nvim-ufo**: folding with Treesitter/LSP providers and custom fold text
- **claudecode.nvim**: Claude Code integration

## Common Commands

### Plugin Management
```vim
:Lazy              " View plugin status
:Lazy update       " Update all plugins
:Lazy clean        " Remove unused plugins
:Lazy sync         " Install missing, clean unused, update plugins
```

### LSP & Tools
```vim
:Mason             " Open Mason UI to manage LSP servers/tools (press g? for help)
:checkhealth       " Check Neovim health (useful for debugging)
```

### Testing Configuration
```bash
nvim --headless +q 2>&1  # Test for startup errors
```
Pickers can be exercised headlessly too: open one with `Snacks.picker.grep({ search = '...', live = false })`, `vim.wait` until `not p:is_active()`, then read the sorted view with `p.list:get(i)` (`p.list.items` is unsorted arrival order).

## Key Mappings (Leader = Space)

### Search (snacks.picker)
- `<leader>sf`: Search files · `<leader>sa`: all files (hidden + ignored)
- `<leader>sg`: Live grep · `<leader>sw`: grep current word · `<leader>s/`: grep open buffers
- `<leader>sd`: Diagnostics · `<leader>sh`: Help · `<leader>sk`: Keymaps
- `<leader>sr`: Resume last picker · `<leader>s.`: Recent files · `<leader>ss`: Select picker
- `<leader><leader>`: Buffers · `<leader>/`: Fuzzy search in current buffer
- `<leader>sn`: Search Neovim config files

### LSP
- `grd` definition · `grr` references · `gri` implementation · `grt` type definition
- `grn` rename · `gra` code action
- `gO` document symbols · `gW` workspace symbols
- `<leader>th`: Toggle inlay hints

### Git
- `<leader>gh`: File history (snacks git log) · `<leader>gH`: File history (Diffview)
- `<leader>gd`: Diffview open · `<leader>gq`: Diffview close
- `<leader>h*`: gitsigns hunk actions (`hs` stage, `hr` reset, `hS` stage buffer, `hu` undo stage)
- `<leader>tb`: Toggle line blame

### Diagnostics (trouble / workspace-diagnostics)
- `<leader>xx`: Diagnostics · `<leader>xX`: Buffer diagnostics · `<leader>xQ`: Quickfix list
- `<leader>xw`: Populate workspace diagnostics
- `<leader>cs`: Symbols · `<leader>cl`: LSP definitions/references

### Claude Code (`<leader>a`)
- `ac` toggle · `af` focus · `ar` resume · `aC` continue · `am` select model
- `ab` add buffer · `as` send selection (visual) · `aa` / `ad` accept / deny diff
- `al` list Claude's changes (hunk picker, `<a-d>` side-by-side diff) · `av` diff current file vs. before Claude · `aF` toggle follow Claude edits · `ax` checkpoint (mark changes reviewed)
- `<C-a>f` (terminal): focus away from Claude

### Other Tools
- `<leader>tf`: Toggle file explorer (snacks)
- `<leader>tt`: Toggle floating terminal (snacks)
- `<leader>fg`: Find and replace (Spectre)
- `<leader>f`: Format buffer
- `<leader>zen`: Zen mode
- `<leader>rmt` / `<leader>rmp`: Markdown preview toggle / open
- `s`: Flash jump (normal/visual/operator) · `<C-s>` in cmdline: toggle Flash search

### Folding (nvim-ufo)
- `za`/`zo`/`zc`: toggle/open/close fold · `zR`/`zM`: open/close all · `zr`/`zm`: open/close one level

## Important Configuration Details

### Neovim 0.11+ Migration
When updating LSP configurations, always use `vim.lsp.config[server_name] = config_table` + `vim.lsp.enable(server_name)` instead of `require('lspconfig')[server_name].setup(config_table)`.

### Formatting (conform.nvim)
- lua → stylua · python → black · typescript/tsx/vue → prettier · php → mago_format · sql/mysql → sql_formatter
- Format on save for all filetypes except C/C++; LSP formatting as fallback
- A `phpfixer` formatter (`./bin/phpfixer`) is defined but not assigned to any filetype

### Shell
- The snacks terminal uses `fish` when it is executable, otherwise `vim.o.shell`.

## File Locations

- Config directory: `~/.config/nvim/`
- Plugin data: `~/.local/share/nvim/`
- Mason packages: `~/.local/share/nvim/mason/`
- Lazy plugins: `~/.local/share/nvim/lazy/`

## Extending Configuration

To add new plugins, create files in `lua/custom/plugins/` that return a table of plugin specifications; they are loaded automatically. For optional kickstart plugins, uncomment the relevant `require 'kickstart.plugins.<name>'` lines in `init.lua`.
