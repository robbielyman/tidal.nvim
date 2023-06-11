local M = {}

---@param mode "visual" | "motion"
---@return table
local function linewise(mode)
  local start_char, end_char = unpack(({
    visual = { "<", ">" },
    motion = { "[", "]" },
  })[mode])

  -- Get the start and the end of the selection
  local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, start_char))
  local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, end_char))
  local selected_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  return {
    start_pos = { start_line, start_col },
    end_pos = { end_line, end_col },
    selected_lines = selected_lines,
  }
end

local function get_visual(res)
  local mode = vim.fn.visualmode()
  -- line-visual
  -- return lines encompassed by the selection; already in res object
  if mode == "V" then
    return res.selected_lines
  end

  if mode == "v" then
    -- regular-visual
    -- return the buffer text encompassed by the selection
    local start_line, start_col = unpack(res.start_pos)
    local end_line, end_col = unpack(res.end_pos)
    -- exclude the last char in text if "selection" is set to "exclusive"
    if vim.opt.selection:get() == "exclusive" then
      end_col = end_col - 1
    end
    return vim.api.nvim_buf_get_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, {})
  end

  -- block-visual
  -- return the lines encompassed by the selection, each truncated by the start and end columns
  if mode == "\x16" then
    local _, start_col = unpack(res.start_pos)
    local _, end_col = unpack(res.end_pos)
    -- exclude the last col of the block if "selection" is set to "exclusive"
    if vim.opt.selection:get() == "exclusive" then
      end_col = end_col - 1
    end
    -- exchange start and end columns for proper substring indexing if needed
    -- e.g. instead of str:sub(10, 5), do str:sub(5, 10)
    if start_col > end_col then
      start_col, end_col = end_col, start_col
    end
    -- iterate over lines, truncating each one
    return vim.tbl_map(function(line)
      return line:sub(start_col, end_col)
    end, res.selected_lines)
  end
end

--- Get the current visual selection
---@return string[]
function M.get_visual_text()
  local res = linewise("visual")
  return get_visual(res)
end

--- Get selection encompassed by the motion marked by '[, ']
---@return string[]
function M.get_motion_text()
  -- FIXME: currently only works for linewise motions
  local res = linewise("motion")
  return res.selected_lines
end

return M
