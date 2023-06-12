local api = require("tidal.api")
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
---@field boot TidalBootConfig
---@field mappings table
---@field highlightgroup string | nil

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
  mappings = {
    send_line = { mode = { "i", "n" }, key = "<S-CR>" },
    send_visual = { mode = { "x" }, key = "<S-CR>" },
    send_block = { mode = { "i", "n", "x" }, key = "<M-CR>" },
    send_node = { mode = "n", key = "<Leader><CR>" },
    send_hush = { mode = "n", key = "<leader><Esc>" },
  },
  selection_highlight = {
    higroup = "IncSearch",
    timeout = 150,
  },
}

local keymaps = {
  send_line = { callback = api.send_line, desc = "Send current line to tidal" },
  send_visual = {
    callback = [[<Esc><Cmd>lua require("tidal.api").send_visual()<CR>gv]],
    desc = "Send current visual selection to tidal",
  },
  send_block = { callback = api.send_block, desc = "Send current block to tidal" },
  send_node = { callback = api.send_node, desc = "Send current TS node to tidal" },
  send_hush = {
    callback = function()
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
          local command = keymaps[name]
          vim.keymap.set(mapping.mode, mapping.key, command.callback, { buffer = true, desc = command.desc })
        end
      end
    end,
  })
end

return M
