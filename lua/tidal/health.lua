local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local error = vim.health.error or vim.health.report_error

local ts = vim.treesitter

function M.check()
  start("tidal.nvim")

  if vim.fn.has("nvim-0.8.0") == 1 then
    ok("Using Neovim >= 0.8.0")
  else
    error("Neovim >= 0.8.0 is required")
  end

  for _, cmd in ipairs({ "ghci", "sclang" }) do
    local name = cmd
    local found = false
    if vim.fn.executable(cmd) == 1 then
      name = cmd
      found = true
    end

    if found then
      ok(("`%s` is installed"):format(name))
    else
      warn(("`%s` is not installed"):format(name))
    end

    -- Check for TS parser for Haskell
    local parsers = vim.api.nvim_get_runtime_file("parser/haskell.so", true)
    if not #parsers == 1 then
      warn("Multiple haskell parsers found: " .. table.concat(parsers, "\n"))
    end
    local parser = parsers[1]
    local parsername = vim.fn.fnamemodify(parser, ":t:r")
    local is_loadable, err_or_nil = pcall(ts.language.add, "haskell")
    if not is_loadable then
      error(string.format('Parser "%s" failed to load (path: %s): %s', parsername, parser, err_or_nil or "?"))
    else
      local lang = ts.language.inspect(parsername)
      ok(string.format("Parser: %-10s ABI: %d, path: %s", parsername, lang._abi_version, parser))
    end
  end
end

return M
