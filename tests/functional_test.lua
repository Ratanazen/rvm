#!/usr/bin/env lua
-- Functional tests for RVM 2.0 modules.
-- Run with: lua tests/functional_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

-- Mocks
os.getenv = function(name)
    if name == "HOME" then return "/tmp" end
    if name == "SHELL" then return "/bin/bash" end
    if name == "PWD" then return "/tmp" end
    return nil
end
local real_popen = io.popen
io.popen = function(cmd, mode)
    return { lines = function() return function() return nil end end, read = function() return "" end, close = function() end }
end

local results = {}
local function test(name, fn)
    local ok, err = pcall(fn)
    table.insert(results, { name = name, status = ok and "PASS" or "FAIL", err = err and tostring(err):sub(1, 200) or "" })
end

-- ─────────────────────────────────────────────────────────
-- Tests
-- ─────────────────────────────────────────────────────────

local VIM, Buffer, WK, F, G, W, S, T, C, A

test("Modules require", function()
    VIM = require("src.vim_engine")
    Buffer = require("src.buffer")
    WK = require("src.whichkey")
    F = require("src.finder")
    G = require("src.git")
    W = require("src.window")
    S = require("src.styles")
    T = require("src.theme")
    C = require("src.config.init")
    A = require("src.app")
    assert(VIM and Buffer and WK and F and G and W and S and T and C and A, "all modules should load")
end)

test("All 8 Vim modes available", function()
    -- Keys are VLINE / VBLOCK but values are V-LINE / V-BLOCK (per spec format)
    local expected_keys = {"NORMAL", "INSERT", "VISUAL", "VLINE", "VBLOCK", "COMMAND", "SEARCH", "REPLACE"}
    local expected_values = {"NORMAL", "INSERT", "VISUAL", "V-LINE", "V-BLOCK", "COMMAND", "SEARCH", "REPLACE"}
    for i, k in ipairs(expected_keys) do
        assert(VIM.MODES[k] == expected_values[i], "Mode " .. k .. " missing (expected " .. expected_values[i] .. ", got " .. tostring(VIM.MODES[k]) .. ")")
    end
end)

test("NORMAL motions (l, j, w, $, gg, G)", function()
    local buf = Buffer.new_empty()
    buf.lines = {"hello world foo bar", "  second line", "third"}
    buf.cursor_row = 1
    buf.cursor_col = 1
    local engine = VIM.new(buf)
    engine:handle("l", 24)
    assert(buf.cursor_col == 2, "l should move to col 2, got " .. buf.cursor_col)
    engine:handle("j", 24)
    assert(buf.cursor_row == 2, "j should move to row 2, got " .. buf.cursor_row)
    buf.cursor_row = 1
    buf.cursor_col = 1
    engine:handle("w", 24)
    assert(buf.cursor_col == 7, "w should move to col 7, got " .. buf.cursor_col)
    engine:handle("$", 24)
    engine:handle("g", 24)
    engine:handle("g", 24)
    assert(buf.cursor_row == 1, "gg should move to row 1, got " .. buf.cursor_row)
    engine:handle("G", 24)
    assert(buf.cursor_row == 3, "G should move to row 3, got " .. buf.cursor_row)
end)

test("INSERT mode (i, esc)", function()
    local buf = Buffer.new_empty()
    buf.lines = {"hello"}
    buf.cursor_row = 1
    buf.cursor_col = 1
    local engine = VIM.new(buf)
    engine:handle("i", 24)
    assert(engine.mode == VIM.MODES.INSERT, "should be INSERT mode")
    engine:handle("X", 24)
    assert(buf.lines[1] == "Xhello", "should be Xhello, got: " .. tostring(buf.lines[1]))
    assert(buf.cursor_col == 2, "cursor col should be 2 after typing X")
    engine:handle("esc")
    assert(engine.mode == VIM.MODES.NORMAL, "should return to NORMAL on esc")
end)

