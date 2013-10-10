
--way better than TSound :D

	sound = {}
	
function sound:load()
	 music1 = love.audio.newSource("sounds/songs/CleanSoul.ogg", "stream")
	 music2 = love.audio.newSource("sounds/songs/Eclipse.ogg", "stream")
	 music3 = love.audio.newSource("sounds/songs/first.ogg", "stream")
	 music4 = love.audio.newSource("sounds/songs/menu.ogg", "stream")
	 music5 = love.audio.newSource("sounds/songs/town.ogg", "stream")
	 music6 = love.audio.newSource("sounds/songs/music.ogg", "stream")
	 music7 = love.audio.newSource("sounds/songs/alightintro.ogg", "stream")
	 music8 = love.audio.newSource("sounds/songs/superwin.ogg", "stream")
	 intro = love.audio.newSource("sounds/intro.ogg", "stream")

	 step = love.audio.newSource("sounds/step.ogg", "static")
	 jump = love.audio.newSource("sounds/jump.ogg", "static")
	 startup = love.audio.newSource("sounds/startup.ogg", "static")
	 shoot = love.audio.newSource("sounds/shoot.wav", "static")
	 itempickup = love.audio.newSource("sounds/itempickup.ogg", "static")
	 hurt = love.audio.newSource("sounds/hurt.ogg", "static")
	 ground_hit = love.audio.newSource("sounds/ground_hit.ogg", "static")
	 hit_tile = love.audio.newSource("sounds/hit_tile.ogg", "static")
	 hit1 = love.audio.newSource("sounds/hit.ogg", "static")
	 hit2 = love.audio.newSource("sounds/hit2.wav", "static")
	 hit3 = love.audio.newSource("sounds/hit3.wav", "static")
	 hit4 = love.audio.newSource("sounds/hit4.wav", "static")
	 hit5 = love.audio.newSource("sounds/hit5.wav", "static")
	 explode = love.audio.newSource("sounds/explode.ogg", "static")
	 electric = love.audio.newSource("sounds/electric.ogg", "static")
	 click = love.audio.newSource("sounds/click.ogg", "static")
	 chesthit = love.audio.newSource("sounds/chesthit.ogg", "static")
	 chest = love.audio.newSource("sounds/chest.ogg", "static")
	 bow = love.audio.newSource("sounds/bow.ogg", "static")
	 achivement = love.audio.newSource("sounds/achivement.wav", "static")
	 coin = love.audio.newSource("sounds/coin.wav", "static")
	 powers = love.audio.newSource("sounds/powers.wav", "static")
end

function sound:play(name)
	if name == "music8" then
		music8:play()
		music8:setLooping(true)
	end
	if name == "music7" then
		music7:play()
		music7:setLooping(true)
	end
	if name == "music6" then
		music6:play()
		music6:setLooping(true)
	end
	if name == "music5" then
		music5:play()
		music5:setLooping(true)
	end
	if name == "music2" then
		music2:play()
		music2:setLooping(true)
	end
	if name == "music3" then
		music3:play()
		music3:setLooping(true)
	end
	if name == "music4" then
		music4:play()
		music4:setLooping(true)
	end
	
	if name == "music1" then
		music1:play()
		music1:setLooping(true)
	elseif name == "coin" then
		if  coin:isStopped() then
			coin:play()
		else
			coin:rewind()
		end
	elseif name == "hit5" then
		if hit5:isStopped() then
			hit5:play()
		end
	elseif name == "powers" then
		if powers:isStopped() then
			powers:play()
		else 
			powers:rewind()
		end
	elseif name == "achivement" then
		if achivement:isStopped() then
			achivement:play()
		end
	elseif name == "jump" then
		if jump:isStopped() then
			jump:play()
			jump:setVolume(.3)
		else
			jump:rewind()
		end
	elseif name == "bow" then
		if  bow:isStopped() then
			bow:play()
		else
			bow:rewind()
		end
	elseif name == "chest" then
		if chest:isStopped() then
			chest:play()
		else
			chest:rewind()
		end
	elseif name == "chesthit" then
		if chesthit:isStopped() then
			chesthit:play()
		else
			chesthit:rewind()
		end
	elseif name == "click" then
		if click:isStopped() then
			click:play()
		else
			click:rewind()
		end
	elseif name == "electric" then
		if electric:isStopped() then
			electric:play()
		else
			electric:rewind()
		end
	elseif name == "explode" then
		if explode:isStopped() then
			explode:play()
		else
			explode:rewind()
		end
	elseif name == "ground_hit" then
		if ground_hit:isStopped() then
			ground_hit:play()
		else
			ground_hit:rewind()
		end
	elseif name == "hit1" then
		if hit1:isStopped() then
			hit1:play()
		else
			hit1:rewind()
		end
	elseif name == "hit2" then
		if hit2:isStopped() then
			hit2:play()
		else
			hit2:rewind()
		end
	elseif name == "hit3" then
		if hit3:isStopped() then
			hit3:play()
		else
			hit3:rewind()
		end
	elseif name == "hit4" then
		if hit4:isStopped() then
			hit4:play()
		else
			hit4:rewind()
		end
	elseif name == "hit_tile" then
		if hit_tile:isStopped() then
			hit_tile:play()
		else
			hit_tile:rewind()
		end
	elseif name == "hurt" then
		if hurt:isStopped() then
			hurt:play()
		else
			hurt:rewind()
		end
	elseif name == "itempickup" then
		if itempickup:isStopped() then
			itempickup:play()
		else
			itempickup:rewind()
		end
	elseif name == "shoot" then
		if shoot:isStopped() then
			shoot:play()
		else
			shoot:rewind()
		end
	elseif name == "startup" then
		if startup:isStopped() then
			startup:play()
		else
			startup:rewind()
		end
	elseif name == "step" then
		if step:isStopped() then
			step:play()
		else
			step:rewind()
		end
	elseif name == "intro" then
		if intro:isStopped() then
			intro:play()
		else
			intro:rewind()
		end
	end
end

function sound:stop(name)
	if name == "music6" then
		music6:stop()
		music6:setLooping(false)
	end
	if name == "music5" then
		music5:stop()
		music5:setLooping(false)
	end
	if name == "music2" then
		music2:stop()
		music2:setLooping(false)
	end
	if name == "music3" then
		music3:stop()
		music3:setLooping(false)
	end
	if name == "music4" then
		music4:stop()
		music4:setLooping(false)
	end
	if name == "music1" then
		music1:stop()
		music1:setLooping(false)
	end
end