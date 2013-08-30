local BlockObj = {}
BlockObj.__index = BlockObj

function Block( B )
	local t = setmetatable( {}, BlockObj )
	t.poly = B
	
	t.valid = true
	
	local block = {}
	local centerx,centery = center(t.poly.x1, t.poly.y1, t.poly.x2, t.poly.y2, t.poly.x3, t.poly.y3, t.poly.x4, t.poly.y4)
	block.body = love.physics.newBody(world, X, Y)
	block.shape = love.physics.newPolygonShape( t.poly.x1, t.poly.y1, t.poly.x2, t.poly.y2, t.poly.x3, t.poly.y3, t.poly.x4, t.poly.y4  )
	block.fixture = love.physics.newFixture(block.body, block.shape, 3)
	block.fixture:setRestitution(0.5)
	block.body:setLinearDamping( 0 )
	t.physObj = block
	
	return t
end

function BlockObj:GetPhysicsObject()
	return self.physObj
end

function BlockObj:Update(dt)
	
end

function BlockObj:GetLine()
	return self.poly.line
end

function BlockObj:Remove()
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

function BlockObj:Draw()
	love.graphics.setColor( 220,220,220,255 )
	
	love.graphics.polygon("fill", self.physObj.body:getWorldPoints(self.physObj.shape:getPoints()))
end

function BlockObj:IsValid() return self.valid end

function BlockObj:IsCookie() return false end
function BlockObj:IsBullet() return false end
function BlockObj:IsEnemy() return false end
function BlockObj:IsBlock() return true end
