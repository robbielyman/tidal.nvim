local api = require("tidal.api")
local M = {}

---@class TidalBootConfig
---@field tidal TidalProcConfig
---@field sclang TidalProcConfig
---@field split "v"

---@class TidalProcConfig
---@field file string
---@field args table<string>
---@field enabled boolean

---@class TidalConfig
---@field boot TidalBootConfig
---@field mappings table
local defaults = {
  boot = {
    tidal = {
      file = vim.api.nvim_get_runtime_file("bootfiles/BootTidal.hs", false)[1],
      args = {},
      enabled = true,
    },
    sclang = {
      file = vim.api.nvim_get_runtime_file("bootfiles/BootSuperDirt.scd", false)[1],
      args = {},
      enabled = false,
    },
    split = "v",
  },
  mappings = {
    send_line = { mode = { "i", "n" }, key = "<S-CR>" },
    send_block = { mode = { "i", "n" }, key = "<M-CR>" },
    send_hush = { mode = "n", key = "<leader-Esc>" },
  },
}

local default_mappings = {
  send_line = { action = api.send_line, desc = "Send current line to tidal" },
  send_block = { action = api.send_block, desc = "Send current block to tidal" },
  send_hush = {
    action = function()
      api.send("hush")
    end,
    desc = "Send 'hush' to tidal",
  },
}

---@type TidalConfig
M.options = {}

---Configure Tidal plugin
---@param options TidalConfig | nil
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", defaults, options or {})
  vim.api.nvim_create_user_command("TidalLaunch", function()
    api.launch_tidal(M.options.boot)
  end, { desc = "Launch Tidal instance" })
  vim.api.nvim_create_user_command("TidalExit", api.exit_tidal, { desc = "Quit Tidal instance" })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.tidal" },
    callback = function()
      vim.api.nvim_buf_set_option(0, "filetype", "haskell")
      for name, mapping in pairs(M.options.mappings) do
        if mapping then
          local command = default_mappings[name]
          vim.keymap.set(mapping.mode, mapping.key, command.action, { buffer = true, desc = command.desc })
        end
      end
    end,
  })
end

return M
