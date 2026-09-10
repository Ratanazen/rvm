-- src/git.lua
-- Git workflow for RVM.
-- Provides: status, diff, stage, unstage, commit, push, pull, branch, log, blame.
-- Integrates with `lazygit` when present, otherwise falls back to native git.

local Git = {}
Git.__index = Git

-- ─────────────────────────────────────────────────────────
-- Detection helpers
-- ─────────────────────────────────────────────────────────
local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function run(cmd)
  local h = io.popen(cmd .. " 2>&1")
  if not h then return "", false end
  local out = h:read("*a") or ""
  h:close()
  -- Strip trailing newline
  out = out:gsub("\n$", "")
  return out, true
end

local function has_binary(name)
  local h = io.popen("command -v " .. name .. " 2>/dev/null")
  if not h then return false end
  local r = h:read("*l")
  h:close()
  return r and r ~= ""
end

function Git.has_lazygit()
  return has_binary("lazygit")
end

function Git.is_repo(dir)
  local _, ok = run("git -C " .. shell_quote(dir or ".") .. " rev-parse --is-inside-work-tree")
  return ok
end

-- ─────────────────────────────────────────────────────────
-- Branch info
-- ─────────────────────────────────────────────────────────
function Git.current_branch(dir)
  local out = run("git -C " .. shell_quote(dir or ".") .. " branch --show-current 2>/dev/null")
  out = out:gsub("%s+", "")
  if out == "" then
    -- Maybe detached HEAD
    out = run("git -C " .. shell_quote(dir or ".") .. " rev-parse --short HEAD 2>/dev/null")
    out = out:gsub("%s+", "")
  end
  return out
end

function Git.branch_list(dir)
  local out = run("git -C " .. shell_quote(dir or ".") .. " branch --list 2>/dev/null")
  local list = {}
  for line in out:gmatch("[^\n]+") do
    local current = line:sub(1, 1) == "*"
    local name = line:sub(2):gsub("^%s+", ""):gsub("%s+$", "")
    table.insert(list, { name = name, current = current })
  end
  return list
end

function Git.remote_url(dir)
  return run("git -C " .. shell_quote(dir or ".") .. " config --get remote.origin.url 2>/dev/null")
end

-- ─────────────────────────────────────────────────────────
-- Status (porcelain)
-- ─────────────────────────────────────────────────────────
function Git.status(dir)
  local out = run("git -C " .. shell_quote(dir or ".") .. " status --porcelain 2>/dev/null")
  local entries = {}
  for line in out:gmatch("[^\n]+") do
    if line ~= "" then
      local s = line:sub(1, 2)
      local path = line:sub(4):gsub("^%s+", "")
      -- Strip quotes if any
      path = path:gsub('^"', ""):gsub('"$', "")
      -- Handle renames: "OLD -> NEW"
      local arrow = path:match("(.+) -> (.+)")
      if arrow then
        local old_p, new_p = path:match("(.+) -> (.+)")
        path = new_p
      end
      local kind = "modified"
      if s:match("%?%?") then kind = "untracked"
      elseif s:match("A") then kind = "added"
      elseif s:match("D") then kind = "deleted"
      elseif s:match("R") then kind = "renamed"
      elseif s:match("M") then kind = "modified"
      end
      table.insert(entries, { status = s, kind = kind, path = path })
    end
  end
  return entries
end

function Git.status_summary(dir)
  local entries = Git.status(dir)
  local counts = { modified = 0, added = 0, deleted = 0, untracked = 0, staged = 0 }
  for _, e in ipairs(entries) do
    if e.kind == "modified" then counts.modified = counts.modified + 1 end
    if e.kind == "added" then counts.added = counts.added + 1 end
    if e.kind == "deleted" then counts.deleted = counts.deleted + 1 end
    if e.kind == "untracked" then counts.untracked = counts.untracked + 1 end
    if e.status:sub(1, 1):match("[AMDR]") then counts.staged = counts.staged + 1 end
  end
  counts.total = #entries
  return counts
end

-- ─────────────────────────────────────────────────────────
-- Diff
-- ─────────────────────────────────────────────────────────
function Git.diff(dir, file)
  local cmd = "git -C " .. shell_quote(dir or ".") .. " diff -- " .. (file and shell_quote(file) or "") .. " 2>/dev/null"
  return run(cmd)
end

function Git.diff_staged(dir, file)
  local cmd = "git -C " .. shell_quote(dir or ".") .. " diff --staged -- " .. (file and shell_quote(file) or "") .. " 2>/dev/null"
  return run(cmd)
end

-- ─────────────────────────────────────────────────────────
-- Stage / unstage
-- ─────────────────────────────────────────────────────────
function Git.stage(dir, file)
  local cmd = "git -C " .. shell_quote(dir or ".") .. " add -- " .. (file and shell_quote(file) or ".") .. " 2>/dev/null"
  run(cmd)
