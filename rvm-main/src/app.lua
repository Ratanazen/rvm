local Terminal   = require("src.terminal")
local Buffer     = require("src.buffer")
local Filesystem = require("src.filesystem")
local Theme      = require("src.theme")
local Styles     = require("src.styles")
local Config     = require("src.config.init")
local Project    = require("src.project")
local Plugin     = require("src.plugin")
local LSP        = require("src.lsp")
local Keybindings = require("src.keybindings")
local UI         = require("src.ui")
local VimEngine   = require("src.vim_engine")
local WhichKey    = require("src.whichkey")
local Finder      = require("src.finder")
local Git         = require("src.git")
local TerminalPanel = require("src.terminal_panel")
local Workspace   = require("src.window")

local App = {}
App.__index = App

function App.new(target_path)
    local self = setmetatable({}, App)

    -- 1. Load user configuration if present
    Config.load_user_config()
    self.config = Config
    if Config.editor and Config.editor.icons and Config.editor.icons.mode then
        local TerminalGraphics = require("src.terminal_graphics")
        TerminalGraphics.set_mode(Config.editor.icons.mode)
    end

    -- 2. Project Detection (Flutter, React, Vue, Svelte, Node, Rust, Go, Python, etc.)
    self.project = Project.detect(target_path or ".")
    -- Record this project as recent
    if self.project and self.project.root then
        Project.recent_add(self.project.root)
    end

    -- 3. Theme & Style initialization
    -- Per spec: default theme = "terminal", default style = "lazyvim"
    self.theme_index = 1
    self.theme = Theme.get(Config.theme or "RVM Terminal") or Theme.default()
    self.style = Styles.get(Config.style or "RVM LazyVim") or Styles.get("rvm-lazyvim")

    -- 4. Multi-buffer management
    self.buffers   = {}
    self.buf_index = 1

    local first_buf = Buffer.new_empty()
    table.insert(self.buffers, first_buf)
    self.buffer = first_buf

    -- 5. Filesystem explorer
    self.filesystem = nil
    self.show_dashboard = true

    -- Per spec requirement #2 (LazyVim UX), Vim modes are now the default editor experience.
    -- `easy_mode` is preserved for backward compatibility but defaults to false.
    self.easy_mode = false
    self.vim_mode = "NORMAL"

    -- 6. Search & Command state
    self.in_command = false
    self.in_search = false
    self.command_input = ""
    self.search_input = ""
    self.last_search = nil

    -- 7. Overlays (Which-Key, Palette, Lazy, Hover) — per spec requirement #16
    self.vim          = VimEngine.new(self.buffer)
    self.whichkey     = WhichKey.new()
    self.finder       = Finder.new()
    self.terminal     = TerminalPanel.new()
    self.workspace    = Workspace.new()
    self.git_state    = { last_diff = "", last_log = {}, last_status = {} }
    self.terminal_focus = false
    self.explorer_focus = false

    -- Legacy overlay flags (kept for backward compatibility with existing UI code)
    self.show_whichkey = false
    self.show_palette = false
    self.palette_input = ""
    self.palette_sel = 1
    self.leader_pending = false
    self.show_lazy = false
    self.show_hover = false
    self.hover_data = nil

    -- 8. Custom hooks & commands from plugins
    self.custom_commands = {}
    self.custom_keymaps = {}

    -- 9. Status message
    self.status_msg = string.format("RVM — %s detected | %s active | Space: leader", self.project.name, self.style.name)
    self.should_quit = false

    -- 10. Handle target argument
    if target_path then
        local is_dir = (target_path == "." or target_path:sub(-1) == "/")
        if not is_dir then
            local handle = io.popen("test -d '" .. target_path:gsub("'", "'\\''") .. "' && echo 'dir' 2>/dev/null")
            if handle then
                local res = handle:read("*a")
                handle:close()
                if res and res:find("dir") then is_dir = true end
            end
        end

        if is_dir then
            self.filesystem = Filesystem.new(target_path)
            self.filesystem.is_visible = self.style.sidebar
            self.show_dashboard = true
        else
            local buf = Buffer.from_file(target_path)
            self.buffers[1] = buf
            self.buffer = buf
            self.vim:set_buffer(buf)
            self.show_dashboard = false
            self:apply_filetype_style(target_path)
        end
    else
        self.filesystem = Filesystem.new(self.project and self.project.root or ".")
        self.filesystem.is_visible = self.style.sidebar
    end

    -- 11. Initialize plugins
    Plugin.init_all(Config.plugins, self)

    return self
end

-- Requirement 9: Apply filetype-specific style/theme
function App:apply_filetype_style(file_path)
    if not file_path then return end
    local ext = file_path:match("%.([%w_]+)$")
    if ext then
        ext = ext:lower()
        local ft_cfg = Config.filetypes[ext]
        if ft_cfg then
            if ft_cfg.theme then
                self.theme = Theme.get(ft_cfg.theme)
            end
        end
    end