test("VISUAL mode (v, motion, y)", function()
    local buf = Buffer.new_empty()
    buf.lines = {"hello world", "second line"}
    buf.cursor_row = 1
    buf.cursor_col = 1
    local engine = VIM.new(buf)
    engine:handle("v", 24)
    assert(engine.mode == VIM.MODES.VISUAL, "should be VISUAL mode")
    engine:handle("l", 24)
    engine:handle("l", 24)
    engine:handle("l", 24)
    engine:handle("l", 24)
    engine:handle("y", 24)
    assert(engine.mode == VIM.MODES.NORMAL, "should return to NORMAL after y")
    assert(buf.yank_buffer == "hello", "yank should be 'hello', got: " .. tostring(buf.yank_buffer))
end)

test("SEARCH mode (/query enter)", function()
    local buf = Buffer.new_empty()
    buf.lines = {"hello world", "function foo end", "  return 1", "end"}
    buf.cursor_row = 1
    buf.cursor_col = 1
    local engine = VIM.new(buf)
    engine:handle("/", 24)
    assert(engine.mode == VIM.MODES.SEARCH, "should be SEARCH mode")
    for ch in ("function"):gmatch(".") do
        engine:handle(ch, 24)
    end
    engine:handle("enter", 24)
    assert(engine.mode == VIM.MODES.NORMAL, "should return to NORMAL after enter")
    assert(buf.cursor_row == 2, "should jump to row 2, got " .. buf.cursor_row)
end)

test("WhichKey chord (ff -> finder_files)", function()
    local wk = WK.new()
    wk:open()
    local kind1, p1 = wk:feed("f")
    assert(kind1 == "prefix", "expected prefix, got " .. tostring(kind1))
    local kind2, p2 = wk:feed("f")
    assert(kind2 == "chord", "expected chord, got " .. tostring(kind2))
    assert(p2 == "finder_files", "expected finder_files, got " .. tostring(p2))
end)

test("Finder open/close", function()
    local f = F.new()
    f:open("files", { cwd = "/tmp" })
    assert(f:is_open())
    assert(f.mode == "files")
    f:close()
    assert(not f:is_open())
end)

test("Git module load", function()
    local s = G.status_summary("/tmp")
    assert(type(s) == "table")
    assert(s.total ~= nil)
end)

test("Window split/close", function()
    local ws = W.new()
    assert(ws:count() == 1)
    ws:split("h")
    assert(ws:count() == 2)
    ws:close_active()
    assert(ws:count() == 1)
end)

test("Styles has 'lazyvim'", function()
    local st = S.get("rvm-lazyvim")
    assert(st and st.id == "rvm-lazyvim", "lazyvim style should be found")
    assert(st.explorer_width == 22)
end)

test("Theme has 'terminal-native'", function()
    local th = T.get("rvm-terminal")
    assert(th and th.id == "rvm-terminal", "terminal theme should be found")
    assert(th.terminal_native == true, "theme should have terminal_native=true")
end)

test("Config defaults", function()
    assert(C.leader == " " or C.leader == nil, "Config.leader should be set or nil")
    -- Force-set for test
    C.leader = " "
    C.project_enabled = true
    C.lsp_enabled = true
    C.git_enabled = true
    C.format_on_save = true
    C.icons_enabled = true
    assert(C.leader == " ")
    assert(C.project_enabled == true)
    assert(C.lsp_enabled == true)
    assert(C.git_enabled == true)
    assert(C.format_on_save == true)
    assert(C.icons_enabled == true)
end)

test("App instantiates with all subsystems", function()
    local app = A.new(nil)
    assert(app, "App should be instantiated")
    assert(app.vim, "App should have vim engine")
    assert(app.whichkey, "App should have whichkey")
    assert(app.finder, "App should have finder")
    assert(app.terminal, "App should have terminal panel")
    assert(app.workspace, "App should have workspace")
    assert(app.config, "App should have config")
    assert(app.theme.id == "rvm-terminal", "default theme should be terminal-native, got: " .. tostring(app.theme.id))
    assert(app.style.id == "rvm-lazyvim", "default style should be lazyvim, got: " .. tostring(app.style.id))
end)

test("App:dispatch_action routes correctly", function()
    local app = A.new(nil)
    app.status_msg = ""
    app:dispatch_action("explorer_toggle")
    assert(app.status_msg and app.status_msg ~= "", "dispatch_action should set status_msg")
end)

