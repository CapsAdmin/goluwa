require("quad")

-- local references to common functions
local assert = assert
local insert = table.insert
local remove = table.remove
local ipairs = ipairs

local min = math.min
local max = math.max
local abs = math.abs
local sqrt = math.sqrt
local cos = math.cos
local atan2 = math.atan2

local base = _G

local quad = quad

module("fizz")

statics = {}
dynamics = {}
kinematics = {}
--ghosts = {}
gravity = 0
maxVelocity = 1000
buffer = {}
cchecks = 0
mshapes = 0

-- remove all elements from a numerically indexed table
function clearBuffer(b)
  for i = 1, #b do
    b[i] = nil
  end
end

-- clamps number between two values
function clamp(n, low, high)
  return min(max(n, low), high)
end

-- clamps vector size if above a given length
function clampVec(x, y, len)
  local d = sqrt(x*x + y*y)
  if d > len then
    local n = 1/d * len
    x, y = x * n, y * n
  end
  return x, y
end

-- returns shape index and its list
function findShape(s)
  local t = s.list
  for k, v in ipairs(t) do
    if v == s then
      return k, t
    end
  end
end

-- removes shape from its list
function removeShape(s)
  local k, t = findShape(s)
  if k then
    s.list = nil
    remove(t, k)
    quad.remove(s)
  end
end

-- returns center position and half width/height for any shape type
function getBounds(s)
  local x, y = s.x, s.y
  local hw, hh
  local t = s.shape
  if t == "rect" then
    hw, hh = s.hw, s.hh
  elseif t == "circle" then
    hw, hh = s.r, s.r
  elseif t == "line" then
    local dx, dy = s.x2 - x, s.y2 - y
    x, y = x + dx/2, y + dy/2
    hw, hh = abs(dx), abs(dy)
  end
  return x, y, hw, hh
end

-- reinsert in the quadtree
function repartition(s)
  local x, y, hw, hh = getBounds(s)
  quad.insert(s, x, y, hw, hh)
end

-- rects have a center position and half-width/height
function addRectShape(list, x, y, w, h)
  local s = { list = list, shape = "rect", x = x, y = y, hw = w/2, hh = h/2 }
  insert(list, s)
  repartition(s)
  return s
end

-- circles have a center position and radius
function addCircleShape(list, x, y, r)
  local s = { list = list, shape = "circle", x = x, y = y, r = r }
  insert(list, s)
  repartition(s)
  return s
end

-- lines have a starting position and ending position
-- the direction of the line affects which side can be passed through
function addLineShape(list, x, y, x2, y2)
  assert(x ~= x2 or y ~= y2, "Line has zero length")
  local s = { list = list, shape = "line", x = x, y = y, x2 = x2, y2 = y2 }
  insert(list, s)
  repartition(s)
  return s
end

shapeCtors =
{
  rect = addRectShape, 
  circle = addCircleShape,
  line = addLineShape
}

-- static shapes do not move or respond to collisions
function addStatic(shape, ...)
  return shapeCtors[shape](statics, ...)
end

-- dynamic shapes are affected by gravity and collisions
function addDynamic(shape, ...)
  local s = shapeCtors[shape](dynamics, ...)
  s.friction = 1
  s.bounce = 0
  s.damping = 0
  s.xv, s.yv = 0, 0
  return s
end

-- kinematic shapes move only when assigned a velocity
function addKinematic(shape, ...)
  local s = shapeCtors[shape](kinematics, ...)
  s.xv, s.yv = 0, 0
  return s
end

function testRectRect(a, b)
  -- distance between the shapes
  local dx, dy = a.x - b.x, a.y - b.y
  local adx = abs(dx)
  local ady = abs(dy)
  -- sum of the half-widths
  local shw, shh = a.hw + b.hw, a.hh + b.hh
  if adx > shw or ady > shh then
    return
  end
  -- shortest separation
  local sx, sy = shw - adx, shh - ady
  -- ugly! (there must be a simpler way?)
  if sx < sy then
    sy = 0
  else
    sx = 0
  end
  if dx < 0 then
    sx = -sx
  end
  if dy < 0 then
    sy = -sy
  end
  -- todo: inside edges?
  -- penertation depth
  local pen = sqrt(sx*sx + sy*sy)
  if pen > 0 then
    return sx/pen, sy/pen, pen
  end
end

