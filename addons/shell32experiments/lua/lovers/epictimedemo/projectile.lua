
	projectiles = {}

	local runL = {}
	runL[1] = love.graphics.newImage("pics/bow/bow/player/playerL.png")
	runL[1]:setFilter('nearest','nearest')
	runL[2] = love.graphics.newImage("pics/bow/bow/player/playerL2.png")
	runL[2]:setFilter('nearest','nearest')
	runL[3] = love.graphics.newImage("pics/bow/bow/player/playerL3.png")
	runL[3]:setFilter('nearest','nearest')
	runL[4] = love.graphics.newImage("pics/bow/bow/player/playerL4.png")
	runL[4]:setFilter('nearest','nearest')

	local runR = {}
	runR[1] = love.graphics.newImage("pics/bow/bow/player/playerR.png")
	runR[1]:setFilter('nearest','nearest')
	runR[2] = love.graphics.newImage("pics/bow/bow/player/playerR2.png")
	runR[2]:setFilter('nearest','nearest')
	runR[3] = love.graphics.newImage("pics/bow/bow/player/playerR3.png")
	runR[3]:setFilter('nearest','nearest')
	runR[4] = love.graphics.newImage("pics/bow/bow/player/playerR4.png")
	runR[4]:setFilter('nearest','nearest')	

	local relaseAnim = {}
	relaseAnim[1] = love.graphics.newImage("pics/bow/bow/player/playerreleaseL.png")
	relaseAnim[1]:setFilter('nearest','nearest')
	relaseAnim[2] = love.graphics.newImage("pics/bow/bow/player/playerreleaseR.png")
	relaseAnim[2]:setFilter('nearest','nearest')


function projectiles:load()
	bow_pic = {}
	bow_pic[1] = love.graphics.newImage("pics/bow/bow/bow1.png")
	bow_pic[1]:setFilter('nearest','nearest')
	bow_pic[2] = love.graphics.newImage('pics/bow/bow/bow2.png')
	bow_pic[2]:setFilter('nearest','nearest')
	bow_pic[3] = love.graphics.newImage('pics/bow/bow/bow3.png')
	bow_pic[3]:setFilter('nearest','nearest')
	bow_pic[5] = love.graphics.newImage('pics/bow/bow/bow5.png')
	bow_pic[5]:setFilter('nearest','nearest')

	charging = false

	bow_pull = {}
	bow_pull[1] = love.graphics.newImage('pics/bow/bow/bow1pull.png')
	bow_pull[1]:setFilter('nearest','nearest')
	bow_pull[2] = love.graphics.newImage('pics/bow/bow/bow2pull.png')
	bow_pull[2]:setFilter('nearest','nearest')
	bow_pull[3] = love.graphics.newImage('pics/bow/bow/bow3pull.png')
	bow_pull[3]:setFilter('nearest','nearest')
	bow_pull[5] = love.graphics.newImage('pics/bow/bow/bow5pull.png')
	bow_pull[5]:setFilter('nearest','nearest')

	bow = {}
	bow[1] = {pull = bow_pull[1],x = 3,y = -1,bowspeed = 225,damage = 4,width = 8,height = 16,knockback = 2,pic = bow_pic[1]}
	bow[2] = {pull = bow_pull[2],x = 3,y = 0,bowspeed = 200,damage = 2,width = 8,height = 16,knockback = 0.3,pic = bow_pic[2]}
	bow[3] = {pull = bow_pull[3],x = 3,y = -3,bowspeed = 300,damage = 3,width = 8,height = 16,knockback = 0.5,pic = bow_pic[3]}
	bow[4] = {pull = bow_pull[4],x = 1,y = -5,bowspeed = 500,damage = 2,width = 8,height = 16,knockback = 0.5,pic = bow_pic[4]}
	bow[5] = {pull = bow_pull[5],x = 3,y = -1,bowspeed = 550,damage = 9,width = 8,height = 16,knockback = 0.5,pic = bow_pic[5]}

	bownum = nil 
	item_bow:spawn(200,30,bow_pic[1],1)
end

item_bow = {}
function item_bow:spawn(x,y,pic,type)
	table.insert(item_bow,{x=x,y=y,pic=pic,type=type})
end

function projectiles:draw()
	arrow:draw()
	if bownum ~= nil then 
		if player.state == 'right' or player.state == 'idleR'  then 
			if not charging then
				love.graphics.draw(bow[player.bownum].pic,player.x - 1.35 + bow[player.bownum].x,player.y + bow[player.bownum].y - 1,0,1.4,1.4)
			end
			if charging then
				love.graphics.draw(bow[player.bownum].pull,player.x - 1.35 + bow[player.bownum].x,player.y + bow[player.bownum].y - 1,0,1.4,1.4)
			end
		end
		if player.state == "left" or player.state == 'idleL' then
			if charging == false then
				love.graphics.draw(bow[player.bownum].pic,player.x + 21 - bow[player.bownum].x,player.y + bow[player.bownum].y - 2,0,-1.4,1.4)
			end
			if charging == true then
				love.graphics.draw(bow[player.bownum].pull,player.x + 21 - bow[player.bownum].x,player.y + bow[player.bownum].y - 2,0,-1.4,1.4)
			end
		end
	end
end

function projectiles:anim(dt)
	if bownum ~= nil then 
		if player.state == "right" then 
		player.animtime = player.animtime + dt
		if player.animtime > .0 then 
			player.currentPic = runR[1]
		end
		if player.animtime > .2 then 
			player.currentPic = runR[2]
		end 
		if player.animtime > .4 then 
			player.currentPic = runR[3]
		end
		if player.animtime > .6 then 
			player.currentPic = runR[4]
			player.animtime = 0.0
		end
	end 
		if player.state == "left" then 
		player.animtime = player.animtime + dt
		if player.animtime > .0 then 
			player.currentPic = runL[1]
		end
		if player.animtime > .2 then 
			player.currentPic = runL[2]
		end 
		if player.animtime > .4 then 
			player.currentPic = runL[3]
		end
		if player.animtime > .6 then 
			player.currentPic = runL[4]
			player.animtime = 0.0
		end
	end 

	if not player.givepunch and player.state == "idleL" then 
		player.currentPic = runL[1]
	end

	if not player.givepunch and player.state == "idleR" then 
		player.currentPic = runR[1]
	end

	if charging and player.state == 'idleL' or player.state == 'left' and charging then 
		player.currentPic = relaseAnim[1]
	end

	if charging and player.state == 'idleR' or player.state == 'right' and charging then 
		player.currentPic = relaseAnim[2]
	end

	end
end

function projectiles:update(dt)
	projectiles:anim(dt)
end

function projectiles:keypressed(key)
	if bownum ~= nil and key == 'x' and (player.state == 'idleL' or player.state == 'idleR') and not (player.isAttacked and not player.givepunch) then 
		charging = true
	end
end

function projectiles:keyrelased(key)
end

















