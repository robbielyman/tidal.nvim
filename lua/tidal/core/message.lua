local state = require("tidal.core.state")
local select = require("tidal.util.select")

local M = {}

--- Send a command to the tidal interpreter
---@param text string
function M.send(text)
  if not state.tidal.proc then
    return
  end
  vim.api.nvim_chan_send(state.tidal.proc, text .. "\n")
end

--- Send a multiline command to the tidal interpreter
---@param lines string[]
function M.send_multiline(lines)
  M.send(":{\n" .. table.concat(lines, "\n") .. "\n:}")
end

--- Send a text contained in a motion to the tidal interpreter
function M._send_motion()
  M.send_multiline(select.get_motion_text())
end

--- Enter operator pending mode to send text to tidal interpreter
function M.set_operator_pending()
  vim.o.operatorfunc = "v:lua.require'tidal.core.message'._send_motion"
  return "g@"
end

return M
