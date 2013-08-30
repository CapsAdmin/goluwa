require( "Vector" )
require( "Line" )
require( "bullet" )
require( "cookie" )
require( "enemy" )
require( "block" )

math.pi = 3.14159265358979323846264
local lg = love.graphics

game = {}

function love.load()
	love.graphics.setPointStyle("smooth")
	
	world = love.physics.newWorld(0, 0, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)
	
	game.money = 500
	game.mainCookie = Cookie(lg.getWidth() / 2, lg.getHeight() / 2)

	game.entities = {}
	table.insert(game.entities, game.mainCookie)
	
	game.blocks = {}
	
	local expl = love.graphics.newImage("expl.png")
	
	local p = lg.newParticleSystem(expl, 1000)
	p:setEmissionRate(100)
	p:setSpeed(75, 100)
	p:setSizes(2, 1)
	p:setColors(20, 105, 220, 255, 34, 30, 185, 0)
	p:setPosition(400, 300)
	p:setEmitterLifetime(0.1)
	p:setParticleLifetime(0.2)
	p:setDirection(0)
	p:setSpread(360)
	p:setTangentialAcceleration(1000)
	p:stop()
	
	game.explosion = p
end

function center(x1,y1,x2,y2,x3,y3,x4,y4)

	local x12 = x2 - x1
	local y12 = y2 - y1
	local x34 = x4 - x3
	local y34 = y4 - y3
	
	return x34-x12,y34-y12
end

