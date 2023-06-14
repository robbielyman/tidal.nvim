local M = {}

---@class TidalBootConfig
---@field tidal TidalProcConfig
---@field sclang TidalProcConfig
---@field split "v" | nil

---@class TidalProcConfig
---@field cmd string
---@field file string
---@field args table<string>
---@field enabled boolean

---@class TidalConfig
local defaults = {
  boot = {
    tidal = {
      cmd = "ghci",
      file = vim.api.nvim_get_runtime_file("bootfiles/BootTidal.hs", false)[1],
      args = {
        "-v0",
      },
      enabled = true,
    },
    sclang = {
      cmd = "sclang",
      file = vim.api.nvim_get_runtime_file("bootfiles/BootSuperDirt.scd", false)[1],
      args = {},
      enabled = false,
    },
    split = "v",
  },
  --- Default keymaps
  --- Set to false to disable all
  --- @type table | nil
  mappings = {
    send_line = { mode = { "i", "n" }, key = "<S-CR>" },
    send_visual = { mode = { "x" }, key = "<S-CR>" },
    send_block = { mode = { "i", "n", "x" }, key = "<M-CR>" },
    send_node = { mode = "n", key = "<Leader><CR>" },
    send_hush = { mode = "n", key = "<leader><Esc>" },
  },
  selection_highlight = {
    highlight = "IncSearch",
    timeout = 150,
  },
}

---@type TidalConfig
M.options = {}

M.namespace = vim.api.nvim_create_namespace("Tidal")

---Configure Tidal plugin
---@param options TidalConfig | nil
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