function testRectCircle(a, b)
  local r = b.r
  -- project center of the circle onto the rect
  local px, py = b.x, b.y
  local rl, rr = a.x - a.hw, a.x + a.hw
  local rt, rb = a.y - a.hh, a.y + a.hh
  if px < rl then
    px = rl
  end
  if px > rr then
    px = rr
  end
  if py < rt then
    py = rt
  end
  if py > rb then
    py = rb
  end

  -- todo: temporary fix
  if px == b.x and py == b.y then
    -- circle center is inside the rect
    local dx, dy = a.x - b.x, a.y - b.y
    -- sum of the half-widths
    local shw, shh = a.hw + r, a.hh + r
    local adx = abs(dx)
    local ady = abs(dy)
    -- shortest separation
    local sx, sy = shw - adx, shh - ady
    -- ugly! (there must be a simpler way?)
    if sx < sy then
      sy = 0
    else
      sx = 0
    end
    if dx < 0 then
      sx = -sx
    end
    if dy < 0 then
      sy = -sy
    end
    local pen = sqrt(sx*sx + sy*sy)
    return sx/pen, sy/pen, pen
  end

  local dx, dy = px - b.x, py - b.y
  local distSq = dx*dx + dy*dy
  if distSq > r*r then
    return
  end

  local pen = sqrt(distSq)
  --assert(pen > 0)
  --if pen > 0 then
    return dx/pen, dy/pen, r - pen
  --end
end

