# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration based on kickstart.nvim. It's a single-file configuration (`init.lua`) with optional modular plugins in `lua/custom/plugins/` and example plugins in `lua/kickstart/plugins/`. This is **not** a Neovim distribution but a starting point for personal configuration.

## Architecture

### Core Configuration Structure

- **`init.lua`**: The main configuration file (lines 1-332). All core settings, keymaps, autocommands, and plugin definitions are here. This is intentionally a single file for teaching purposes.
- **`lua/custom/plugins/*.lua`**: User's custom plugin configurations that extend the base setup
  - `init.lua`: Additional custom plugins (nvim-tree, toggleterm, flash.nvim, nvim-spectre, workspace-diagnostics, zen-mode)
  - `lsp.lua`: Currently empty but available for LSP overrides
- **`lua/kickstart/plugins/*.lua`**: Optional example plugins (autopairs, debug, gitsigns, indent_line, lint, neo-tree) that can be enabled by uncommenting them in init.lua:292-297

### Plugin Management

- Uses **lazy.nvim** as the plugin manager (setup at init.lua:240)
- Plugins are auto-installed on first run
- Custom plugins are imported via `{ import = 'custom.plugins' }` at init.lua:303

### LSP Configuration (Neovim 0.11+)

**IMPORTANT**: This config uses Neovim 0.11+ which requires the new `vim.lsp.config` API instead of the deprecated `require('lspconfig')` pattern.

- LSP setup is in init.lua:471-735
- Uses **Mason** for LSP/tool installation (mason.nvim v1.11.0, mason-lspconfig.nvim v1.32.0)
- Language servers configured in the `servers` table (init.lua:666-699):
  - pyright (Python)
  - terraformls (Terraform)
  - gopls (Go)
  - tailwindcss (CSS)
  - yamlls (YAML)
  - intelephense (PHP)
  - ts_ls (TypeScript)
  - volar (Vue.js with hybrid mode disabled)
  - lua_ls (Lua)
- LSP setup uses `vim.lsp.config[server_name] = server` pattern at init.lua:730 (NOT `require('lspconfig')[server_name].setup()`)
- Completions powered by **blink.cmp** with **LuaSnip** for snippets

### Key Plugins

- **Telescope**: Fuzzy finder for files, LSP symbols, diagnostics (init.lua:354-456)
- **Treesitter**: Syntax highlighting and code understanding (init.lua:241-281)
- **Conform.nvim**: Code formatting with formatters configured per filetype (init.lua:737-836)
  - Custom PHP formatter: `./bin/phpfixer` (configured at init.lua:758-763)
  - Format on save enabled (except for C/C++)
- **Mini.nvim**: Provides statusline, surround, and text objects (init.lua:204-240)
- **Which-key**: Displays pending keybinds (init.lua:294-345)

### Custom Plugin Highlights

- **nvim-tree**: File tree explorer (`<leader>tf` to toggle)
- **toggleterm**: Terminal integration (`<leader>tt`, uses Fish shell at `/run/current-system/sw/bin/fish`)
- **flash.nvim**: Fast navigation with `s` key
- **nvim-spectre**: Find and replace (`<leader>fg`)
- **workspace-diagnostics**: Workspace-wide diagnostics (`<leader>x`)
- **zen-mode**: Distraction-free writing (`<leader>zen`)

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
:LspInfo           " Show LSP client status
:checkhealth       " Check Neovim health (useful for debugging)
```

### Testing Configuration
```bash
nvim --headless +q 2>&1  # Test for startup errors
```

## Key Mappings (Leader = Space)

### Navigation & Search
- `<leader>sf`: Search files
- `<leader>sg`: Search by grep (live)
- `<leader>sw`: Search current word
- `<leader>sd`: Search diagnostics
- `<leader>sh`: Search help
- `<leader>/`: Fuzzy search in current buffer
- `<leader>sn`: Search Neovim config files

### LSP
- `grd`: Go to definition
- `grr`: Go to references
- `gri`: Go to implementation
- `grt`: Go to type definition
- `grn`: Rename symbol
- `gra`: Code action
- `grq`: Show documentation (hover)
- `gO`: Document symbols
- `gW`: Workspace symbols

### Custom Tools
- `<leader>tf`: Toggle file tree (nvim-tree)
- `<leader>ff`: Find current buffer in file tree
- `<leader>tt`: Toggle terminal (toggleterm)
- `<leader>fg`: Find and replace (Spectre)
- `<leader>x`: Populate workspace diagnostics
- `<leader>zen`: Toggle zen mode
- `<leader>f`: Format buffer
- `s`: Flash jump (in normal/visual/operator mode)

### Toggle
- `<leader>th`: Toggle inlay hints

## Important Configuration Details

### Neovim 0.11+ Migration
When updating LSP configurations, always use `vim.lsp.config[server_name] = config_table` instead of the old `require('lspconfig')[server_name].setup(config_table)` pattern. The lspconfig framework is deprecated as of Neovim 0.11.

### Shell Configuration
- On Windows: Uses PowerShell
- On Linux (this system): Uses Fish shell for integrated terminal (`/run/current-system/sw/bin/fish`)

### Formatting
- Format on save is enabled by default for most languages (init.lua:744-757)
- C and C++ have format-on-save disabled
- PHP uses custom formatter at `./bin/phpfixer` (must exist in project root)
- Manual formatting: `<leader>f`

### Volar (Vue) Configuration
The Vue language server (volar) has `hybridMode: false` and uses TypeScript SDK from `~/.local/share/.npm-global/lib/node_modules/typescript/lib` (init.lua:674-684).

## File Locations

- Config directory: `~/.config/nvim/`
- Plugin data: `~/.local/share/nvim/`
- Mason packages: `~/.local/share/nvim/mason/`
- Lazy plugins: `~/.local/share/nvim/lazy/`

## Extending Configuration

To add new plugins, create files in `lua/custom/plugins/` that return a table of plugin specifications. They will be automatically loaded via the import statement at init.lua:303.

For optional kickstart plugins, uncomment the relevant require statements at init.lua:292-297.