function distance(x1,y1,x2,y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

love.mouse.oldPos = {x=0,y=0}
love.mouse.vel = {x=0,y=0}
function love.update(dt)
	world:update(dt)
	game.explosion:update(dt)
	
	local curx,cury = love.mouse.getPosition()
	love.mouse.vel = {x=curx-love.mouse.oldPos.x,y=cury-love.mouse.oldPos.y}
	love.mouse.oldPos = {x=curx,y=cury}
	
	local move = 1800
	if love.keyboard.isDown( "w" )then
		game.mainCookie:Move("w",move)
	end
	
	if love.keyboard.isDown( "a" )then
		game.mainCookie:Move("a",move)
	end
	
	if love.keyboard.isDown( "s" )then
		game.mainCookie:Move("s",move)
	end
	
	if love.keyboard.isDown( "d" )then
		game.mainCookie:Move("d",move)
	end
	
	for k, v in pairs(game.entities)do
		v:Update(dt)
	end
	
end

function love.keypressed(key)
	if key == "menu" then
		game.money = 500000
	end
	
	if key == "r" then
		for k, v in pairs(game.entities)do
			v:Remove()
		end
		game = {}
		world:destroy()
		love.load()
	end
	
	if key == "e" then
		local curx,cury = love.mouse.getPosition()
		CreateEnemy(curx,cury,_,_,4+math.random()*3)
	end
	
	if key == "g" then
		local curx,cury = love.mouse.getPosition()
		table.insert(game.entities, Cookie(curx,cury,_,_,_,_,true))
	end
	
	if key == "q" then
		game.mainCookie.btype = 2
	end
end

function CreateEnemy(x,y,a,b,s)
	table.insert(game.entities,Enemy(x,y,a,b,s))
end

local drawing = false
local tempDrawx,tempDrawy = 0,0

function love.mousepressed(derpx, derpy, button)
	if button == "l" then
		if shopActive then
			
		else
			if game.mainCookie then
				game.mainCookie:Shoot()
			else
				
			end
		end
	end
	
	if button == "m" then
		if not drawing then
			if game.money >= 10 then
				tempDrawx,tempDrawy = derpx, derpy
				drawing = true
			end
		else
			
			local dist = distance(derpx,derpy,tempDrawx,tempDrawy)
			local cost = math.ceil(dist,0)
			
			--local ang = math.atan((derpy-tempDrawy)/(derpx-tempDrawx))
			local ang = math.atan((tempDrawy-derpy)/(tempDrawx-derpx))
			if (tempDrawx-derpx) >= 0 then
				ang = ang + math.pi
			end
			--local ang = math.asin((derpx-tempDrawx)/dist)
			if cost >= game.money then
				cost = game.money
				derpx = cost * math.cos(ang) + tempDrawx
				derpy = cost * math.sin(ang) + tempDrawy
			end
			
			local tempLine = Line( Vector(derpx,derpy), Vector(tempDrawx,tempDrawy))
			local nope
			for k,v in pairs(game.entities)do
				if v:IsBlock() then
					if v:GetLine():Intersects(tempLine) then
						nope = true
					end
				end
			end
			if dist > 10 and (not nope) then
				
				local transx = 3 * math.cos(ang + math.pi/2)
				local transy = 3 * math.sin(ang + math.pi/2)
				
				local block = {}
				block.x1 = tempDrawx + transx
				block.y1 = tempDrawy + transy
				block.x2 = tempDrawx - transx
				block.y2 = tempDrawy - transy
				block.x3 = derpx - transx
				block.y3 = derpy - transy
				block.x4 = derpx + transx
				block.y4 = derpy + transy
				
				block.line = tempLine
				game.money = game.money - cost
				
				local blin = Block(block)
				table.insert(game.entities,blin)
				table.insert(game.blocks,blin)
				
				drawing = false
			end
		end
	end
	
	if button == "r" then
		if drawing then
			drawing = false
		else
			game.mainCookie.power = game.mainCookie.power + 1
		end
	end
end

dbug = ""

function love.draw()	
	love.graphics.setColor( 80, 80, 80, 255 )
	love.graphics.circle("line", lg.getWidth() / 2, lg.getHeight() / 2, 350)
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	love.graphics.print("Points: "..tostring(game.money), 10, 24)
	love.graphics.print("#ents: "..tostring(#game.entities), 10, 38)
	love.graphics.print("Health: "..tostring(game.mainCookie.health), 10, 52)
	love.graphics.print("Debug: "..tostring(dbug), 10, 66)
	
	if drawing then
		local curx, cury = love.mouse.getPosition()
		local ang = math.atan((cury-tempDrawy)/(curx-tempDrawx))
		if (tempDrawx-curx) >= 0 then
			ang = ang + math.pi
		end
		local cost = math.ceil(distance(curx,cury,tempDrawx,tempDrawy),0)
		if cost >= game.money then
			cost = game.money
			curx = cost * math.cos(ang) + tempDrawx
			cury = cost * math.sin(ang) + tempDrawy
		end
		
		local tempLine = Line( Vector(curx,cury), Vector(tempDrawx,tempDrawy))
			local nope
			for k,v in pairs(game.entities)do
				if v:IsBlock() then
					if v:GetLine():Intersects(tempLine) then
						nope = true
					end
				end
			end
		
		if distance(curx,cury,tempDrawx,tempDrawy) > 10 and (not nope) then
			love.graphics.setColor( 255, 255, 255, 205 )
			love.graphics.print(cost.."$",curx,cury-17)
			love.graphics.setColor( 85, 255, 85, 125 )
		else
			love.graphics.setColor( 255, 85, 85, 125 )
		end
		
		local transx = 3 * math.cos(ang + math.pi/2)
		local transy = 3 * math.sin(ang + math.pi/2)
		love.graphics.polygon("fill",tempDrawx+transx,tempDrawy+transy,tempDrawx-transx,tempDrawy-transy,curx-transx,cury-transy,curx+transx,cury+transy)
		
	end
	
	love.graphics.setColor( 255, 255, 255, 205 )
	
	for k, v in pairs(game.entities)do
		v:Draw()
	end
	
	love.graphics.draw(game.explosion, 0, 0)
end

function getEntityFromFixture( fx )
	for k, v in pairs(game.entities)do
		if v.physObj.fixture == fx then
			return v
		end
	end
	return false
end

function beginContact(a, b, coll)
    x,y = coll:getNormal()
	
	local aent = getEntityFromFixture( a )
	local bent = getEntityFromFixture( b )
		
	if aent and bent then
		if (aent:IsBullet() and bent:IsEnemy())then
			aent:Explode()
			bent:TakeDamage(aent:GetPower()*math.random())
		elseif (bent:IsBullet() and aent:IsEnemy()) then
			bent:Explode()
			aent:TakeDamage(bent:GetPower()*math.random())
		end
		
		if (aent:IsEnemy() and bent:IsCookie())then
			if not bent:TakeDamage(aent:GetSize()) then
				aent:Explode()
			end
		elseif (aent:IsCookie() and bent:IsEnemy()) then
			if not aent:TakeDamage(bent:GetSize()) then
				bent:Explode()
			end
		end
	end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll)
end