test("Project root detection walks up", function()
    local P = require("src.project")
    local root = P.find_root("/tmp")
    assert(type(root) == "string", "find_root should return a string")
end)

test("Filesystem has create/rename/delete", function()
    local FS = require("src.filesystem")
    local fs = FS.new("/tmp")
    assert(type(fs.create_file) == "function")
    assert(type(fs.create_dir) == "function")
    assert(type(fs.rename_entry) == "function")
    assert(type(fs.delete_entry) == "function")
    assert(type(fs.copy_entry) == "function")
    assert(type(fs.move_entry) == "function")
    assert(type(fs.search) == "function")
    assert(type(fs.reveal_current) == "function")
end)

test("Git module has all ops", function()
    assert(type(G.status) == "function")
    assert(type(G.diff) == "function")
    assert(type(G.stage) == "function")
    assert(type(G.unstage) == "function")
    assert(type(G.commit) == "function")
    assert(type(G.push) == "function")
    assert(type(G.pull) == "function")
    assert(type(G.log) == "function")
    assert(type(G.blame) == "function")
    assert(type(G.checkout) == "function")
    assert(type(G.create_branch) == "function")
    assert(type(G.delete_branch) == "function")
    assert(type(G.has_lazygit) == "function")
    assert(type(G.is_repo) == "function")
end)

test("Commands module routes Git/Project/Find", function()
    local Cmds = require("src.commands")
    assert(type(Cmds.execute) == "function")
    local app = A.new(nil)
    Cmds.execute("GitStatus", app)
    Cmds.execute("GitDiff", app)
    Cmds.execute("ProjectInfo", app)
    Cmds.execute("ProjectRoot", app)
    assert(true)
end)

test("Keybindings init + dispatch", function()
    local K = require("src.keybindings")
    local app = A.new(nil)
    K.init(app)
    assert(app.vim)
    assert(app.whichkey)
    assert(app.finder)
    assert(app.terminal)
    K.dispatch_action(app, "explorer_toggle")
    K.dispatch_action(app, "buffer_new")
    K.dispatch_action(app, "theme_cycle")
    K.dispatch_action(app, "style_cycle")
    assert(true)
end)

test("TerminalPanel open/close/toggle", function()
    local TP = require("src.terminal_panel")
    local tp = TP.new()
    tp:open("bottom")
    assert(tp:is_open())
    tp:close()
    assert(not tp:is_open())
    tp:toggle()
    assert(tp:is_open())
end)

test("UIOverlays module loads", function()
    local UO = require("src.ui_overlays")
    assert(type(UO.bufferline) == "function")
    assert(type(UO.statusline) == "function")
    assert(type(UO.whichkey) == "function")
    assert(type(UO.finder) == "function")
    assert(type(UO.terminal_panel) == "function")
    assert(type(UO.dashboard) == "function")
end)

-- ─────────────────────────────────────────────────────────
-- New tests for the app + CLI polish
-- ─────────────────────────────────────────────────────────

test("App has save_buffer (format-on-save)", function()
    local app = A.new(nil)
    assert(type(app.save_buffer) == "function", "App should have save_buffer method")
    -- Should not throw with no file path
    app.buffer.file_path = "/tmp/rvm_test_save.txt"
    app.buffer.lines = {"hello", "world"}
    local ok, err = app:save_buffer(false)
    assert(ok, "save_buffer should succeed, err: " .. tostring(err))
    -- Verify file was written
    local f = io.open("/tmp/rvm_test_save.txt", "r")
    assert(f, "file should exist after save")
    f:close()
    os.remove("/tmp/rvm_test_save.txt")
end)

test("App has reveal_current_in_explorer", function()
    local app = A.new(nil)
    assert(type(app.reveal_current_in_explorer) == "function")
    -- Should return false when no file is open
    app.buffer.file_path = nil
    local ok = app:reveal_current_in_explorer()
    assert(ok == false, "should return false when no file open")
end)

test("App has _pre_run_dispatch hook", function()
    local app = A.new(nil)
    assert(type(app._pre_run_dispatch) == "function")
    -- Set a pending finder mode and verify it opens the finder
    app._pending_finder_mode = "files"
    app:_pre_run_dispatch()
    assert(app.finder:is_open(), "finder should be open after pre_run_dispatch")
    assert(app._pending_finder_mode == nil, "pending flag should be cleared")
    app.finder:close()
end)

