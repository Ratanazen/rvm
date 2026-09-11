local Filesystem = {}
Filesystem.__index = Filesystem

function Filesystem.new(root_path)
    local self = setmetatable({}, Filesystem)
    self.root = root_path or "."
    self.entries = {}
    self.git_statuses = {}
    self.selected_index = 1
    self.is_visible = true
    self:load_git_status()
    self:scan_initial()
    return self
end

function Filesystem:load_git_status()
    self.git_statuses = {}
    local clean_root = self.root:gsub("/+$", "")
    local target = (clean_root == "" or clean_root == ".") and "." or clean_root
    local cmd = "git -C '" .. target:gsub("'", "'\\''") .. "' status --porcelain 2>/dev/null"
    local handle = io.popen(cmd)
    if not handle then return end

    for line in handle:lines() do
        local status = line:sub(1, 2):gsub("%s+", "")
        local rel_path = line:sub(4):gsub("^%s*(.-)%s*$", "%1")
        if status == "??" then status = "U" end
        if status == "M" or status == "MM" then status = "M" end
        if status == "A" or status == "AM" then status = "A" end
        if status == "D" then status = "D" end

        self.git_statuses[rel_path] = status
        local basename = rel_path:match("([^/\\]+)$")
        if basename then
            self.git_statuses[basename] = status
        end
    end
    handle:close()
end

local function scan_dir(dir_path, depth, git_statuses)
    local results = {}
    local clean_root = dir_path:gsub("/+$", "")
    local target_cmd = (clean_root == "" or clean_root == ".") and "." or clean_root
    local cmd = "ls -1Ap '" .. target_cmd:gsub("'", "'\\''") .. "' 2>/dev/null"
    local handle = io.popen(cmd)
    if not handle then return results end

    for line in handle:lines() do
        local raw_line = line:gsub("^%s*(.-)%s*$", "%1")
        if raw_line ~= "" then
            local is_dir = (raw_line:sub(-1) == "/")
            local name = is_dir and raw_line:sub(1, -2) or raw_line
            if name ~= "." and name ~= ".." and not name:find("^%.git") and name ~= "target" and name ~= ".DS_Store" then
                local full_path = (clean_root == "." or clean_root == "") and name or (clean_root .. "/" .. name)
                local g_status = git_statuses and (git_statuses[full_path] or git_statuses[name])
                table.insert(results, {
                    name = name,
                    path = full_path,
                    is_dir = is_dir,
                    depth = depth or 0,
                    is_expanded = false,
                    git_status = g_status
                })
            end
        end
    end
    handle:close()

    table.sort(results, function(a, b)
        if a.is_dir ~= b.is_dir then
            return a.is_dir
        end
        return a.name:lower() < b.name:lower()
    end)

    return results
end

function Filesystem:scan_initial()
    self.entries = scan_dir(self.root, 0, self.git_statuses)
    self.selected_index = 1
end

function Filesystem:toggle_expand()
    local entry = self.entries[self.selected_index]
    if not entry or not entry.is_dir then return false end

    if entry.is_expanded then
        -- Collapse
        entry.is_expanded = false
        local i = self.selected_index + 1
        while i <= #self.entries and self.entries[i].depth > entry.depth do
            table.remove(self.entries, i)
        end
    else
        -- Expand
        entry.is_expanded = true
        local children = scan_dir(entry.path, entry.depth + 1, self.git_statuses)
        for idx, child in ipairs(children) do
            table.insert(self.entries, self.selected_index + idx, child)
        end
    end
    return true
end

function Filesystem:selected_entry()
    return self.entries[self.selected_index]
end

function Filesystem:move_down()
    if self.selected_index < #self.entries then
        self.selected_index = self.selected_index + 1
    end
end

function Filesystem:move_up()
    if self.selected_index > 1 then
        self.selected_index = self.selected_index - 1
    end
end

