local Terminal = {}

Terminal.orig_stty = nil

function Terminal.enable_raw_mode()
    local handle = io.popen("stty -g 2>/dev/null")
    if handle then
        Terminal.orig_stty = handle:read("*a"):trim()
        handle:close()
    end
    os.execute("stty raw -echo min 1 time 0 2>/dev/null")
    io.write("\27[?25l") -- Hide cursor during render
    io.flush()
end

function Terminal.disable_raw_mode()
    io.write("\27[?25h\27[0m\27_Ga=d,d=a\27\\\27[2J\27[H") -- Show cursor, reset, clear graphics, clear
    io.flush()
    if Terminal.orig_stty and Terminal.orig_stty ~= "" then
        os.execute("stty " .. Terminal.orig_stty .. " 2>/dev/null")
    else
        os.execute("stty sane 2>/dev/null")
    end
end

function string.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function Terminal.get_size()
    local handle = io.popen("stty size 2>/dev/null")
    if handle then
        local res = handle:read("*a")
        handle:close()
        if res then
            local rows, cols = res:match("(%d+)%s+(%d+)")
            if rows and cols then
                return tonumber(rows), tonumber(cols)
            end
        end
    end
    return 24, 80
end

function Terminal.clear()
    io.write("\27[2J\27[H")
end

function Terminal.move_cursor(row, col)
    io.write(string.format("\27[%d;%dH", row, col))
end

function Terminal.show_cursor()
    io.write("\27[?25h")
end

function Terminal.hide_cursor()
    io.write("\27[?25l")
end

function Terminal.reset_color()
    return "\27[0m"
end

function Terminal.fg_rgb(r, g, b)
    return string.format("\27[38;2;%d;%d;%dm", r or 255, g or 255, b or 255)
end

function Terminal.bg_rgb(r, g, b)
    return string.format("\27[48;2;%d;%d;%dm", r or 0, g or 0, b or 0)
end

function Terminal.bold()
    return "\27[1m"
end

function Terminal.read_key()
    local char = io.stdin:read(1)
    if not char then return nil end

    local byte = string.byte(char)

    -- Handle escape sequences
    if byte == 27 then
        -- Read next bytes if available
        os.execute("sleep 0.001")
        local seq1 = io.stdin:read(1)
        if not seq1 then return "esc" end

        local seq2 = io.stdin:read(1)
        if seq1 == "[" then
            if seq2 == "A" then return "up" end
            if seq2 == "B" then return "down" end
            if seq2 == "C" then return "right" end
            if seq2 == "D" then return "left" end
            if seq2 == "H" then return "home" end
            if seq2 == "F" then return "end" end
            if seq2 == "5" then io.stdin:read(1); return "pageup" end
            if seq2 == "6" then io.stdin:read(1); return "pagedown" end
            if seq2 == "3" then io.stdin:read(1); return "delete" end
        end
        return "esc"
    end

    -- Control keys
    if byte == 19 then return "ctrl_s" end  -- Ctrl+S
    if byte == 17 then return "ctrl_q" end  -- Ctrl+Q
    if byte == 6  then return "ctrl_f" end  -- Ctrl+F
    if byte == 26 then return "ctrl_z" end  -- Ctrl+Z
    if byte == 25 then return "ctrl_y" end  -- Ctrl+Y
    if byte == 18 then return "ctrl_r" end  -- Ctrl+R
    if byte == 5  then return "ctrl_e" end  -- Ctrl+E
    if byte == 9  then return "tab" end     -- Tab
    if byte == 13 or byte == 10 then return "enter" end
    if byte == 127 or byte == 8 then return "backspace" end

    return char
end

return Terminal
