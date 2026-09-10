local Cursor = {}

function Cursor.clamp(buffer, max_rows, max_cols)
    buffer:clamp_cursor()

    -- Adjust vertical scroll offset
    if buffer.cursor_row <= buffer.row_offset then
        buffer.row_offset = buffer.cursor_row - 1
    elseif buffer.cursor_row > buffer.row_offset + max_rows then
        buffer.row_offset = buffer.cursor_row - max_rows
    end

    -- Adjust horizontal scroll offset
    if buffer.cursor_col <= buffer.col_offset then
        buffer.col_offset = buffer.cursor_col - 1
    elseif buffer.cursor_col > buffer.col_offset + max_cols then
        buffer.col_offset = buffer.cursor_col - max_cols
    end
end

return Cursor