-- ─────────────────────────────────────────────────────────
-- File operations (per spec requirement #6)
-- ─────────────────────────────────────────────────────────
local function shell_quote(s)
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function path_exists(p)
    local f = io.open(p, "r")
    if f then f:close(); return true end
    return false
end

function Filesystem:create_file(name)
    if not name or name == "" then return false, "no name" end
    local full = self.root
    if full:sub(-1) ~= "/" then full = full .. "/" end
    full = full .. name
    -- Create parent dirs as needed
    local parent = full:match("^(.*)/[^/]+$")
    if parent and parent ~= "" and not path_exists(parent) then
        os.execute("mkdir -p " .. shell_quote(parent))
    end
    local f = io.open(full, "w")
    if not f then return false, "create failed" end
    f:close()
    self:load_git_status()
    self:scan_initial()
    return true
end

function Filesystem:create_dir(name)
    if not name or name == "" then return false, "no name" end
    local full = self.root
    if full:sub(-1) ~= "/" then full = full .. "/" end
    full = full .. name
    os.execute("mkdir -p " .. shell_quote(full))
    self:load_git_status()
    self:scan_initial()
    return true
end

function Filesystem:rename_entry(old_path, new_name)
    if not old_path or not new_name then return false, "missing args" end
    local parent = old_path:match("^(.*)/[^/]+$") or self.root
    if parent:sub(-1) ~= "/" then parent = parent .. "/" end
    local new_path = parent .. new_name
    os.execute("mv " .. shell_quote(old_path) .. " " .. shell_quote(new_path) .. " 2>/dev/null")
    self:load_git_status()
    self:scan_initial()
    return true
end

function Filesystem:delete_entry(path)
    if not path then return false, "no path" end
    if path:match("^/%.?$") then return false, "refused to delete root" end
    os.execute("rm -rf " .. shell_quote(path) .. " 2>/dev/null")
    self:load_git_status()
    self:scan_initial()
    return true
end

function Filesystem:copy_entry(src, dst)
    if not src or not dst then return false, "missing args" end
    -- If dst is a directory, copy into it; else use as new path
    os.execute("cp -r " .. shell_quote(src) .. " " .. shell_quote(dst) .. " 2>/dev/null")
    self:load_git_status()
    self:scan_initial()
    return true
end

function Filesystem:move_entry(src, dst)
    if not src or not dst then return false, "missing args" end
    os.execute("mv " .. shell_quote(src) .. " " .. shell_quote(dst) .. " 2>/dev/null")
    self:load_git_status()
    self:scan_initial()
    return true
end

-- Search file contents within the tree
function Filesystem:search(query, max_results)
    if not query or query == "" then return {} end
    max_results = max_results or 200
    local rg_check = io.popen("command -v rg >/dev/null 2>&1 && echo ok")
    local has_rg = false
    if rg_check then
        local r = rg_check:read("*a")
        rg_check:close()
        has_rg = (r and r:find("ok")) and true or false
    end

    local cmd
    if has_rg then
        cmd = "rg --vimgrep --no-heading --max-count=" .. max_results .. " --color=never -- " .. shell_quote(query) .. " " .. shell_quote(self.root) .. " 2>/dev/null | head -" .. max_results
    else
        cmd = "grep -rn --color=never -- " .. shell_quote(query) .. " " .. shell_quote(self.root) .. " 2>/dev/null | head -" .. max_results
    end

    local h = io.popen(cmd)
    if not h then return {} end
    local results = {}
    for line in h:lines() do
        local path, row, text = line:match("^([^:]+):(%d+):(.*)$")
        if path then
            table.insert(results, { path = path, row = tonumber(row) or 1, text = text })
        end
    end
    h:close()
    return results
end

-- Reveal current buffer file in explorer
function Filesystem:reveal_current(file_path)
    if not file_path then return false end
    -- Find the entry whose path matches
    for i, e in ipairs(self.entries) do
        if e.path == file_path then
            self.selected_index = i
            return true
        end
    end
    -- Try matching by basename
    local base = file_path:match("([^/\\]+)$")
    if base then
        for i, e in ipairs(self.entries) do
            if e.name == base then
                self.selected_index = i
                return true
            end
        end
    end
    return false
end

return Filesystem
