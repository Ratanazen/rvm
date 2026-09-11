local Buffer = {}
Buffer.__index = Buffer

function Buffer.new_empty()
    local self = setmetatable({}, Buffer)
    self.lines = {""}
    self.file_path = nil
    self.cursor_row = 1
    self.cursor_col = 1
    self.row_offset = 0
    self.col_offset = 0
    self.is_dirty = false
    self.yank_buffer = nil
    self.undo_stack = {}
    self.redo_stack = {}
    return self
end

function Buffer.from_file(filepath)
    local self = Buffer.new_empty()
    if not filepath then return self end

    -- Guard against directories
    local is_dir = (filepath == "." or filepath:sub(-1) == "/")
    if not is_dir then
        local handle = io.popen("test -d '" .. filepath:gsub("'", "'\\''") .. "' && echo 'dir' 2>/dev/null")
        if handle then
            local res = handle:read("*a")
            handle:close()
            if res and res:find("dir") then is_dir = true end
        end
    end

    if is_dir then
        self.file_path = nil
        self.lines = {""}
        return self
    end

    local file = io.open(filepath, "r")
    if file then
        self.lines = {}
        local ok, _ = pcall(function()
            for line in file:lines() do
                table.insert(self.lines, line)
            end
        end)
        file:close()
        if not ok or #self.lines == 0 then
            self.lines = {""}
        end
        self.file_path = filepath
        self.is_dirty = false
    else
        self.file_path = filepath
        self.lines = {""}
    end
    return self
end

function Buffer:save(filepath)
    local target = filepath or self.file_path
    if not target or target == "" then
        return false, "No file name"
    end
    local file, err = io.open(target, "w")
    if not file then
        return false, tostring(err)
    end
    for _, line in ipairs(self.lines) do
        file:write(line .. "\n")
    end
    file:close()
    self.file_path = target
    self.is_dirty = false
    return true
end

function Buffer:snapshot()
    local copy_lines = {}
    for _, line in ipairs(self.lines) do
        table.insert(copy_lines, line)
    end
    table.insert(self.undo_stack, {
        lines = copy_lines,
        r = self.cursor_row,
        c = self.cursor_col
    })
    self.redo_stack = {}
end

function Buffer:undo()
    if #self.undo_stack == 0 then return end
    local current = {
        lines = self.lines,
        r = self.cursor_row,
        c = self.cursor_col
    }
    table.insert(self.redo_stack, current)

    local last = table.remove(self.undo_stack)
    self.lines = last.lines
    self.cursor_row = last.r
    self.cursor_col = last.c
    self.is_dirty = true
end

function Buffer:redo()
    if #self.redo_stack == 0 then return end
    table.insert(self.undo_stack, {
        lines = self.lines,
        r = self.cursor_row,
        c = self.cursor_col
    })
    local next_snap = table.remove(self.redo_stack)
    self.lines = next_snap.lines
    self.cursor_row = next_snap.r
    self.cursor_col = next_snap.c
    self.is_dirty = true
end

function Buffer:clamp_cursor()
    if self.cursor_row < 1 then self.cursor_row = 1 end
    if self.cursor_row > #self.lines then self.cursor_row = #self.lines end

    local cur_line = self.lines[self.cursor_row] or ""
    local max_col = #cur_line + 1
    if self.cursor_col < 1 then self.cursor_col = 1 end
    if self.cursor_col > max_col then self.cursor_col = max_col end
end

function Buffer:insert_char(c)
    self:snapshot()
    local line = self.lines[self.cursor_row] or ""
    local before = line:sub(1, self.cursor_col - 1)
    local after = line:sub(self.cursor_col)
    self.lines[self.cursor_row] = before .. c .. after
    self.cursor_col = self.cursor_col + #c
    self.is_dirty = true
end

function Buffer:insert_newline()
    self:snapshot()
    local line = self.lines[self.cursor_row] or ""
    local before = line:sub(1, self.cursor_col - 1)
    local after = line:sub(self.cursor_col)

    self.lines[self.cursor_row] = before
    table.insert(self.lines, self.cursor_row + 1, after)
    self.cursor_row = self.cursor_row + 1
    self.cursor_col = 1
    self.is_dirty = true
end

function Buffer:delete_char()
    if self.cursor_col > 1 then
        self:snapshot()
        local line = self.lines[self.cursor_row] or ""
        local before = line:sub(1, self.cursor_col - 2)
        local after = line:sub(self.cursor_col)
        self.lines[self.cursor_row] = before .. after
        self.cursor_col = self.cursor_col - 1
        self.is_dirty = true
    elseif self.cursor_row > 1 then
        self:snapshot()
        local prev_line = self.lines[self.cursor_row - 1] or ""
        local cur_line = self.lines[self.cursor_row] or ""
        self.cursor_col = #prev_line + 1
        self.lines[self.cursor_row - 1] = prev_line .. cur_line
        table.remove(self.lines, self.cursor_row)
        self.cursor_row = self.cursor_row - 1
        self.is_dirty = true
    end
end

function Buffer:delete_line()
    if #self.lines == 0 then return end
    self:snapshot()
    self.yank_buffer = self.lines[self.cursor_row]
    table.remove(self.lines, self.cursor_row)
    if #self.lines == 0 then
        self.lines = {""}
    end
    self:clamp_cursor()
    self.is_dirty = true
end

function Buffer:yank_line()
    self.yank_buffer = self.lines[self.cursor_row]
end

function Buffer:paste_line()
    if not self.yank_buffer then return end
    self:snapshot()
    table.insert(self.lines, self.cursor_row + 1, self.yank_buffer)
    self.cursor_row = self.cursor_row + 1
    self.cursor_col = 1
    self.is_dirty = true
end

function Buffer:get_word_under_cursor()
    local line = self.lines[self.cursor_row] or ""
    local col = self.cursor_col
    if #line == 0 then return "" end

    local left = col
    while left > 1 and line:sub(left - 1, left - 1):match("[%a%d_]") do
        left = left - 1
    end

    local right = col
    while right <= #line and line:sub(right, right):match("[%a%d_]") do
        right = right + 1
    end

    return line:sub(left, right - 1)
end

function Buffer:get_token_under_cursor()
    local line = self.lines[self.cursor_row] or ""
    local col = self.cursor_col
    if #line == 0 then return "" end

    local left = col
    while left > 1 and line:sub(left - 1, left - 1):match("[%a%d_%-%#%.]") do
        left = left - 1
    end

    local right = col
    while right <= #line and line:sub(right, right):match("[%a%d_%-%#%.]") do
        right = right + 1
    end

    return line:sub(left, right - 1)
end

return Buffer
