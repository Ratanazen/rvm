-- src/whichkey.lua
-- LazyVim-style Which-Key popup.
-- When the user presses <leader> (default: Space), we display a grouped menu.
-- Two-key chords: <leader>ff (find files), <leader>fg (live grep), etc.
--
-- This module is the registry + render logic. It is consumed by `keybindings.lua`.

local WhichKey = {}
WhichKey.__index = WhichKey

-- ─────────────────────────────────────────────────────────
-- Registry: top-level groups (single char shown when leader pressed)
-- Each group has: label, icon, entries = { [chord] = { label = ..., action = ... } }
-- ─────────────────────────────────────────────────────────
WhichKey.groups = {
  f = { label = "Find",   icon = "󰍉", desc = "Telescope-like finders" },
  g = { label = "Git",    icon = "󰊢", desc = "Git workflow" },
  b = { label = "Buffers", icon = "󰓩", desc = "Buffer operations" },
  p = { label = "Projects", icon = "󰉋", desc = "Project management" },
  l = { label = "LSP",    icon = "󰌵", desc = "Language server" },
  x = { label = "Diagnostics", icon = "󰅙", desc = "Diagnostics panel" },
  t = { label = "Terminal", icon = "󰆍", desc = "Terminal panel" },
  e = { label = "Explorer", icon = "󰉋", desc = "Toggle file explorer" },
  w = { label = "Window",  icon = "󰖲", desc = "Window management" },
  s = { label = "Search",  icon = "󰍉", desc = "Buffer search" },
  q = { label = "Quit",    icon = "󰗼", desc = "Quit / session" },
  h = { label = "Help",    icon = "󰋽", desc = "Help" },
  d = { label = "Debug",   icon = "󰃤", desc = "Debug" },
}

-- ─────────────────────────────────────────────────────────
-- Chord registry: { "ff" = {label, action}, "fg" = ..., ... }
-- ─────────────────────────────────────────────────────────
WhichKey.chords = {
  -- File finders (Telescope-like)
  ["ff"] = { label = "Find Files",        action = "finder_files",     group = "f" },
  ["fg"] = { label = "Live Grep",         action = "finder_grep",       group = "f" },
  ["fb"] = { label = "Buffers",           action = "finder_buffers",    group = "f" },
  ["fr"] = { label = "Recent Files",      action = "finder_recent",     group = "f" },
  ["fc"] = { label = "Commands",          action = "finder_commands",   group = "f" },
  ["fh"] = { label = "Help",              action = "finder_help",       group = "f" },
  ["fk"] = { label = "Key Maps",          action = "finder_keymaps",    group = "f" },

  -- Git
  ["gg"] = { label = "Git Status",        action = "git_status",        group = "g" },
  ["gd"] = { label = "Git Diff",          action = "git_diff",          group = "g" },
  ["gc"] = { label = "Git Commit",        action = "git_commit",        group = "g" },
  ["gp"] = { label = "Git Push",          action = "git_push",          group = "g" },
  ["gl"] = { label = "Git Log",           action = "git_log",            group = "g" },
  ["gb"] = { label = "Git Branch",        action = "git_branch",        group = "g" },
  ["ga"] = { label = "Git Stage All",     action = "git_stage_all",     group = "g" },
  ["gu"] = { label = "Git Unstage All",   action = "git_unstage_all",   group = "g" },

  -- Buffers
  ["bd"] = { label = "Delete Buffer",     action = "buffer_delete",    group = "b" },
  ["bo"] = { label = "Close Other Buffers", action = "buffer_close_others", group = "b" },
  ["bn"] = { label = "Next Buffer",       action = "buffer_next",       group = "b" },
  ["bp"] = { label = "Previous Buffer",   action = "buffer_prev",       group = "b" },
  ["bl"] = { label = "Buffer List",       action = "buffer_list",        group = "b" },

  -- Projects
  ["pp"] = { label = "Project Switcher",  action = "project_switch",    group = "p" },
  ["pf"] = { label = "Project Files",     action = "project_files",     group = "p" },
  ["pg"] = { label = "Project Grep",      action = "project_grep",      group = "p" },
  ["pr"] = { label = "Recent Projects",   action = "project_recent",    group = "p" },
  ["pd"] = { label = "Project Dashboard", action = "project_dashboard", group = "p" },

  -- LSP
  ["la"] = { label = "Code Actions",      action = "lsp_code_action",   group = "l" },
  ["lr"] = { label = "Rename Symbol",     action = "lsp_rename",        group = "l" },
  ["lf"] = { label = "Format Buffer",     action = "lsp_format",        group = "l" },
  ["lh"] = { label = "Hover",              action = "lsp_hover",          group = "l" },
  ["ld"] = { label = "Definition",        action = "lsp_definition",    group = "l" },
  ["ll"] = { label = "References",        action = "lsp_references",    group = "l" },
  ["ls"] = { label = "Signature Help",    action = "lsp_signature",     group = "l" },
  ["lw"] = { label = "Workspace Symbols", action = "lsp_workspace_syms", group = "l" },

  -- Diagnostics
  ["xx"] = { label = "Diagnostics Panel", action = "diagnostics_panel",  group = "x" },
  ["xn"] = { label = "Next Diagnostic",  action = "diagnostics_next",   group = "x" },
  ["xp"] = { label = "Prev Diagnostic",  action = "diagnostics_prev",   group = "x" },
  ["xo"] = { label = "Open Diagnostics", action = "diagnostics_open",   group = "x" },

  -- Terminal
  ["tt"] = { label = "Toggle Terminal",  action = "terminal_toggle",   group = "t" },
  ["tf"] = { label = "Terminal Float",   action = "terminal_float",    group = "t" },
  ["to"] = { label = "Open New Terminal", action = "terminal_new",      group = "t" },

  -- Window
  ["ws"] = { label = "Split Horizontal",  action = "window_split",      group = "w" },
  ["wv"] = { label = "Split Vertical",    action = "window_vsplit",      group = "w" },
  ["wc"] = { label = "Close Window",      action = "window_close",      group = "w" },
  ["wo"] = { label = "Close Others",      action = "window_close_others", group = "w" },
  ["wh"] = { label = "Focus Left",        action = "window_focus_left", group = "w" },
  ["wj"] = { label = "Focus Down",        action = "window_focus_down", group = "w" },
  ["wk"] = { label = "Focus Up",          action = "window_focus_up",   group = "w" },
  ["wl"] = { label = "Focus Right",       action = "window_focus_right", group = "w" },
  ["w="] = { label = "Equalize",          action = "window_equalize",   group = "w" },
  ["w-"] = { label = "Decrease Height",   action = "window_dec_h",      group = "w" },
  ["w+"] = { label = "Increase Height",    action = "window_inc_h",      group = "w" },
  ["w<"] = { label = "Decrease Width",    action = "window_dec_w",      group = "w" },
  ["w>"] = { label = "Increase Width",    action = "window_inc_w",      group = "w" },

  -- Single-key shortcuts (no chord, just one key after leader)
  ["e"]  = { label = "Toggle Explorer",   action = "explorer_toggle",   single = true },
  ["E"]  = { label = "Reveal Current File", action = "explorer_reveal",  single = true },
  ["w"]  = { label = "Save File",         action = "file_save",         single = true },
  ["q"]  = { label = "Quit",              action = "app_quit",          single = true },
  ["Q"]  = { label = "Force Quit",        action = "app_force_quit",    single = true },
  ["n"]  = { label = "New Buffer",        action = "buffer_new",        single = true },
  ["t"]  = { label = "Cycle Themes",      action = "theme_cycle",      single = true },
  ["s"]  = { label = "Cycle Styles",      action = "style_cycle",      single = true },
  ["u"]  = { label = "Undo",              action = "edit_undo",         single = true },
  ["r"]  = { label = "Redo",              action = "edit_redo",         single = true },
  ["i"]  = { label = "Icons Mode",        action = "icons_toggle",      single = true },
}

