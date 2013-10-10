-- Lua quadtree implementation
-- ===========================
-- Features
-- + dynamic world size
-- + supports objects of any size
-- + cells are reused instead of garbage collected
-- + adjustable depth via mincellsize

local base = _G

-- references to common functions
local table = table
local ipairs = ipairs
local abs = math.abs
local max = math.max
local tinsert = table.insert
local tremove = table.remove
module("quad")

dirs = { 'nw', 'sw', 'ne', 'se' }
rdirs = { nw='se', sw='ne', ne='sw', se='nw' }
root = nil
handles = {}
cellpool = {}
mincellsize = 8 -- must be > 0
-- some stats
objects = 0
livecells = 0

local function addCell(p, d, x, y, s)
  local c
  if #cellpool == 0 then
    c = {}
  else
    c = tremove(cellpool)
    c.nw = nil
    c.ne = nil
    c.sw = nil
    c.se = nil
  end
  c.parent = p
  c.relation = d
  c.x = x
  c.y = y
  c.side = s
  livecells = livecells + 1
  return c
end

local function removeCell(c)
  if c.parent then
    c.parent[c.relation] = nil
  end
  livecells = livecells - 1
  tinsert(cellpool, c)
end

local function hasChildren(c)
  return c.nw ~= nil or c.sw ~= nil or c.ne ~= nil or c.se ~= nil
end

local function fitsInCell(c, x, y, s)
  local dx = abs(c.x - x)
  local dy = abs(c.y - y)
  local eight = c.side/4
  return s < eight and dx < eight and dy < eight
end

-- returns direction string and offset
local function getSubCell(c, x, y)
  local d, ox, oy
  if x < c.x then
    if y < c.y then
      d, ox, oy = 'nw', -1, -1
    else
      d, ox, oy = 'sw', -1, 1
    end
  else
    if y < c.y then
      d, ox, oy = 'ne', 1, -1
    else
      d, ox, oy = 'se', 1, 1
    end
  end
  return d, ox, oy
end

local function getCell(c, x, y, s)
  -- does the object fit inside this cell?
  local quarter = c.side/2
	if s*2 > quarter or quarter < mincellsize then
		return c
  end
  -- find which sub-cell the object belongs to
  local d, ox, oy = getSubCell(c, x, y)
  -- create sub-cell if necessary
  if c[d] == nil then
    local eight = quarter/2
    ox = ox*eight + c.x
    oy = oy*eight + c.y
    c[d] = addCell(c, d, ox, oy, quarter)
  end
  -- descend deeper down the tree
  return getCell(c[d], x, y, s)
end

local function selectAllCell(root, dest)
  for i, v in ipairs(root) do
    tinsert(dest, v)
  end
  for i, v in ipairs(dirs) do
    local c = root[v]
    if c then
      selectAllCell(c, dest)
    end
  end
end

local function selectCell(root, dest, x, y, hw, hh)
  for i, v in ipairs(root) do
    tinsert(dest, v)
  end
  for i, v in ipairs(dirs) do
    local c = root[v]
    if c then
      local r = c.side
      local dx = abs(c.x - x)
      local dy = abs(c.y - y)
      -- the query intersect this cell?
      if r > dx - hw and r > dy - hh then
        -- the query covers the cell entirely?
        if r < hw - dx and r < hh - dy then
          selectAllCell(c, dest)
        else
          selectCell(c, dest, x, y, hw, hh)
        end
      end
    end
  end
end

function select(dest, x, y, hw, hh)
  if root then
    selectCell(root, dest, x, y, hw, hh);
  end
end

function selectAABB(dest, l, t, r, b)
  -- re-align aabb if necessary
  if l > r then
    l, r = r, l
  end
  if t > b then
    t, b = b, t
  end
  local x, y = (l + r)/2, (t + b)/2
  local hw = (r - l)/2
  local hh = (b - t)/2
  return select(dest, x, y, hw, hh)
end

function selectAll(dest, x, y, hw, hh)
  if root then
    selectAllCell(dest)
  end
end

function insert(object, x, y, hw, hh)
  local s = max(hw, hh)
  --assert(s > 0)
  local c = handles[object]
  if c then
    -- object still fits in its current cell?
    if fitsInCell(c, x, y, s) then
      return
    end
    remove(object)
  end

  if root == nil then
    root = addCell(nil, 'none', 0, 0, s*4)
  end
  while true do
    -- can the object fit in the root cell?
    if fitsInCell(root, x, y, s) then
      local c = getCell(root, x, y, s)
      -- insert object
      tinsert(c, object)
      handles[object] = c
      objects = objects + 1
      return
    end
    -- expand tree upwards
    local d, ox, oy = getSubCell(root, x, y)
    d = rdirs[d]
    local quarter = root.side/2
    ox = ox*quarter + root.x
    oy = oy*quarter + root.y
    -- create new root
    local nroot = addCell(nil, 'none', ox, oy, root.side*2)
    nroot[d] = root
    root.relation = d
    root.parent = nroot
    root = nroot
  end
end

local function trimBottom(c)
  while c and #c == 0 and not hasChildren(c) do
    local p = c.parent
    removeCell(c)
    c = p
  end
end

function remove(object)
  local c = handles[object]
  if c == nil then
    return
  end
  objects = objects - 1
  handles[object] = nil
  -- todo: make constant time
  for i, v in ipairs(c) do
    if v == object then
      tremove(c, i)
      break
    end
  end
  trimBottom(c)
end

-- trim the top of the quadtree deleting
-- root nodes if they only have a single child
function trimTop()
  while root and #root == 0 do
    -- root has one child only?
    local only = false 
    local child = 'none'
    for i, v in ipairs(dirs) do
      if root[v] then
        if only == true then
					-- root has more than one child
          return
        end
        only = true
        child = v
      end
    end
    local nroot
    if only then
      -- severe the link between child and parent
      nroot = root[child]
      nroot.relation = 'none'
      nroot.parent = nil

			-- before we remove the old root
      -- make sure it doesn't point to its only child
      root[child] = nil
    end
    removeCell(root)
    -- assign new root
    root = nroot
  end
end