local config = require("tidal.config")
local notify = require("tidal.util.notify")
local api = require("tidal.api")

local Tidal = {}

---Configure Tidal plugin
---@param options TidalConfig | nil
function Tidal.setup(options)
  -- TODO: Check version support
  if vim.fn.has("nvim-0.8.0") == 0 then
    notify.error("Tidal requires nvim >= 0.8.0")
    return
  end
  config.setup(options)
end

Tidal.api = api

return Tidal
