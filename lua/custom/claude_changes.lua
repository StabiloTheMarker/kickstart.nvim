-- Track the files Claude Code edits from the terminal inside this Neovim.
-- bin/claude-nvim-hook (a Claude Code Pre/PostToolUse hook) calls M.hook over $NVIM:
-- before the first edit of a file its content is kept as the baseline, and after
-- every edit the buffer is reloaded (and, in follow mode, shown at the change).
local M = {}

M.base = {} ---@type table<string, string|false> path -> content before Claude's first edit (false = new file)
M.order = {} ---@type string[] paths in the order Claude first touched them
M.pre = {} ---@type table<string, string|false> path -> content right before the edit in progress
M.follow = false

---@return string|false
local function read(path)
  local f = io.open(path, 'rb')
  if not f then
    return false
  end
  local s = f:read '*a'
  f:close()
  return s
end

--- A normal file window in the current tab to show changes in, never the Claude terminal
local function target_win()
  local cur = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  table.insert(wins, 1, cur)
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == '' and vim.api.nvim_win_get_config(win).relative == '' then
      return win
    end
  end
end

--- Show `path` at the first line that changed between `old` and the file on disk
local function show(path, old)
  local win = target_win()
  if not win then
    return
  end
  local hunks = vim.diff(old or '', read(path) or '', { result_type = 'indices' }) --[[@as integer[][] ]]
  local line = hunks[1] and math.max(hunks[1][3], 1) or 1
  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)
  vim.bo[buf].buflisted = true
  vim.api.nvim_win_set_buf(win, buf)
  pcall(vim.api.nvim_win_set_cursor, win, { line, 0 })
  vim.api.nvim_win_call(win, function()
    vim.cmd 'normal! zz'
  end)
end

--- Called by the hook for every Edit/Write/MultiEdit/NotebookEdit.
---@param event 'PreToolUse'|'PostToolUse'
---@param path string
---@param cwd? string Claude's working directory, for relative paths
function M.hook(event, path, cwd)
  if not path:match '^/' and cwd then
    path = cwd .. '/' .. path
  end
  path = vim.fs.normalize(path)
  if event == 'PreToolUse' then
    local content = read(path)
    M.pre[path] = content
    if M.base[path] == nil then
      M.base[path] = content
      table.insert(M.order, path)
    end
  else
    local old = M.pre[path]
    M.pre[path] = nil
    vim.schedule(function()
      local buf = vim.fn.bufnr(path)
      if buf > 0 and vim.api.nvim_buf_is_loaded(buf) then
        vim.cmd.checktime(buf)
      end
      if M.follow then
        show(path, old)
      end
    end)
  end
  return 0
end

--- All of Claude's changes since the baseline, as one git-style unified diff
function M.diff_text()
  local root = vim.fn.getcwd()
  local out = {} ---@type string[]
  for _, path in ipairs(M.order) do
    local old, new = M.base[path], read(path)
    if old ~= new then
      local rel = vim.fs.relpath(root, path) or path
      out[#out + 1] = ('diff --git a/%s b/%s'):format(rel, rel)
      if not old then
        out[#out + 1] = 'new file mode 100644'
      end
      out[#out + 1] = old and ('--- a/' .. rel) or '--- /dev/null'
      out[#out + 1] = new and ('+++ b/' .. rel) or '+++ /dev/null'
      out[#out + 1] = (vim.diff(old or '', new or '', { ctxlen = 3 }) --[[@as string]]):gsub('\n$', '')
    end
  end
  return table.concat(out, '\n')
end

--- Picker with one entry per changed hunk; <cr> jumps there, the preview shows the diff
function M.pick()
  local text = M.diff_text()
  if text == '' then
    vim.notify('No changes by Claude since the last checkpoint', vim.log.levels.INFO)
    return
  end
  Snacks.picker.pick {
    title = 'Claude changes',
    cwd = vim.fn.getcwd(),
    finder = function(opts, ctx)
      return require('snacks.picker.source.diff').diff(vim.tbl_extend('force', opts, { diff = text }), ctx)
    end,
    format = 'file',
    preview = 'diff',
    actions = {
      side_by_side = function(picker, item)
        picker:close()
        M.diff_file(Snacks.picker.util.path(item))
      end,
    },
    win = { input = { keys = { ['<a-d>'] = { 'side_by_side', mode = { 'i', 'n' } } } } },
  }
end

--- Side-by-side diff (new tab) of a file against its content before Claude touched it
---@param path? string defaults to the current buffer
function M.diff_file(path)
  path = vim.fs.normalize(path or vim.api.nvim_buf_get_name(0))
  local old = M.base[path]
  if old == nil then
    vim.notify('Claude has not edited ' .. vim.fn.fnamemodify(path, ':~:.'), vim.log.levels.INFO)
    return
  end
  vim.cmd.tabedit(vim.fn.fnameescape(path))
  local ft = vim.bo.filetype
  vim.cmd 'diffthis'
  vim.cmd 'leftabove vnew'
  local buf = vim.api.nvim_get_current_buf()
  local text = (old or ''):gsub('\n$', '')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, '\n', { plain = true }))
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = ft
  vim.api.nvim_buf_set_name(buf, 'claude-base://' .. vim.fn.fnamemodify(path, ':~:.'))
  vim.cmd 'diffthis'
  vim.keymap.set('n', 'q', '<cmd>tabclose<cr>', { buffer = buf, desc = 'Close Claude diff' })
  vim.cmd 'wincmd l'
end

--- Treat everything Claude changed so far as reviewed
function M.checkpoint()
  M.base, M.order = {}, {}
  vim.notify 'Claude changes: checkpoint set'
end

function M.toggle_follow()
  M.follow = not M.follow
  vim.notify('Follow Claude edits: ' .. (M.follow and 'on' or 'off'))
end

return M
