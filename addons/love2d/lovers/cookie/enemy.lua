local EnemyObj = {}
EnemyObj.__index = EnemyObj

function Enemy( X, Y, A, B, S )
	local t = setmetatable( {}, EnemyObj )
	t.power = A or 1
	t.health = B or 2
	t.maxHealth = t.health
	t.size = S or 4
	
	t.valid = true
	
	local ball = {}
	ball.body = love.physics.newBody(world, X, Y, "dynamic")
	ball.shape = love.physics.newCircleShape(t.size)
	ball.fixture = love.physics.newFixture(ball.body, ball.shape, 5)
	ball.fixture:setRestitution(0.6)
	ball.body:setLinearDamping( 1.2 )
	t.physObj = ball
	
	return t
end

function EnemyObj:Update(dt)
	local distx,disty
	local cookiePosx,cookiePosy = game.mainCookie:GetPos()
	
	distx = cookiePosx - self.physObj.body:getX()
	disty = cookiePosy - self.physObj.body:getY()
	
	local dist = math.sqrt((distx ^2) + (disty^2))
	
	local normx,normy
	normx = distx / dist
	normy = disty / dist
	
	local force = self.size * 25
	
	self.physObj.body:applyForce( normx * force, normy * force )
end

function EnemyObj:GetSize()
	return self.size
end

function EnemyObj:TakeDamage( dmg )
	local health = self.health
	if health - dmg >= 0 then
		self.health = health - dmg
	else
		self:Explode()
	end
end

function EnemyObj:Explode()
	game.explosion:setPosition(self.physObj.body:getX(), self.physObj.body:getY())
	game.explosion:setEmissionRate(50+50*(self.size-1))
	game.explosion:setColors(20, 245, 20, 255, 80, 220, 45, 0)
	game.explosion:setSpeed(15+45*(self.size-1), 15+60*(self.size-1))
	game.explosion:start()
	self:Remove()
end

function EnemyObj:Remove()
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

function EnemyObj:Draw()
	local perc = (self.health*100)/self.maxHealth
	love.graphics.setColor( (1.95*perc),255-(2*perc),25,255 )
	love.graphics.circle("fill", self.physObj.body:getX(), self.physObj.body:getY(), self.physObj.shape:getRadius())
end

function EnemyObj:getX() return self.physObj.body:getX() end
function EnemyObj:getY() return self.physObj.body:getY() end

function EnemyObj:IsValid() return self.valid end

function EnemyObj:IsCookie() return false end
function EnemyObj:IsBullet() return false end
function EnemyObj:IsEnemy() return true end
function EnemyObj:IsBlock() return false end

