
text = {}

local fontS = love.graphics.newFont("fonts/1a.ttf", 12);
local a1 = love.graphics.newFont("fonts/3a.ttf", 18);
local scaleText = 0;

function text:add(x,y,message,type,dir)
	table.insert(text,{x=x,y=y,message=message,alphaText=255,type=type,dir=dir,speed=30,timer=0,xvel=0,yvel=-40,rot=0,scale=1})
end

function text:draw()
	for i,v in ipairs(text) do
		if v.type == 'critical' then 
		love.graphics.setColor(180,20,40,v.alphaText)	
		love.graphics.setFont(a1)
		love.graphics.print(v.message,v.x,v.y,v.rot,v.scale + scaleText,v.scale + scaleText)
		love.graphics.setColor(255,255,255,255)
	elseif v.type == 'combat' then  
		love.graphics.setColor(200,20,40)	
		love.graphics.setFont(a1)
		love.graphics.print(v.message,v.x,v.y,v.rot,v.scale,v.scale)
		love.graphics.setColor(255,255,255)
	elseif v.type == 'power' then  
		love.graphics.setColor(235,245,250)	
		love.graphics.setFont(fontS)
		love.graphics.print(v.message,v.x,v.y,v.rot,v.scale,v.scale)
		love.graphics.setColor(255,255,255)
		end
	end
end

function text:update(dt)
	for i,v in ipairs(text) do 
		if v.type == 'combat' then 
			v.timer = v.timer + dt
			v.xvel = v.xvel + v.speed*dt
			v.yvel = v.yvel + v.speed*dt
			if v.dir == 'left' then 
				v.x = v.x - v.xvel*dt
				v.y = v.y + v.yvel*dt
			end
			if v.dir == 'right' then 
				v.x = v.x + v.xvel*dt
				v.y = v.y + v.yvel*dt
			end
			if v.timer > 2 then 
				table.remove(text,i)
				v.timer = 0
			end
		end
		--Critical damage message
		if v.type == 'critical' then
			scaleText = scaleText + .2*dt 
			v.timer = v.timer + dt
			if v.dir == 'left' then 
				v.x = v.x - 45*dt
				v.y = v.y + 10*dt
			end
			if v.dir == 'right' then 
				v.x = v.x + 45*dt
				v.y = v.y + 10*dt
			end

			if v.timer > 1.3 then 
				v.alphaText = v.alphaText - 140 * dt 
				if v.alphaText <= 0 then 
					v.alphaText = 0
				end
			end

			if v.timer > 1.8 then
				scaleText = 0
			end

			if v.timer > 2.5 then 
				table.remove(text,i)
				v.alphaText = 255
			end
		end
		--Power text
		if v.type == 'power' then
			v.timer = v.timer + dt
			if v.timer > 1.5 then 
				v.y = v.y - 140 * dt
			end
			if v.timer > 2.0 then 
				table.remove(text,i)
			end
		end
	end
end





