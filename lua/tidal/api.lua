local boot = require("tidal.core.boot")
local message = require("tidal.core.message")
local state = require("tidal.core.state")
local notify = require("tidal.util.notify")

local M = {}

--- Begin a Tidal session
--- Will start an sclang instance if specified in config
---@param args TidalBootConfig
function M.launch_tidal(args)
  local current_win = vim.api.nvim_get_current_win()
  if state.launched then
    notify.warn("Tidal is already running")
    return
  end
  if args.tidal.enabled then
    vim.cmd(args.split == "v" and "vsplit" or "split")
    boot.tidal(args.tidal)
  end
  if args.sclang.enabled then
    vim.cmd(args.split == "v" and "split" or "vsplit")
    boot.sclang(args.sclang)
  end
  vim.api.nvim_set_current_win(current_win)
  state.launched = true
end

--- Quit Tidal session
function M.exit_tidal()
  if not state.launched then
    notify.warn("Tidal is not running. Launch with ':TidalLaunch'")
    return
  end
  if state.tidal.proc then
    vim.fn.jobstop(state.tidal.proc)
  end
  if state.sclang.proc then
    vim.fn.jobstop(state.sclang.proc)
  end
  state.launched = false
end

M.send = message.send

--- Send the current line to the tidal interpreter
M.send_line = function()
  M.send(vim.api.nvim_get_current_line())
end

--- Send the current block to tidal interpreter
M.send_block = function()
  -- FIXME: Hack
  vim.api.nvim_feedkeys(message.set_operator_pending(), "n", false)
  -- motion to select inner paragraph
  vim.api.nvim_feedkeys("ip", "n", false)
end

--- Send current TS block to tidal interpreter
function M.send_node()
  local node = vim.treesitter.get_node()
  local root
  if node then
    root = node:tree():root()
  end
  if not root then
    return
  end
  local parent
  if node then
    parent = node:parent()
  end
  while node ~= nil and node ~= root do
    local t = node:type()
    if t == "top_splice" then
      break
    end
    node = parent
    if node then
      parent = node:parent()
    end
  end
  if not node then
    return
  end
  local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(node)
  local lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
  message.send_multiline(lines)
end

return M
