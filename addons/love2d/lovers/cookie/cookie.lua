local CookieObj = {}
CookieObj.__index = CookieObj

function Cookie( X, Y, A, B, C, M, F )
	local t = setmetatable( {}, CookieObj )
	t.pos = {x=X,y=Y}
	t.vel = {x=0,y=0}
	t.rotation = A or 0
	t.power = B or 1
	t.health = C or 100
	t.btype = M or 1
	t.bot = F or false
	
	t.valid = true
	
	t.shootTime = 0.5 + math.random()*0.6
	t.targetting = false
	
	t.targetted = {}
	
	local size = 15
	if t.bot then
		size = 8
	end
	
	local ball = {}
	ball.body = love.physics.newBody(world, X, Y, "dynamic")
	ball.shape = love.physics.newCircleShape(size)
	if t.bot then
		ball.fixture = love.physics.newFixture(ball.body, ball.shape, 15)
		ball.body:setLinearDamping( 12 )
	else
		ball.fixture = love.physics.newFixture(ball.body, ball.shape, 2)
		ball.body:setLinearDamping( 5 )
	end
	
	
	t.physObj = ball
	
	return t
end

function CookieObj:FindNearestEnemy()
	local nearest,neardist
	if self.target then
		if self.target:IsValid() then
			local tempLine = Line(Vector(self.pos.x, self.pos.y), Vector(self.target:getX(), self.target:getY()))
			for k, v in pairs(game.blocks)do
				if tempLine:Intersects(v:GetLine()) then
					nope = true
				end
			end
		end
	end
	
	for k, v in pairs(self.targetted)do
		local tg = game.entities[k]
		if not tg then self.targetted[k] = nil else
			if (not tg.getX) or (not tg.getY)then
				self.targetted[k] = nil
			else
				if (not tg:getX() == v.x) or (not tg:getY() == v.y)then
					self.targetted[k] = nil
				end
			end
		end
	end
	
	for k, v in pairs(game.entities)do
		if v:IsEnemy() then
			if not self.targetted[k] then
				local tempLine = Line(Vector(self.pos.x, self.pos.y), Vector(v:getX(), v:getY()))
				local nope = false
				for t, b in pairs(game.blocks)do
					if tempLine:Intersects(b:GetLine()) then
						nope = true
						self.targetted[k] = {x=v:getX(), y=v:getY()}
					end
				end
				if not nope then
					if not nearest then
						nearest = v
						neardist = distance(self.pos.x, self.pos.y, v:getX(), v:getY())
					else
						local dist = distance(self.pos.x, self.pos.y, v:getX(), v:getY())
						if dist < neardist then
							nearest = v
							neardist = dist
						end
					end
				end
			end
		end
	end
	if nearest then
		self.targetting = true
		self.target = nearest
		return nearest:getX(),nearest:getY()
	end
	self.targetting = false
	self.target = nil
	return love.mouse.getPosition()
end

function CookieObj:TakeDamage( dmg )
	local health = self.health
	if health - dmg > 0 then
		self.health = health - dmg
		return false
	else
		self.health = 0
		self:Explode()
		return true
	end
end

function CookieObj:Explode()
	game.explosion:setPosition(self.pos.x, self.pos.y)
	game.explosion:setEmissionRate(520)
	game.explosion:setColors(170, 145, 120, 255, 250, 120, 45, 0)
	game.explosion:setSpeed(128+math.random()*40, 240+math.random()*50)
	game.explosion:start()
	--self:Remove()
end

