local M = {}

local api = vim.api

local hl_ns = api.nvim_create_namespace("hltidal")
local hl_timer

--- Apply a transient highlight to a range in the current buffer
---@param start { [1]: integer, [2]: integer } Start position {line, col}
---@param finish { [1]: integer, [2]: integer } Finish position {line, col}
---@param opts? table
function M.apply_highlight(start, finish, opts)
  opts = opts or {}
  local event = opts.event or vim.v.event
  local higroup = opts.higroup or "IncSearch"
  local timeout = opts.timeout or 150

  local bufnr = api.nvim_get_current_buf()
  api.nvim_buf_clear_namespace(bufnr, hl_ns, 0, -1)
  if hl_timer then
    hl_timer:close()
  end

  vim.highlight.range(
    bufnr,
    hl_ns,
    higroup,
    start,
    finish,
    { regtype = event.regtype, inclusive = event.inclusive, priority = vim.highlight.priorities.user }
  )

  hl_timer = vim.defer_fn(function()
    hl_timer = nil
    if api.nvim_buf_is_valid(bufnr) then
      api.nvim_buf_clear_namespace(bufnr, hl_ns, 0, -1)
    end
  end, timeout)
end

return M
