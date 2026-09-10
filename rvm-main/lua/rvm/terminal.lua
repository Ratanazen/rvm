-- lua/rvm/terminal.lua
-- RVM Responsive Terminal Engine (Root, CWD, Dynamic Resize, Shell Auto-detection)

local M = {}

M.active_terminals = {}

--- Auto-detect shell executable
--- @return string
function M.shell()
  local env_shell = os.getenv("SHELL")
  if env_shell and vim.fn.executable(env_shell) == 1 then
    return env_shell
  end
  local fallback = vim.o.shell or "bash"
  if vim.fn.executable(fallback) == 1 then
    return fallback
  end
  vim.notify("Configured shell not executable. Falling back to sh.", vim.log.levels.WARN, { title = "RVM Terminal" })
  return "sh"
end

--- Get relative window dimensions based on terminal columns
--- @return table { width: number, height: number }
function M.get_responsive_size()
  local cols = vim.o.columns
  if cols < 100 then
    return { width = 0.98, height = 0.90 }
  else
    return { width = 0.85, height = 0.80 }
  end
end

--- Open or toggle terminal at project root
function M.open_root()
  local root = vim.fn.getcwd()
  local lazy_ok, lazyvim = pcall(require, "lazyvim.util")
  if lazy_ok and lazyvim.root then
    root = lazyvim.root.get()
  end

  local snacks_ok, snacks = pcall(require, "snacks")
  if snacks_ok and snacks.terminal then
    local size = M.get_responsive_size()
    snacks.terminal.toggle(nil, {
      cwd = root,
      win = {
        style = "terminal",
        width = size.width,
        height = size.height,
        border = "single",
        title = false,
        wo = {
          winbar = "",
        },
      },
    })
  else
    vim.cmd("ToggleTerm direction=float cwd=" .. vim.fn.fnameescape(root))
  end
end

--- Open terminal at current working directory
function M.open_cwd()
  local cwd = vim.fn.getcwd()
  local snacks_ok, snacks = pcall(require, "snacks")
  if snacks_ok and snacks.terminal then
    local size = M.get_responsive_size()
    snacks.terminal.toggle(nil, {
      cwd = cwd,
      win = {
        style = "terminal",
        width = size.width,
        height = size.height,
        border = "single",
        title = false,
        wo = {
          winbar = "",
        },
      },
    })
  else
    vim.cmd("ToggleTerm direction=float cwd=" .. vim.fn.fnameescape(cwd))
  end
end

--- Resize terminal on VimResized event
function M.resize()
  local size = M.get_responsive_size()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      local config = vim.api.nvim_win_get_config(win)
      if config.relative and config.relative ~= "" then
        config.width = math.floor(vim.o.columns * size.width)
        config.height = math.floor(vim.o.lines * size.height)
        pcall(vim.api.nvim_win_set_config, win, config)
      end
    end
  end
end

--- List active terminal sessions
function M.list()
  local count = 0
  local list = { "RVM Active Terminals", "────────────────────────" }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      count = count + 1
      local name = vim.api.nvim_buf_get_name(buf)
      table.insert(list, string.format("Terminal %d: %s", count, name ~= "" and name or "shell"))
    end
  end
  if count == 0 then
    table.insert(list, "No active terminals.")
  end
  vim.notify(table.concat(list, "\n"), vim.log.levels.INFO, { title = "RVM Terminal List" })
end

--- Setup RVM terminal engine
function M.setup()
  -- Ensure terminal shell is set
  vim.o.shell = M.shell()
end

return M
