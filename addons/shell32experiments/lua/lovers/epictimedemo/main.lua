--http://en.irc2go.com/webchat/?net=OFTC&nick=Murii&room=love
require 'player'
require 'camera'
require 'world'
require 'cloud'
require 'env'
require 'animal'
require 'sun'
require 'projectile'
require 'arrow'
require 'particle'
require 'states'
require 'sound'
require 'effect'
require 'achivements'
require 'beast'
require 'text'
require 'villigers'
require 'shopkeepers'
require 'drops'

screenW = love.graphics.getWidth()
screenH = love.graphics.getHeight()

function love.load()
	sound:load()
	world:load()
	states:load()
	player:load()
	anim:load()
	enemy:load()
	vil:load()
	drops:load()
	keeper:load()
	cloud:load()
	env:load()
	sun:load()
	projectiles:load()
end

function love.update(dt)
	states:update(dt)
	player:update(dt)
	world:update(dt)
	env:update(dt)
	anim:update(dt)
	drops:update(dt)
	effect:update(dt)
	cloud:update(dt)
	ach:update(dt)
	vil:update(dt)
	keeper:update(dt)
	enemy:update(dt) 
	sun:update(dt)
	camera:update(dt)
	projectiles:update(dt)
	effects:update(dt)
	text:update(dt)
	arrow:update(dt)
	if gamestate == 'intro' or gamestate == 'play' or gamestate == 'loading' then 
	    love.mouse.setVisible(false)
    else 
    	love.mouse.setVisible(true)
    end

    --lvl transition 
    if player.x + player.w > mapwidth[mapnum] then
    	gamestate = 'loading'
    	world:lvlTransition()
    end


end

function love.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(tostring(love.timer.getFPS()),0,0)
	if gamestate == 'play' then 
	camera:scale(3.2,3.2)
	camera:draw()
	arrow:draw()
	sun:draw()
	env:draw()
	cloud:draw()
	world:draw()
	text:draw()
	anim:draw()
	vil:draw()
	keeper:draw()
	player:draw()
	drops:draw()
	projectiles:draw()
	effects:draw()
	enemy:draw()
	ach:draw()
	end
	if gamestate == 'intro' or gamestate == 'menu' or gamestate == 'loading' or gamestate == 'options' then 
	states:draw()
	effect:draw() 
	states:button()	
	end
end

function love.keypressed(key)
	if key == "escape" and gamestate == 'play' or gamestate == 'tutorial'  or gamestate == 'options' then
      --gamestate = 'menu'
      love.event.push("quit")
      music2:stop()
   end
   if (key == " " or key == "return") and gamestate == 'intro' or not gamestate == 'play' or not gamestate == 'loading' then
      gamestate = 'menu' 
      intro:stop() 
   end
   if gamestate == 'play' then 
   	  player:keypressed(key)
      projectiles:keypressed(key)
	end
end

function love.keyrelased(key)
	if gamestate == 'play' then
	player:keyrelased(key)
	projectiles:keyrelased(key)
	end
end

function love.mousepressed( x, y, bu )
	states:click(x,y,bu)
end