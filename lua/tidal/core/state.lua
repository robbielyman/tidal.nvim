---@class TidalProcState
---@field buf? integer
---@field proc? integer

---@class TidalState
local state = {
  ---@type boolean
  launched = false,
  ---@type TidalProcState
  tidal = {},
  ---@type TidalProcState
  sclang = {},
}

return state