function CookieObj:Draw()
	love.graphics.setColor( 255,255,255,255 )
	
	local curx,cury
	if self.bot then
		if self.target then
			if self.target:IsValid() then
				curx,cury = self.target:getX(),self.target:getY()
			else
				curx,cury = self:FindNearestEnemy()
			end
		else
			curx,cury = self:FindNearestEnemy()
		end
	else
		curx,cury = love.mouse.getPosition()
	end
	local ang = math.atan((self.pos.y-cury)/(self.pos.x-curx))
	if (self.pos.x-curx) >= 0 then
		ang = ang + math.pi
	end
	
	self.rotation = ang
	
	local size = 18
	if self.bot then
		size = 12
	end
	
	curx = size * math.cos(ang) + self.pos.x
	cury = size * math.sin(ang) + self.pos.y
	
	local transx = math.cos(ang + math.pi/2) * self.power
	local transy = math.sin(ang + math.pi/2) * self.power
	
	local b = {}
	b.x1 = self.pos.x + transx
	b.y1 = self.pos.y + transy
	b.x2 = self.pos.x - transx
	b.y2 = self.pos.y - transy
	b.x3 = curx - transx 
	b.y3 = cury - transy
	b.x4 = curx + transx
	b.y4 = cury + transy
	
	love.graphics.polygon("line",b.x1,b.y1,b.x2,b.y2,b.x3,b.y3,b.x4,b.y4)
	
	size = 15
	if self.bot then
		size = 8
	end
	
	love.graphics.circle("line", self.pos.x, self.pos.y, size)
	love.graphics.setColor( 0,0,0,255 )
	love.graphics.circle("fill", self.pos.x, self.pos.y, size-1)
end

function CookieObj:Move(key, ammount)
	local movex,movey
	if key == "w" then
		movex = 0
		movey = ammount*-1
	elseif key == "a" then
		movex = ammount*-1
		movey = 0
	elseif key == "s" then
		movex = 0
		movey = ammount
	elseif key == "d" then
		movex = ammount
		movey = 0
	end

	self.physObj.body:applyForce( movex, movey )
end

function CookieObj:Shoot()
	local bulx,buly
	local ang = self.rotation
	
	
	
	if self.btype == 1 then
		bulx = (17 + self.power/2) * math.cos(ang) + self.pos.x
		buly = (17 + self.power/2) * math.sin(ang) + self.pos.y
		local bullet = Bullet(bulx,buly,self.power,self.power+1)
		table.insert(game.entities, bullet)
		local force = 25 * (self.power ^ 1.8)
		bullet:GetPhysicsObject().body:applyLinearImpulse( math.cos(ang)*force, math.sin(ang)*force )
	elseif self.btype == 2 then
		for i = 0, 2 do
			local newang = ang + ((math.pi/22)*(i-1))
			
			local pow = (16 + self.power/2)
			if i == 1 then
				pow = (17 + self.power)
			end
			bulx = pow * math.cos(newang) + self.pos.x
			buly = pow * math.sin(newang) + self.pos.y
			local bullet = Bullet(bulx,buly,self.power,self.power+1)
			table.insert(game.entities, bullet)
			local force = 20 * (self.power ^ 1.8)
			bullet:GetPhysicsObject().body:applyLinearImpulse( math.cos(newang)*force, math.sin(newang)*force )
		end
	elseif self.btype == 3 then
	end
	
	self:FindNearestEnemy()
end

function CookieObj:Remove()
	for k, v in pairs(game.entities)do
		if v == self then
			table.remove(game.entities,k)
		end
	end
	self.physObj.fixture:destroy()
	self.physObj.body:destroy()
	self.valid = false
	self = nil
end

function CookieObj:Update(dt)
	
	if (not self.pos.x == self.physObj.body:getX()) or (not self.pos.y == self.physObj.body:getY()) then
		self.targetted = {}
	end
	self.pos.x = self.physObj.body:getX()
	self.pos.y = self.physObj.body:getY()
	
	if self.bot and self.targetting then
		if self.shootTime - dt > 0 then
			self.shootTime = self.shootTime - dt
		else
			self:Shoot()
			self.shootTime = 0.5 + math.random()*0.6
		end
	end
end

function CookieObj:GetPos()
	return self.pos.x,self.pos.y
end

function CookieObj:IsValid() return self.valid end

function CookieObj:IsCookie() return true end
function CookieObj:IsBullet() return false end
function CookieObj:IsEnemy() return false end
function CookieObj:IsBlock() return false end