end

function Git.unstage(dir, file)
  local cmd = "git -C " .. shell_quote(dir or ".") .. " reset HEAD -- " .. (file and shell_quote(file) or ".") .. " 2>/dev/null"
  run(cmd)
end

function Git.stage_all(dir)
  run("git -C " .. shell_quote(dir or ".") .. " add -A 2>/dev/null")
end

function Git.unstage_all(dir)
  run("git -C " .. shell_quote(dir or ".") .. " reset 2>/dev/null")
end

-- ─────────────────────────────────────────────────────────
-- Commit
-- ─────────────────────────────────────────────────────────
function Git.commit(dir, message)
  if not message or message == "" then
    return false, "empty message"
  end
  local out = run(string.format(
    "git -C %s commit -m %s 2>&1",
    shell_quote(dir or "."), shell_quote(message)
  ))
  return out, true
end

function Git.commit_all(dir, message)
  Git.stage_all(dir)
  return Git.commit(dir, message)
end

-- ─────────────────────────────────────────────────────────
-- Push / pull
-- ─────────────────────────────────────────────────────────
function Git.push(dir)
  return run("git -C " .. shell_quote(dir or ".") .. " push 2>&1")
end

function Git.pull(dir)
  return run("git -C " .. shell_quote(dir or ".") .. " pull 2>&1")
end

-- ─────────────────────────────────────────────────────────
-- Log
-- ─────────────────────────────────────────────────────────
function Git.log(dir, max_entries)
  max_entries = max_entries or 30
  local cmd = string.format(
    "git -C %s log --pretty='%%h|%%an|%%ad|%%s' --date=short -n %d 2>/dev/null",
    shell_quote(dir or "."), max_entries
  )
  local out = run(cmd)
  local entries = {}
  for line in out:gmatch("[^\n]+") do
    local h, an, ad, s = line:match("([^|]+)|([^|]+)|([^|]+)|(.+)")
    if h then
      table.insert(entries, { hash = h, author = an, date = ad, subject = s })
    end
  end
  return entries
end

-- ─────────────────────────────────────────────────────────
-- Blame
-- ─────────────────────────────────────────────────────────
function Git.blame(dir, file)
  if not file then return {} end
  local cmd = string.format(
    "git -C %s blame --porcelain %s 2>/dev/null",
    shell_quote(dir or "."), shell_quote(file)
  )
  local out = run(cmd)
  local entries = {}
  local cur = nil
  for line in out:gmatch("[^\n]+") do
    local hash, orig_line, final_line = line:match("^(%x+) (%d+) (%d+)")
    if hash then
      cur = { hash = hash:sub(1, 8), line = tonumber(final_line) }
      table.insert(entries, cur)
    else
      local author = line:match("^author%s+(.+)$")
      local date   = line:match("^author%-time%s+(%d+)")
      local summary = line:match("^summary%s+(.+)$")
      if author and cur then cur.author = author end
      if date and cur then cur.date = os.date("%Y-%m-%d", tonumber(date) or 0) end
      if summary and cur then cur.summary = summary end
    end
  end
  return entries
end

-- ─────────────────────────────────────────────────────────
-- Branch ops
-- ─────────────────────────────────────────────────────────
function Git.checkout(dir, branch)
  return run("git -C " .. shell_quote(dir or ".") .. " checkout " .. shell_quote(branch) .. " 2>&1")
end

function Git.create_branch(dir, name)
  return run("git -C " .. shell_quote(dir or ".") .. " checkout -b " .. shell_quote(name) .. " 2>&1")
end

function Git.delete_branch(dir, name)
  return run("git -C " .. shell_quote(dir or ".") .. " branch -d " .. shell_quote(name) .. " 2>&1")
end

-- ─────────────────────────────────────────────────────────
-- Lazygit integration
-- ─────────────────────────────────────────────────────────
function Git.launch_lazygit(dir)
  if not Git.has_lazygit() then return false, "lazygit not installed" end
  -- Suspend raw mode first via app state? We're a pure module.
  -- Caller (app) is responsible for suspending terminal raw mode.
  local cmd = "cd " .. shell_quote(dir or ".") .. " && lazygit 2>&1"
  local out = run(cmd)
  return true, out
end

-- ─────────────────────────────────────────────────────────
-- Aggregate header info
-- ─────────────────────────────────────────────────────────
function Git.summary(dir)
  local repo = Git.is_repo(dir)
  if not repo then
    return { repo = false, branch = "", counts = { total = 0, modified = 0, added = 0, deleted = 0, untracked = 0, staged = 0 } }
  end
  return {
    repo    = true,
    branch  = Git.current_branch(dir),
    counts  = Git.status_summary(dir),
    remote  = Git.remote_url(dir),
  }
end

return Git