end

function App:open_buffer(file_path)
    for i, buf in ipairs(self.buffers) do
        if buf.file_path == file_path then
            self.buf_index = i
            self.buffer = buf
            self.vim:set_buffer(buf)
            self:apply_filetype_style(file_path)
            return
        end
    end
    local buf = file_path and Buffer.from_file(file_path) or Buffer.new_empty()
    table.insert(self.buffers, buf)
    self.buf_index = #self.buffers
    self.buffer = self.buffers[self.buf_index]
    self.vim:set_buffer(self.buffer)
    self.show_dashboard = false
    self:apply_filetype_style(file_path)
end

function App:close_buffer()
    if #self.buffers <= 1 then
        self.buffers[1] = Buffer.new_empty()
        self.buf_index = 1
        self.buffer = self.buffers[1]
        self.vim:set_buffer(self.buffer)
        self.show_dashboard = true
        return
    end
    table.remove(self.buffers, self.buf_index)
    self.buf_index = math.max(1, self.buf_index - 1)
    self.buffer = self.buffers[self.buf_index]
    self.vim:set_buffer(self.buffer)
    self:apply_filetype_style(self.buffer.file_path)
end

function App:next_buffer()
    if #self.buffers > 1 then
        self.buf_index = (self.buf_index % #self.buffers) + 1
        self.buffer = self.buffers[self.buf_index]
        self.vim:set_buffer(self.buffer)
        self.show_dashboard = false
        self:apply_filetype_style(self.buffer.file_path)
    end
end

function App:prev_buffer()
    if #self.buffers > 1 then
        self.buf_index = ((self.buf_index - 2) % #self.buffers) + 1
        self.buffer = self.buffers[self.buf_index]
        self.vim:set_buffer(self.buffer)
        self.show_dashboard = false
        self:apply_filetype_style(self.buffer.file_path)
    end
end

-- ─────────────────────────────────────────────────────────
-- Dispatch a named action (used by finder "commands" mode and keybindings)
-- ─────────────────────────────────────────────────────────
function App:dispatch_action(action)
    Keybindings.dispatch_action(self, action)
end

-- ─────────────────────────────────────────────────────────
-- Save with optional format-on-save (per spec requirement #18:
-- `vim.g.rvm_format_on_save = true`)
-- ─────────────────────────────────────────────────────────
function App:save_buffer(format)
    if format == nil then
        format = self.config and self.config.format_on_save ~= false
    end
    if format and self.config and self.config.lsp_enabled ~= false then
        local ok, LSP_mod = pcall(require, "src.lsp")
        if ok and LSP_mod and LSP_mod.format then
            pcall(LSP_mod.format, self.buffer)
        end
    end
    local ok, err = self.buffer:save()
    if ok then
        self.status_msg = "Saved " .. (self.buffer.file_path or "untitled")
    else
        self.status_msg = "Save error: " .. tostring(err)
    end
    return ok, err
end

-- ─────────────────────────────────────────────────────────
-- Reveal current buffer file in the explorer (per spec requirement #6)
-- ─────────────────────────────────────────────────────────
function App:reveal_current_in_explorer()
    if not self.filesystem or not self.buffer or not self.buffer.file_path then
        return false
    end
    self.filesystem.is_visible = true
    return self.filesystem:reveal_current(self.buffer.file_path)
end

-- ─────────────────────────────────────────────────────────
-- Pre-run hook: dispatch any pending action set by init.lua
-- (e.g. `rvm find` opens the file finder before the first frame)
-- ─────────────────────────────────────────────────────────
function App:_pre_run_dispatch()
    if self._pending_finder_mode and self.finder then
        self.finder:open(self._pending_finder_mode, {
            cwd = self.project and self.project.root or "."
        })
        self._pending_finder_mode = nil
    elseif self._pending_action then
        local action = self._pending_action
        self._pending_action = nil
        if self.dispatch_action then
            self:dispatch_action(action)
        end
    end
end

-- ─────────────────────────────────────────────────────────
-- Main loop
-- ─────────────────────────────────────────────────────────
function App:run()
    Terminal.enable_raw_mode()

    -- Dispatch any pending action set by init.lua before the first frame.
    self:_pre_run_dispatch()

    while not self.should_quit do
        if self.show_lazy then
            local Lazy = require("src.lazy")
            local rows, cols = Terminal.get_size()
            Lazy.render(rows, cols, self.theme)
            local key = Terminal.read_key()
            if key == "esc" or key == "q" then self.show_lazy = false end
        else
            UI.render(self)
            local key = Terminal.read_key()
            if key then
                Keybindings.handle(key, self)
            end
        end
    end

    Terminal.disable_raw_mode()
end

return App