-- ─────────────────────────────────────────────────────────
-- State machine
-- ─────────────────────────────────────────────────────────
function WhichKey.new()
  local self = setmetatable({}, WhichKey)
  self.visible        = false
  self.prefix         = ""          -- e.g. "f" once user pressed <leader>f
  self.last_result    = nil        -- filled when user completes a chord
  return self
end

function WhichKey:open()
  self.visible = true
  self.prefix  = ""
end

function WhichKey:close()
  self.visible = false
  self.prefix  = ""
  self.last_result = nil
end

function WhichKey:is_open()
  return self.visible
end

-- Feed a key. Returns: ("chord", chord_action) | ("prefix", prefix_char) | ("cancel", nil) | ("noop", nil)
function WhichKey:feed(key)
  if not self.visible then return "noop", nil end
  if key == "esc" or key == " " then
    if self.prefix == "" and key == " " then
      -- User pressed Space twice → cancel
      self:close()
      return "cancel", nil
    end
    self:close()
    return "cancel", nil
  end

  local new_prefix = self.prefix .. key

  -- Check for single-key chord
  if self.prefix == "" then
    local entry = WhichKey.chords[key]
    if entry and entry.single then
      self:close()
      return "chord", entry.action
    end
  end

  -- Check for two-key chord
  if #new_prefix == 2 then
    local entry = WhichKey.chords[new_prefix]
    if entry then
      self:close()
      return "chord", entry.action
    end
    -- Not found, cancel
    self:close()
    return "cancel", nil
  end

  -- One key so far — check if it's a known group prefix
  if #new_prefix == 1 then
    if WhichKey.groups[new_prefix] then
      self.prefix = new_prefix
      return "prefix", new_prefix
    end
    -- Unknown single key, but check single-key chords again
    local entry = WhichKey.chords[new_prefix]
    if entry and entry.single then
      self:close()
      return "chord", entry.action
    end
    self:close()
    return "cancel", nil
  end

  self:close()
  return "cancel", nil
end

-- ─────────────────────────────────────────────────────────
-- Render hint data — returns a list of { key=, label=, icon= } rows
-- UI layer actually draws them.
-- ─────────────────────────────────────────────────────────
function WhichKey:hint_rows()
  if not self.visible then return {} end

  if self.prefix == "" then
    -- Show top-level groups + single-key chords
    local rows = {}
    for k, g in pairs(WhichKey.groups) do
      table.insert(rows, { key = k, label = g.label, icon = g.icon, desc = g.desc })
    end
    -- Single-key shortcuts
    for k, e in pairs(WhichKey.chords) do
      if e.single then
        table.insert(rows, { key = k, label = e.label, icon = "*", desc = "" })
      end
    end
    -- Sort: groups first (alphabetical), then singles (alphabetical)
    table.sort(rows, function(a, b) return a.key < b.key end)
    return rows
  else
    -- Show entries in current group prefix
    local rows = {}
    for chord, e in pairs(WhichKey.chords) do
      if #chord == 2 and chord:sub(1, 1) == self.prefix then
        table.insert(rows, { key = chord:sub(2, 2), label = e.label, icon = "›" })
      end
    end
    table.sort(rows, function(a, b) return a.key < b.key end)
    return rows
  end
end

return WhichKey
