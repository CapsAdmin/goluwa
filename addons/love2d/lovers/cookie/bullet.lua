local BulletObj = {}
BulletObj.__index = BulletObj

function Bullet( X, Y, A, S )
	local t = setmetatable( {}, BulletObj )
	t.power = A or 1
	t.size = S or 1
	
	t.valid = true
	
	local ball = {}
	ball.body = love.physics.newBody(world, X, Y, "dynamic")
	ball.shape = love.physics.newCircleShape(t.size)
	ball.fixture = love.physics.newFixture(ball.body, ball.shape, 3)
	ball.fixture:setRestitution(0.5)
	ball.body:setLinearDamping( 0 )
	ball.body:setBullet(true)
	t.physObj = ball
	
	return t
end

function BulletObj:GetPhysicsObject()
	return self.physObj
end

function BulletObj:Update(dt)
	if self.physObj.body:getX() < self.size*-2 or
	   self.physObj.body:getX() > love.graphics.getWidth() + (self.size*2) or
	   self.physObj.body:getY() < self.size*-2 or
	   self.physObj.body:getY() > love.graphics.getHeight() + (self.size*2) then
	   
		self:Remove()
	end
end

function BulletObj:GetPower()
	return self.power
end

function BulletObj:Explode()
	game.explosion:setPosition(self.physObj.body:getX(), self.physObj.body:getY())
	game.explosion:setEmissionRate(50+50*(self.size-1))
	game.explosion:setColors(20, 105, 220, 255, 34, 30, 185, 0)
	game.explosion:setSpeed(15+45*(self.size-1), 15+60*(self.size-1))
	game.explosion:start()
	self:Remove()
end

function BulletObj:Remove()
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

function BulletObj:Draw()
	love.graphics.setColor( 100,100,250,255 )
	
	love.graphics.circle("fill", self.physObj.body:getX(), self.physObj.body:getY(), self.physObj.shape:getRadius())
end

function BulletObj:IsValid() return self.valid end

function BulletObj:IsCookie() return false end
function BulletObj:IsBullet() return true end
function BulletObj:IsEnemy() return false end
function BulletObj:IsBlock() return false end
