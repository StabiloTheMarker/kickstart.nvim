-- Helpers for snacks.picker grep/files: rank code above comments & docs,
-- and filter results by file type from inside the picker.
local M = {}

-- Score adjustments on top of snacks' default score of 1000 (must stay > 0)
local DEFINITION_BONUS = 300
local COMMENT_PENALTY = -600
local DOC_FILE_PENALTY = -400

local doc_exts = { md = true, markdown = true, mdx = true, txt = true, rst = true, adoc = true, org = true }
local lock_names = { ['lazy-lock.json'] = true, ['package-lock.json'] = true, ['yarn.lock'] = true, ['pnpm-lock.yaml'] = true, ['composer.lock'] = true, ['poetry.lock'] = true, ['uv.lock'] = true, ['Cargo.lock'] = true, ['go.sum'] = true }

-- Line prefixes that start a whole-line comment
local line_comment = { '^//', '^/%*', '^%*', '^%-%-', '^<!%-%-', '^"""', "^'''", '^#[^%[!]' }
-- Preprocessor / attribute lines start with # but are code
local hash_code = { '^#include', '^#define', '^#if', '^#else', '^#endif', '^#pragma', '^#import', '^#region', '^#endregion' }
-- Trailing comment markers (need whitespace before, so `http://` does not count)
local trailing_comment = { '%s//', '%s#%s', '%s%-%-%s', '/%*' }

local definition_keywords = { 'function', 'def', 'class', 'fn', 'func', 'interface', 'type', 'struct', 'enum', 'trait', 'impl', 'const', 'let', 'var', 'local', 'export', 'public', 'private', 'protected', 'static', 'async' }

--- Is the match at byte column `col` (0-based) of `line` inside a comment?
local function in_comment(line, col)
  local trimmed = line:gsub('^%s+', '')
  for _, p in ipairs(hash_code) do
    if trimmed:find(p) then
      return false
    end
  end
  for _, p in ipairs(line_comment) do
    if trimmed:find(p) then
      return true
    end
  end
  local before = line:sub(1, col)
  for _, p in ipairs(trailing_comment) do
    if before:find(p) then
      return true
    end
  end
  return false
end

local function is_definition(line)
  local first = line:match '^%s*([%a_]+)'
  if not first then
    return false
  end
  for _, kw in ipairs(definition_keywords) do
    if first == kw then
      return true
    end
  end
  -- `name = function(` / `name: function`
  return line:find '^%s*[%w_%.:]+%s*[=:]%s*function' ~= nil
end

--- snacks.picker transform for grep results: demote comments, docs and lock files,
--- promote declarations. With `code_only` toggled on, comment matches are dropped.
function M.rank_grep(item, ctx)
  if not item.file then
    return
  end
  -- item.text is "<file>:<line>:<col>:<text>"
  local line = item.text:sub(#item.file + 2):match '^%d+:%d+:(.*)$' or ''
  local col = item.pos and item.pos[2] or 0
  local name = vim.fs.basename(item.file)
  local ext = name:match '%.([^.]+)$'

  local score = 0
  if in_comment(line, col) then
    if ctx.picker.opts.code_only then
      return false
    end
    score = score + COMMENT_PENALTY
  elseif is_definition(line) then
    score = score + DEFINITION_BONUS
  end
  if lock_names[name] or (ext and doc_exts[ext:lower()]) then
    score = score + DOC_FILE_PENALTY
  end
  item.score_add = score
end

local rg_types ---@type {name:string, globs:string[]}[]?

local function get_rg_types()
  if rg_types then
    return rg_types
  end
  rg_types = {}
  for _, l in ipairs(vim.fn.systemlist { 'rg', '--type-list' }) do
    local name, globs = l:match '^([^:]+):%s*(.*)$'
    if name then
      table.insert(rg_types, { name = name, globs = vim.split(globs, ',%s*') })
    end
  end
  return rg_types
end

--- Extensions (without dot) of an rg type's simple `*.ext` globs
local function type_exts(t)
  local exts = {}
  for _, g in ipairs(t.globs) do
    local e = g:match '^%*%.([%w_%-]+)$'
    if e then
      table.insert(exts, e)
    end
  end
  return exts
end

local function set_title(picker, label)
  picker.base_title = picker.base_title or picker.title
  picker.title = label and ('%s [%s]'):format(picker.base_title, label) or picker.base_title
  picker:update_titles()
end

--- Picker action: choose a file type to restrict results to.
--- Grep pickers use rg's `--type`; the files picker uses the type's extensions.
function M.filter_filetype(picker)
  local types = vim.deepcopy(get_rg_types())

  -- Put the type of the file you came from first
  local buf = vim.api.nvim_win_is_valid(picker.main) and vim.api.nvim_win_get_buf(picker.main)
  local cur_ext = buf and vim.api.nvim_buf_get_name(buf):match '%.([^./]+)$'
  if cur_ext then
    for i, t in ipairs(types) do
      if vim.tbl_contains(type_exts(t), cur_ext) then
        table.insert(types, 1, table.remove(types, i))
        break
      end
    end
  end
  table.insert(types, 1, { name = 'all', globs = { 'clear filter' } })

  Snacks.picker.select(types, {
    prompt = 'Filter by file type',
    format_item = function(t)
      return ('%-12s %s'):format(t.name, table.concat(t.globs, ', '))
    end,
  }, function(choice)
    if not choice or picker.closed then
      return
    end
    if choice.name == 'all' then
      picker.opts.ft = nil
      set_title(picker, nil)
    else
      picker.opts.ft = picker.opts.finder == 'files' and type_exts(choice) or choice.name
      set_title(picker, choice.name)
    end
    picker.list:set_target()
    picker:find()
    picker:focus 'input'
  end)
end

return M
