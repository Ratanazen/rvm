-- src/window.lua
-- Window/split management for RVM.
-- Supports: split (horizontal), vsplit (vertical), resize, close,
-- focus navigation (Ctrl-h/j/k/l), equalize.
--
-- Conceptually: a single workspace contains a tree of windows. Each window
-- references a buffer. The UI layer is responsible for rendering each
-- window into its allocated rectangle.

local Window = {}
Window.__index = Window

-- ─────────────────────────────────────────────────────────
-- Window tree
-- A Window is either:
--   { leaf=true, buffer_index=, active=, rect={x,y,w,h} }
-- or
--   { split="h"|"v", ratio=, children={ Window, Window }, rect={...} }
-- ─────────────────────────────────────────────────────────

function Window.new_single(buffer_index)
  return {
    leaf = true,
    buffer_index = buffer_index or 1,
    active = true,
  }
end

-- ─────────────────────────────────────────────────────────
-- Workspace manager
-- ─────────────────────────────────────────────────────────
local Workspace = {}
Workspace.__index = Workspace

function Workspace.new()
  local self = setmetatable({}, Workspace)
  self.root = Window.new_single(1)
  return self
end

-- Find the currently active leaf
function Workspace:_find_active(node)
  if not node then node = self.root end
  if node.leaf then
    if node.active then return node, nil end
    return nil, nil
  end
  for _, child in ipairs(node.children or {}) do
    local found, parent = self:_find_active(child)
    if found then return found, parent or node end
  end
  return nil, nil
end

function Workspace:active_window()
  return self:_find_active()
end

function Workspace:_walk(node, fn)
  fn(node)
  if not node.leaf and node.children then
    for _, c in ipairs(node.children) do
      self:_walk(c, fn)
    end
  end
end

-- Set active leaf to the given window
function Workspace:set_active(target)
  self:_walk(self.root, function(n)
    if n.leaf then n.active = (n == target) end
  end)
end

-- ─────────────────────────────────────────────────────────
-- Split / vsplit
-- ─────────────────────────────────────────────────────────
function Workspace:split(direction, new_buffer_index)
  -- direction: "h" = horizontal stack (new below), "v" = vertical stack (new right)
  local active, parent = self:_find_active()
  if not active then return nil end

  -- Take a buffer index for the new window
  new_buffer_index = new_buffer_index or active.buffer_index

  -- Replace the active leaf with a split containing both old and new
  local old_leaf = {
    leaf = true,
    buffer_index = active.buffer_index,
    active = false,
  }
  local new_leaf = {
    leaf = true,
    buffer_index = new_buffer_index,
    active = true,
  }
  local container
  if direction == "h" then
    container = { split = "h", ratio = 0.5, children = { old_leaf, new_leaf } }
  else
    container = { split = "v", ratio = 0.5, children = { old_leaf, new_leaf } }
  end

  -- Mutate the active node in place so parent references remain valid
  for k, _ in pairs(active) do active[k] = nil end
  for k, v in pairs(container) do active[k] = v end
end

function Workspace:close_active()
  local active, parent = self:_find_active()
  if not active then return end
  if not parent then
    -- Root window: do not close last window
    return
  end
  -- Remove active from parent's children, promote sibling
  local sibling
  for i, c in ipairs(parent.children) do
    if c ~= active then
      sibling = c
      break
    end
  end
  if not sibling then return end
  for k, _ in pairs(parent) do parent[k] = nil end
  for k, v in pairs(sibling) do parent[k] = v end
  -- Make the promoted window active
  self:set_active(parent)
end

function Workspace:close_others()
  -- Make active the only leaf at root
  local active = self:_find_active()
  if not active then return end
  self.root = {
    leaf = true,
    buffer_index = active.buffer_index,
    active = true,
  }
end

