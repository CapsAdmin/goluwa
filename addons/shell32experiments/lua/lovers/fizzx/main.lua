require("fizz")

fizz.maxVelocity = 300
fizz.gravity = 1200

-- give us some stuff to play with
function love.load()
  map =
  {
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 5, 5, 5, 5, 5, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
  1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 
  1, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 0, 0, 0, 0, 0, 3, 1, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 3, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 1, 1, 
  1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 3, 1, 1, 1, 1, 1, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 3, 1, 1, 1, 1, 1, 1, 4, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
  }

  h = 16
  w = #map/h
  
  love.graphics.setMode((w - 1)*16, (h - 1)*16)

  statics = {}
  dynamics = {}
  kinematics = {}
  for x = 0, w - 1 do
    for y = 0, h - 1 do
      local i = map[y*w + x + 1]
      if i > 0 then
        local wx, wy = x*16, y*16
        if i == 1 then
          local s = fizz.addStatic('rect', wx, wy, 16, 16)
          table.insert(statics, s)
        elseif i == 2 then
          local r = math.random(4, 16)
          local s
          if math.random(1, 2) == 1 then
            s = fizz.addDynamic('circle', wx, wy, r)
          else
            r = r * 2
            s = fizz.addDynamic('rect', wx, wy, r, r)
          end
          s.bounce = 0
          s.friction = 0.1
          table.insert(dynamics, s)
        elseif i == 3 then
          local s = fizz.addStatic('line', wx + 8, wy - 8, wx - 8, wy + 8)
          table.insert(statics, s)
        elseif i == 4 then
          local s = fizz.addStatic('line', wx + 8, wy + 8, wx - 8, wy - 8)
          table.insert(statics, s)
        elseif i == 5 then
          local s = fizz.addStatic('line', wx + 8, wy, wx - 8, wy)
          table.insert(statics, s)
        end
      end
    end
  end


  -- player
  p = fizz.addDynamic('rect', 32, 0, 8, 8)
  table.insert(dynamics, p)
  p.damping = 5
  p.friction = 0.15
  p.onCollide = function(p, b, nx, ny, pen)
    if ny < 0 then
      p.grounded = true
      p.jumptime = nil
    end
    return true
  end

  -- kinematic platform
  k = fizz.addKinematic('rect', 256, 300, 30, 10)
  table.insert(kinematics, k)
  k.yv = -50
end

-- nothing too heavy
function love.update(dt)
  -- reset player 'grounded' variable
  p.grounded = false

  -- delta must be in seconds
  -- not too large or there will be tunneling
  dt = math.min(dt, 0.032)
  
  fizz.update(dt)
  
  -- wrap kinematic platform
  if k.y < 0 then
    k.y = 300
  end

  if p.jumptime then
    p.jumptime = p.jumptime + dt
  end
  -- horizontall speed
  local move = 1500
  if p.grounded == false then
    move = 1000
  end
  -- vertical speed
  local jump = 5000
  local l = love.keyboard.isDown("left")
  local r = love.keyboard.isDown("right")
  local u = love.keyboard.isDown(" ")
  -- player horizontal velocity
  if l then
    p.xv = p.xv - move*dt
  elseif r then
    p.xv = p.xv + move*dt
  end
  -- jumping
  if u then
    -- keep track of jump time
    if p.grounded then
      p.jumptime = dt
    end
    if p.jumptime and p.jumptime < 0.25 then
      local c = math.cos(p.jumptime/0.25*(math.pi/2))
      -- player vertical velocity
      p.yv = p.yv - jump*c*dt
    end
  end
end


-- pretty basic
function drawObject(v, r, g, b)
  local lg = love.graphics
  if v.shape == 'rect' then
    local x, y, w, h = v.x, v.y, v.hw, v.hh
    lg.setColor(r, g, b, 255)
    lg.rectangle("fill", x - w, y - h, w * 2, h * 2)
  elseif v.shape == 'circle' then
    local x, y, radius = v.x, v.y, v.r
    lg.setColor(r, g, b, 255)
    lg.circle("fill", x, y, radius, 32)
  elseif v.shape == 'line' then
    local x, y, x2, y2 = v.x, v.y, v.x2, v.y2
    lg.setColor(r, g, b, 255)
    lg.line(x, y, x2, y2)
  end
end

function love.draw()
  local lg = love.graphics
  for i, v in ipairs(statics) do
    drawObject(v, 127, 127, 127)
  end
  for i, v in ipairs(dynamics) do
    drawObject(v, 255, 127, 127)
  end
  for i, v in ipairs(kinematics) do
    drawObject(v, 255, 127, 255)
  end
  lg.setColor(255, 255, 255, 255)
  love.graphics.print("col checks:" .. fizz.cchecks, 0, 0)
  love.graphics.print("quad livecells:" .. quad.livecells, 0, 15)
  love.graphics.print("objects:" .. quad.objects, 0, 30)
  local mem = collectgarbage('count')
  mem = math.ceil(mem)
  love.graphics.print("memory:" .. mem, 0, 45)
end