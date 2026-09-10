local Terminal = require("src.terminal")

local TerminalGraphics = {}

-- Base64 characters table
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64_encode(data)
    if not data or #data == 0 then return "" end
    local t = {}
    local len = #data
    local pad = (3 - len % 3) % 3
    local padded = data .. string.rep("\0", pad)
    for i = 1, #padded, 3 do
        local b1, b2, b3 = padded:byte(i, i + 2)
        local n = (b1 << 16) | (b2 << 8) | b3
        local c1 = (n >> 18) & 63
        local c2 = (n >> 12) & 63
        local c3 = (n >> 6) & 63
        local c4 = n & 63
        t[#t + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1) .. B64:sub(c3 + 1, c3 + 1) .. B64:sub(c4 + 1, c4 + 1)
    end
    local res = table.concat(t)
    if pad == 1 then
        res = res:sub(1, -2) .. "="
    elseif pad == 2 then
        res = res:sub(1, -3) .. "=="
    end
    return res
end

-- Detect terminal image support at startup
function TerminalGraphics.detect_support()
    -- 1. Check if stdout is an interactive terminal
    local is_tty = (os.execute("test -t 1 2>/dev/null") == true or os.execute("test -t 1 2>/dev/null") == 0)
    if not is_tty then return false end

    -- 2. Check Kitty terminal
    if os.getenv("KITTY_WINDOW_ID") or os.getenv("KITTY_PID") then
        return true
    end

    -- 3. Check Ghostty terminal
    if os.getenv("GHOSTTY_RESOURCES_DIR") then
        return true
    end

    -- 4. Check WezTerm
    if os.getenv("WEZTERM_PANE") or os.getenv("WEZTERM_EXECUTABLE") then
        return true
    end

    -- 5. Check TERM or TERM_PROGRAM variables
    local term = (os.getenv("TERM") or ""):lower()
    local term_prog = (os.getenv("TERM_PROGRAM") or ""):lower()

    if term:find("kitty") or term:find("ghostty") or term:find("wezterm") then
        return true
    end
    if term_prog:find("wezterm") or term_prog:find("iterm") or term_prog:find("ghostty") or term_prog:find("kitty") then
        return true
    end

    return false
end

TerminalGraphics.supported = TerminalGraphics.detect_support()
TerminalGraphics.mode = "auto" -- "auto" | "image" | "glyph"
TerminalGraphics.cache = {}

function TerminalGraphics.is_image_enabled()
    if TerminalGraphics.mode == "image" then
        return true
    elseif TerminalGraphics.mode == "glyph" then
        return false
    else
        return TerminalGraphics.supported
    end
end

function TerminalGraphics.set_mode(mode)
    if mode == "auto" or mode == "image" or mode == "glyph" then
        TerminalGraphics.mode = mode
    end
end

-- Read binary file and cache base64 encoded string
function TerminalGraphics.load_base64(file_path)
    if TerminalGraphics.cache[file_path] ~= nil then
        return TerminalGraphics.cache[file_path]
    end

    -- Try relative to app root (/home/reny/RVM/)
    local full_path = file_path
    if not full_path:match("^/") then
        full_path = "/home/reny/RVM/" .. file_path
    end

    local file = io.open(full_path, "rb")
    if not file then
        TerminalGraphics.cache[file_path] = false
        return nil
    end

    local content = file:read("*a")
    file:close()

    if not content or #content == 0 then
        TerminalGraphics.cache[file_path] = false
        return nil
    end

    local b64 = base64_encode(content)
    TerminalGraphics.cache[file_path] = b64
    return b64
end

-- Render image using Kitty graphics protocol escape sequence
-- \27_Ga=T,f=100,t=d,c=<cols>,r=<rows>,m=<0_or_1>;<payload>\27\\
function TerminalGraphics.draw_image(path, row, col, cell_w, cell_h)
    local b64 = TerminalGraphics.load_base64(path)
    if not b64 then return false end

    cell_w = cell_w or 2
    cell_h = cell_h or 1

    if row and col then
        Terminal.move_cursor(row, col)
    end

    local CHUNK_SIZE = 4096
    local len = #b64

    if len <= CHUNK_SIZE then
        -- Single chunk transmission
        io.write(string.format("\27_Ga=T,f=100,t=d,c=%d,r=%d,z=1,m=0;%s\27\\", cell_w, cell_h, b64))
    else
        -- Multi-chunk transmission for larger images
        local offset = 1
        local is_first = true
        while offset <= len do
            local chunk = b64:sub(offset, offset + CHUNK_SIZE - 1)
            offset = offset + CHUNK_SIZE
            local more = (offset <= len) and 1 or 0

            if is_first then
                io.write(string.format("\27_Ga=T,f=100,t=d,c=%d,r=%d,z=1,m=%d;%s\27\\", cell_w, cell_h, more, chunk))
                is_first = false
            else
                io.write(string.format("\27_Gm=%d;%s\27\\", more, chunk))
            end
        end
    end

    return true
end

-- Clear all displayed graphics in Kitty protocol terminals
function TerminalGraphics.clear_all()
    io.write("\27_Ga=d,d=a\27\\")
end

return TerminalGraphics