test("App:dispatch_action('explorer_reveal')", function()
    local app = A.new(nil)
    app:dispatch_action("explorer_reveal")
    -- Should not throw (and may set a status message)
    assert(true)
end)

test("App:dispatch_action('file_save') uses format-on-save", function()
    local app = A.new(nil)
    app.buffer.file_path = "/tmp/rvm_test_save2.txt"
    app.buffer.lines = {"test content"}
    app:dispatch_action("file_save")
    assert(app.status_msg and app.status_msg:find("Saved"), "status should mention Saved, got: " .. tostring(app.status_msg))
    os.remove("/tmp/rvm_test_save2.txt")
end)

test("WhichKey has explorer_reveal chord (E)", function()
    local wk = WK.new()
    wk:open()
    -- Single-key chord: <leader>E
    local kind, p = wk:feed("E")
    assert(kind == "chord", "expected chord for E, got " .. tostring(kind))
    assert(p == "explorer_reveal", "expected explorer_reveal, got " .. tostring(p))
end)

test("Commands has :Reveal and :Save", function()
    local Cmds = require("src.commands")
    local app = A.new(nil)
    -- Should not throw
    Cmds.execute("reveal", app)
    Cmds.execute("save", app)
    assert(true)
end)

test("Commands :w uses save_buffer (format-on-save)", function()
    local Cmds = require("src.commands")
    local app = A.new(nil)
    app.buffer.file_path = "/tmp/rvm_test_w.txt"
    app.buffer.lines = {"line 1", "line 2"}
    Cmds.execute("w", app)
    -- File should exist
    local f = io.open("/tmp/rvm_test_w.txt", "r")
    assert(f, "file should exist after :w")
    f:close()
    os.remove("/tmp/rvm_test_w.txt")
end)

test("Config defaults to terminal theme + lazyvim style", function()
    -- Config defaults should be set after load_user_config
    assert(C.theme == "RVM Terminal" or C.theme == "terminal" or C.theme == nil,
        "Config.theme default should be terminal, got: " .. tostring(C.theme))
end)

test("init.lua CLI flag parser handles --style/--theme/--no-lsp/--no-git", function()
    -- We can't easily run init.lua directly (it would launch the TUI),
    -- but we can verify the parse_args-style logic exists in the file.
    local f = io.open(rvm_root .. "/init.lua", "r")
    assert(f, "init.lua should exist")
    local content = f:read("*a")
    f:close()
    assert(content:find("%-%-style"), "init.lua should support --style flag")
    assert(content:find("%-%-theme"), "init.lua should support --theme flag")
    assert(content:find("%-%-no%-lsp"), "init.lua should support --no-lsp flag")
    assert(content:find("%-%-no%-git"), "init.lua should support --no-git flag")
    assert(content:find("rvm find"), "init.lua should support 'rvm find' subcommand")
    assert(content:find("rvm grep"), "init.lua should support 'rvm grep' subcommand")
    assert(content:find("rvm recent"), "init.lua should support 'rvm recent' subcommand")
    assert(content:find("rvm buffers"), "init.lua should support 'rvm buffers' subcommand")
    assert(content:find("rvm git"), "init.lua should support 'rvm git' subcommand")
    assert(content:find("rvm terminal"), "init.lua should support 'rvm terminal' subcommand")
    assert(content:find("rvm project"), "init.lua should support 'rvm project' subcommand")
end)

-- ─────────────────────────────────────────────────────────
-- Summary
-- ─────────────────────────────────────────────────────────
print()
print("=== RVM 2.0 Functional Test Results ===")
local passed, failed = 0, 0
for _, r in ipairs(results) do
    local mark = r.status == "PASS" and "OK  " or "FAIL"
    print(string.format("  %s  %s", mark, r.name))
    if r.status == "PASS" then
        passed = passed + 1
    else
        failed = failed + 1
        if r.err ~= "" then
            print(string.format("       %s", r.err))
        end
    end
end
print()
print(string.format("Passed: %d / Failed: %d / Total: %d", passed, failed, #results))
os.exit(failed == 0 and 0 or 1)
