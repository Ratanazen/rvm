-- lua/rvm/utils.lua
-- RVM Shared Helpers & Notification Utilities

local M = {}

--- Notify user with RVM branded header
--- @param msg string
--- @param level number|nil
--- @param opts table|nil
function M.notify(msg, level, opts)
  opts = opts or {}
  opts.title = opts.title or "RVM"
  vim.notify(msg, level or vim.log.levels.INFO, opts)
end

--- Format padded string for text UI
--- @param str string
--- @param len number
--- @param align string|nil "left"|"right"|"center"
--- @return string
function M.pad(str, len, align)
  str = tostring(str)
  local str_len = #str
  if str_len >= len then
    return str:sub(1, len)
  end
  local diff = len - str_len
  if align == "center" then
    local left = math.floor(diff / 2)
    local right = diff - left
    return string.rep(" ", left) .. str .. string.rep(" ", right)
  elseif align == "right" then
    return string.rep(" ", diff) .. str
  else
    return str .. string.rep(" ", diff)
  end
end

return M
