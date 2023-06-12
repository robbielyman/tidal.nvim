local boot = require("tidal.core.boot")
local message = require("tidal.core.message")
local state = require("tidal.core.state")
local notify = require("tidal.util.notify")
local util = require("tidal.util")
local select = require("tidal.util.select")
local highlight = require("tidal.util.highlight")
--- FIXME: cyclic imports
--
-- local config = require("tidal.config")
--
-- ---@param start { [1]: integer, [2]: integer } Start position {line, col}
-- ---@param finish { [1]: integer, [2]: integer } Finish position {line, col}
-- local function apply_highlight(start, finish)
--   highlight.apply_highlight(start, finish, {
--     higroup = config.selection_highlight,
--     timeout = config.timeout,
--   })
-- end
--
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
  local line = select.get_current_line()
  local text = line.lines[1]
  if #text > 0 then
    highlight.apply_highlight(line.start, line.finish)
    M.send(text)
  end
end

--- Send the last visual selection to the tidal interpreter
M.send_visual = function()
  local visual = select.get_visual()
  if visual then
    highlight.apply_highlight(visual.start, visual.finish)
    message.send_multiline(visual.lines)
  end
end

--- Send the current block to tidal interpreter
M.send_block = function()
  if util.is_empty(vim.api.nvim_get_current_line()) then
    return
  end
  local block = select.get_block()
  highlight.apply_highlight(block.start, block.finish)
  message.send_multiline(block.lines)
end

--- Send current TS block to tidal interpreter
function M.send_node()
  local block = select.get_node()
  if block then
    highlight.apply_highlight(block.start, block.finish)
    message.send_multiline(block.lines)
  end
end

return M