-- ─────────────────────────────────────────────────────────
-- Focus navigation: returns the next leaf in a direction
-- ─────────────────────────────────────────────────────────
function Workspace:focus(direction)
  -- direction: "left" | "right" | "up" | "down"
  -- Simplified: walk all leaves in order and pick the one most
  -- aligned in the requested direction.
  local leaves = {}
  self:_walk(self.root, function(n)
    if n.leaf then table.insert(leaves, n) end
  end)
  if #leaves <= 1 then return end
  local active = self:_find_active()
  if not active then return end

  -- Sort leaves by spatial position based on direction
  local function score(leaf)
    -- We don't have actual rects yet; assume DFS traversal order.
    -- For our simple model, we just use the traversal order:
    --  - right/down → next leaf in order
    --  - left/up    → previous leaf in order
    return 0
  end

  -- Find current index in leaves list
  local cur_idx
  for i, l in ipairs(leaves) do
    if l == active then cur_idx = i; break end
  end
  if not cur_idx then return end

  local new_idx = cur_idx
  if direction == "right" or direction == "down" then
    new_idx = cur_idx + 1
    if new_idx > #leaves then new_idx = 1 end
  elseif direction == "left" or direction == "up" then
    new_idx = cur_idx - 1
    if new_idx < 1 then new_idx = #leaves end
  end
  if new_idx == cur_idx then return end
  self:set_active(leaves[new_idx])
end

function Workspace:focus_left()  self:focus("left")  end
function Workspace:focus_right() self:focus("right") end
function Workspace:focus_up()   self:focus("up")   end
function Workspace:focus_down() self:focus("down")  end

-- ─────────────────────────────────────────────────────────
-- Resize
-- ─────────────────────────────────────────────────────────
function Workspace:resize(direction, amount)
  local active, parent = self:_find_active()
  if not parent or not parent.split then return end
  amount = amount or 0.05
  -- Adjust ratio: if active is child[1], ratio increases for child[1]
  if parent.children[1] == active then
    if direction == "inc" then
      parent.ratio = math.min(0.95, (parent.ratio or 0.5) + amount)
    else
      parent.ratio = math.max(0.05, (parent.ratio or 0.5) - amount)
    end
  elseif parent.children[2] == active then
    if direction == "inc" then
      parent.ratio = math.max(0.05, (parent.ratio or 0.5) - amount)
    else
      parent.ratio = math.min(0.95, (parent.ratio or 0.5) + amount)
    end
  end
end

function Workspace:inc_height() self:resize("inc") end
function Workspace:dec_height() self:resize("dec") end
function Workspace:inc_width()  self:resize("inc") end
function Workspace:dec_width()  self:resize("dec") end

function Workspace:equalize()
  self:_walk(self.root, function(n)
    if not n.leaf and n.children then
      n.ratio = 0.5
    end
  end)
end

-- ─────────────────────────────────────────────────────────
-- Layout computation
-- Given a root rect (x, y, w, h), compute the rect for every leaf
-- ─────────────────────────────────────────────────────────
local function compute_layout(node, rect, results)
  results = results or {}
  if not node then return results end
  if node.leaf then
    node.rect = rect
    table.insert(results, node)
    return results
  end
  local ratio = node.ratio or 0.5
  if node.split == "h" then
    -- horizontal stack: child1 on top, child2 on bottom
    local h1 = math.floor(rect.h * ratio)
    local h2 = rect.h - h1
    compute_layout(node.children[1], { x = rect.x, y = rect.y, w = rect.w, h = h1 }, results)
    compute_layout(node.children[2], { x = rect.x, y = rect.y + h1, w = rect.w, h = h2 }, results)
  elseif node.split == "v" then
    local w1 = math.floor(rect.w * ratio)
    local w2 = rect.w - w1
    compute_layout(node.children[1], { x = rect.x, y = rect.y, w = w1, h = rect.h }, results)
    compute_layout(node.children[2], { x = rect.x + w1, y = rect.y, w = w2, h = rect.h }, results)
  end
  return results
end

function Workspace:layout(rect)
  return compute_layout(self.root, rect)
end

-- ─────────────────────────────────────────────────────────
-- Iterate all leaves
-- ─────────────────────────────────────────────────────────
function Workspace:leaves()
  local out = {}
  self:_walk(self.root, function(n)
    if n.leaf then table.insert(out, n) end
  end)
  return out
end

function Workspace:count()
  return #self:leaves()
end

return Workspace
