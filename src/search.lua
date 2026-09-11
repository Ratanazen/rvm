local Search = {}

function Search.find(buffer, query, start_row)
    if not query or query == "" then return nil end
    local query_lower = query:lower()

    for r = (start_row or 1), #buffer.lines do
        local line = buffer.lines[r]:lower()
        local c = line:find(query_lower, 1, true)
        if c then
            return r, c
        end
    end

    -- Wrap search from top
    for r = 1, (start_row or 1) - 1 do
        local line = buffer.lines[r]:lower()
        local c = line:find(query_lower, 1, true)
        if c then
            return r, c
        end
    end

    return nil
end

return Search