function testCircleCircle(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  local distSq = dx*dx + dy*dy
  local radii = a.r + b.r
  if distSq > radii*radii then
    return
  end
  local dist = sqrt(distSq)
  if dist > 0 then
    local pen = radii - dist
    return dx/dist, dy/dist, pen
  end
end

-- signed area of a triangle
function signedArea(ax, ay, bx, by, cx, cy)
  return (ax - cx)*(by - cy) - (ay - cy)*(bx - cx)
end

function testLineLine(a, b)
  return false
--[[
  -- major todo: figure out the separation/normals
  assert(false, "Dynamic line shapes are not supported")
  local sa1 = signedArea(a.x, a.y, b.x, b.y, b.x2, b.y2)
  local sa2 = signedArea(a.x, a.y, b.x, b.y, a.x2, a.y2)

  if sa1*sa2 >= 0 then
    return
  end
  local sa3 = signedArea(a.x2, a.y2, b.x2, b.y2, a.x, a.y)
  local sa4 = sa3 + sa2 - sa1
  if sa3*sa4 >= 0 then
    return
  end

  local t = sa3/(sa3 - sa4)
  local dx, dy = a.x2 - a.x, a.y2 - a.y
  local d = sqrt(dx*dx + dy*dy)
  if d > 0 then
    local nx, ny = dy/d, -dx/d
    return nx, ny, (1 - t)*d
  end
  ]]
end

function testLineRect(a, b)
  -- line vector
  local dx, dy = a.x2 - a.x, a.y2 - a.y
  -- line halflength vector
  local hdx, hdy = dx/2, dy/2
  -- line midpoint
  local mx, my = a.x + hdx, a.y + hdy
  -- translate midpoint to rect origin
  mx, my = mx - b.x, my - b.y
  
  -- separating axes tests
  local ahdx = abs(hdx)
  if abs(mx) > b.hw + ahdx then
    return
  end
  local ahdy = abs(hdy)
  if abs(my) > b.hh + ahdy then
    return
  end

  -- wedge product test (cross product in 2D)
  local cross1 = b.hw*ahdy + b.hh*ahdx
  local cross2 = abs(mx*hdy - my*hdx)
  if cross2 > cross1 then
    return
  end

  -- collision normal is the line rotated by 90 degrees
  local d = sqrt(dx*dx + dy*dy)
  local nx, ny = dy/d, -dx/d
  
  -- allow passing through one side of the line
  local vx = (a.xv or 0) - (b.xv or 0)
  local vy = (a.yv or 0) - (b.yv or 0)
  local dot = vx*nx + vy*ny
  if dot > 0 then
    return
  end

  -- todo: penetration is incorrect here
  -- go over linecircle since it's correct there
  local pen = sqrt(cross1) - sqrt(cross2)

  return nx, ny, pen
end

function testLineCircle(a, b)
  -- project circle center onto the line
  local dx, dy = a.x2 - a.x, a.y2 - a.y
  local npx, npy = b.x - a.x, b.y - a.y
  local dot1 = npx*dx + npy*dy
  local dot2 = dx*dx + dy*dy
  --assert(dot2 ~= 0, "Line has zero length")
  local u = clamp(dot1/dot2, 0, 1)
  local qx = a.x + u*dx
  local qy = a.y + u*dy
  local qdx, qdy = b.x - qx, b.y - qy
  local qd = sqrt(qdx*qdx + qdy*qdy)
  if qd >= b.r then
    return
  end
  local d = sqrt(dx*dx + dy*dy)
  local nx, ny = dy/d, -dx/d

  -- allow passing through one side of the line
  local vx = (a.xv or 0) - (b.xv or 0)
  local vy = (a.yv or 0) - (b.yv or 0)
  local dot3 = vx*nx + vy*ny
  if dot3 > 0 then
    return
  end
  return nx, ny, b.r - qd
end

shapeTests =
{
  line = { line = testLineLine, rect = testLineRect, circle = testLineCircle },
  rect = { rect = testRectRect, circle = testRectCircle },
  circle = { circle = testCircleCircle },
}

-- returns normalized separation vector and penetration
function testShapes(a, b)
  -- find collision function
  local test = shapeTests[a.shape][b.shape]
  local r = false
  -- swap the colliding shapes?
  if test == nil then
    test = shapeTests[b.shape][a.shape]
    a, b = b, a
    r = true
  end
  local x, y, p = test(a, b)
  -- reverse direction of the collision normal
  if r == true and x and y then
    x, y = -x, -y
  end
  return x, y, p
end

-- moves shape by given amount without checking for collisions
function moveShape(a, dx, dy)
  a.x = a.x + dx
  a.y = a.y + dy
  if a.shape == 'line' then
    a.x2 = a.x2 + dx
    a.y2 = a.y2 + dy
  end
  repartition(a)
end

-- returns the velocity of shape
function getVelocity(a)
  return a.xv, a.yv
end

-- assigns velocity of shape
function setVelocity(a, x, y)
  a.xv = x
  a.yv = y
end

-- updates the simulation
function update(dt)
  -- update some stats
  mshapes = 0
  cchecks = 0
  
  -- todo: as delta increases expect to see tunneling
  dt = min(dt, 1)

  -- update velocity vectors
  local grav = gravity*dt
  for i = 1, #dynamics do
    local d = dynamics[i]
    -- damping
    local damp = clamp(1 - d.damping*dt, 0, 1)
    d.xv = d.xv*damp
    d.yv = d.yv*damp
    -- gravity
    d.yv = d.yv + grav
    d.xv, d.yv = clampVec(d.xv, d.yv, maxVelocity)
  end
  
  -- move shapes
  for i = 1, #kinematics do
    local k = kinematics[i]
    moveShape(k, k.xv*dt, k.yv*dt)
    mshapes = mshapes + 1
  end

  for i = 1, #dynamics do
    local d = dynamics[i]
    moveShape(d, d.xv*dt, d.yv*dt)
    mshapes = mshapes + 1
    
    --[[
    -- check and resolve collisions
    for j, s in ipairs(statics) do
      checkCollision(d, s)
    end
    for j, k in ipairs(kinematics) do
      checkCollision(d, k)
    end
    for j = i + 1, #dynamics do
      checkCollision(d, dynamics[j])
    end
    ]]

    -- get area covered by the shape
    local x, y, hw, hh = getBounds(d)
    -- reuse buffer so we don't create tables all the time
    clearBuffer(buffer)
    quad.select(buffer, x, y, hw, hh)
    for j, s in ipairs(buffer) do
      if s ~= d then
        -- possible todo: eliminate repeating collision pairs
        checkCollision(d, s)
        cchecks = cchecks + 1
      end
    end
  end
end

-- checks for collisions
function checkCollision(a, b)
  local nx, ny, pen = testShapes(a, b)
  if nx and ny and pen then
    -- user resolution
    local res1, res2 = true, true
    if a.onCollide then
      res1 = a:onCollide(b, nx, ny, pen)
    end
    if b.onCollide then
      res2 = b:onCollide(a, -nx, -ny, pen)
    end
    if res1 == true and res2 == true then
      solveCollision(a, b, nx, ny, pen)
    end
  end
end

-- resolves collisions
function solveCollision(a, b, nx, ny, pen)
  local vx, vy = a.xv - (b.xv or 0), a.yv - (b.yv or 0)
  local dp = vx*nx + vy*ny
  -- objects moving towards each other?
  if dp < 0 then
    -- project velocity onto collision normal
    local pnx, pny = nx*dp, ny*dp
    -- find tangent velocity
    local tx, ty = vx - pnx, vy - pny
    -- respond to the collision
    local r = 1 + a.bounce
    local f = a.friction
    local dvx = pnx*r + tx*f
    local dvy = pny*r + ty*f
    a.xv = a.xv - dvx
    a.yv = a.yv - dvy

    if b.list == dynamics then
      local ar = atan2(vx, vy) - atan2(nx, ny)
      local force = cos(ar)
      b.xv = b.xv - dvx*force
      b.yv = b.yv - dvy*force
    end
  end
  -- separate
  if abs(nx) > 0 or abs(ny) > 0 then
    moveShape(a, nx*pen, ny*pen)
  end
end

-- test a point versus a list of shapes
-- returns first intersecting shape and its index
function queryPointList(x, y, list)
  for i, v in ipairs(list) do
    if v.shape == 'rect' then
      local dx = abs(x - v.x)
      local dy = abs(y - v.y)
      if dx < v.hw and dy < v.hh then
        return v, i
      end
    elseif v.shape == 'circle' then
      local dx = abs(x - v.x)
      local dy = abs(y - v.y)
      local distSq = dx*dx + dy*dy
      if distSq < v.r*v.r then
        return v, i
      end
    end
  end
end

function queryPoint(x, y)
  local q, i = queryPointList(x, y, statics)
  if q == nil or i == nil then
    q, i = queryPointList(x, y, dynamics)
  end
  return q, i
end

--[[
function queryShape(result, a)
  local x, y, hw, hh = getBounds(a)
  quad.select(result, x, y, hw, hh)
  for i = #result, 1 do
    local b = result[i]
    if a ~= b then
      if testShapes(a, b) == nil then
        table.remove(result, i)
      end
    end
  end
end
]]