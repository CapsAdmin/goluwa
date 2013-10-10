math.randomseed(os.time())
math.random()
math.random()
math.random()

effects = {}

local p_spread = 360
local p_velocity_min = 90
local p_velocity_max = 120
local p_gravity = 375
local p_lifetime = 0
local p_limit = 25

function place_effect(x,y,r_bias,min,max,image)
	p_lifetime = 1
	--marj of possibility
	local p_count = math.random(min,max)
	local effect_buffer = {image}
	for i = 1, p_count do
		local vel = math.random(p_velocity_min, p_velocity_max)
		local radius = math.rad(math.random(-p_spread,p_spread)) + r_bias
		local vx = math.cos(radius) * vel
		local vy = math.sin(radius) * vel 
		table.insert(effect_buffer, {x,y,vx,vy,0})
	end
	table.insert(effects, effect_buffer)
end

function effects:update(dt)
	for i,v in ipairs(effects) do
		--remove the surplus particules
	if #effects >= p_limit then
			table.remove(effects, i)
		end
	end

	for i,v in ipairs(effects) do
		for ii,vv in ipairs(v) do

			--v = table num (effects)
			--i = un numar ciudat de la 1 pana la 12
			--ii = un alt numar ciudat de la 1 la 3
			--vv = numele table(v) si Image

			-- i = {ii,vv}

			--vv[5] defapt acceseaza numarul 0 din table.insert(effect_buffer, {x,y,vx,vy,0})
			--vv[4] defapt acceseaza vy 
			--si tot asa


			if ii > 1 then
				vv[5] = vv[5] + dt
				
				if math.abs(vv[3]) >= 1 then
					vv[1] = vv[1] + vv[3] * dt
					vv[4] = vv[4] + p_gravity * dt
					vv[2] = vv[2] + vv[4] * dt	
					end
				if vv[5] >= p_lifetime then
					table.remove(v,ii)
				end
			end
		end
	end
end

function effects:draw()
	for i,v in ipairs(effects) do
		for ii,vv in ipairs(v) do
			love.graphics.setBackgroundColor(bg_r,bg_g,bg_b,250)
			love.graphics.setColor(sky_r,sky_g,sky_b,250)
			love.graphics.draw(v[1],vv[1],vv[2], 0, 0.2, 0.2)
		end
	end
end
