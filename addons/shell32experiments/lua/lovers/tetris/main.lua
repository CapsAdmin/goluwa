--- Tetris by Andrey Penechko
-----
--- Boost Software License - Version 1.0 - August 17th, 2003
-----

require 'data'

io.stdout:setvbuf("no")

----------------------------------------------------------------------------------------------------
------ Callbacks
----------------------------------------------------------------------------------------------------

function love.load()
	init_audio()
	start_game()
end

function love.update(dt)
	if game.state ~= 'game_over' and game.state ~= 'paused' then
		game.timer = game.timer + dt
		if game.timer >= game.frame_delay then
			do_frame()
			game.timer = game.timer - game.frame_delay
		end
	end
end

g = love.graphics

------------------------------------------------------------
function love.draw()
	g.setColor(255, 255, 255)
	g.print('FPS:'..love.timer.getFPS(), g.getWidth() - 110, 0)
	g.print('Score:'..game.score, g.getWidth() - 110, 12)

	g.print('Move: left, right, down', g.getWidth() - 300, 0)
	g.print('Rotate: up', g.getWidth() - 300, 12)
	g.print('Drop: space', g.getWidth() - 300, 24)
	g.print('Pause: P', g.getWidth() - 300, 36)
	g.print('Restart: R (after "Game over")', g.getWidth() - 300, 48)

	for y=1, #figure.next do
		for x=1, #figure.next[1] do
			g.print(string.sub(figure.next[y], x, x),
					g.getWidth() - 90 + (x-1)*12, 36 + (y-1)*12)
		end
	end

	draw_field()

	if not (game.state == 'paused') then
		if rules.shadow then draw_shadow() end
		draw_figure(figure.x, figure.y, draw_block)
	end

	g.setColor(255, 255, 255)
	local str = game.state_names[game.state]
	if str ~= nil then
		g.printf(str, field.offset.x,
				field.offset.y + (block.h + block.offset)*field.h + 4, 
				((block.w + block.offset)*field.w), 'center')
	end
end

----------------------------------------------------------------------------------------------------
------ Draw
----------------------------------------------------------------------------------------------------

------------------------------------------------------------
function draw_shadow()
	local shadow_y = figure.y

	while true do
		if not collides_with_blocks(figure.current, field, figure.x, shadow_y + 1) then
			shadow_y = shadow_y + 1
		else
			break
		end
	end

	draw_figure(figure.x, shadow_y, function (x, y, color)
		draw_block(x, y, {0,0,0}, {255, 255, 255, 64})
	end)
end

------------------------------------------------------------
function draw_figure(_x, _y, drawer_func)
	for y = 1, #figure.current do
		for x = 1, #figure.current[1] do
			if string.sub(figure.current[y], x, x) == '#' then
				drawer_func(_x + x - 1, _y + y - 1, colors[figure.current.index])
			end
		end
	end
end

------------------------------------------------------------
function draw_field()
	g.rectangle("line", field.offset.x - 2, field.offset.y - 2,
						(block.w + block.offset)*field.w + 4,
						(block.h + block.offset)*field.h + 4)

	for y = 1, field.h do
		for x = 1, field.w do
			if field[y][x] ~= 0 then
				draw_block(x, y, colors[field[y][x]])
			end
		end
	end
end

------------------------------------------------------------
-- x, y [1 .. n]
function draw_block(x, y, color, hole_color)
	if y <1 then return end
	hole_color = hole_color or {0,0,0}

	g.setColor(color)
	local lx = field.offset.x + (x-1)*(block.w + block.offset)
	local ly = field.offset.y + (y-1)*(block.h + block.offset)
	g.rectangle("fill", lx, ly, block.w, block.h)

	g.setColor(hole_color)
	-- makes nice hole in the figure with any figure size
	g.rectangle("fill", lx + math.ceil(block.w/4), ly + math.ceil(block.h/4),
						math.floor(block.w/2 - 0.25), math.floor(block.h/2 - 0.25))
end

----------------------------------------------------------------------------------------------------
------ Logic
----------------------------------------------------------------------------------------------------

function start_game()
	field.init()
	game.init()
	game.state = 'in_air'
end

function do_frame()
	local gravity = game.gravities[game.gravity]

	if game.hold_dir ~= 0 then
		game.hold_timer = game.hold_timer + 1
		if game.hold_timer >= rules.autorepeat_delay then
			game.autorepeat_timer = game.autorepeat_timer + 1

			if game.autorepeat_timer >= rules.autorepeat_interval then
				move(game.hold_dir)
				game.autorepeat_timer = 1
			end
		end
	end

	if game.state == 'in_air' and game.frame >= gravity.delay then
		for i=1, gravity.distance do
			fall()
		end
		if is_on_floor() then
			game.state = 'on_floor'
		end
	elseif game.state == 'on_floor' and
			(game.frame >= rules.lock_delay) then
		lock() -- can cause game over
	elseif game.state == 'clearing' and game.frame >= rules.clear_delay then
		remove_lines()
		game.state = 'spawning'
	elseif game.state == 'spawning' then
		game.state = 'in_air'
		spawn_fig()
	end

	game.frame = game.frame + 1
end

function love.keypressed(key, isrepeat)
	if game.state == 'game_over' then 
		if key == 'r' then
			start_game()
		end
		return
	end

	if key == 'p' then
		if game.state == 'paused' then
			game.state = game.last_state
		else
			game.last_state = game.state
			game.state = 'paused'
		end
	elseif game.state ~= 'paused' then
		if key == 'down' then
			game.gravity = 2
		elseif key == 'left' then
			move(-1)
			game.hold_dir = -1
		elseif key == 'right' then
			move(1)
			game.hold_dir = 1
		elseif key == 'up' then
			local new_fig = rotate_fig_left()

			if not collides_with_blocks(new_fig, field, figure.x, figure.y) then
				new_fig.index = figure.current.index
				figure.current = new_fig

				if rules.spin_reset then
					game.frame = 1
				end

				if is_on_floor() then
					game.state = 'on_floor'
				else
					game.state = 'in_air'
				end
			end
		elseif key == ' ' then
			hard_drop()
		end 
	end
end

function love.keyreleased(key, isrepeat)
	if key == 'down' then
		game.gravity = 1
	elseif key == 'left' then
		if love.keyboard.isDown('right') then
			game.hold_dir = 1
		else
			game.hold_dir = 0
			game.hold_timer = 1
			game.autorepeat_timer = 1
		end
	elseif key == 'right' then
		if love.keyboard.isDown('left') then
			game.hold_dir = -1
		else
			game.hold_dir = 0
			game.hold_timer = 1
			game.autorepeat_timer = 1
		end
	end
end

-- 
function lock()
	merge_figure(figure, field)

	if collides_with_spawn_zone(figure.current, field, figure.x, figure.y) then
		game.state = 'game_over' -- [partial] lock out
		on_game_over()
		return
	end

	game.lines_to_remove = full_lines()

	if #game.lines_to_remove > 0 then
		game.state = 'clearing'
	else
		gameaudio.drop:play()
		game.state = 'spawning'
	end
end

function on_game_over()
	gameaudio.gameover:play()
end

function remove_lines()
	local lines_removed = #game.lines_to_remove
	for i = 1, #game.lines_to_remove  do
		table.remove(field, game.lines_to_remove[i])
	end
	for i = 1, lines_removed do
		table.insert(field, 1, {}) 
		for j=1, #field[2] do
			field[1][j] = 0
		end
	end

	on_lines_removed(lines_removed)
end

function on_lines_removed(num)
	if num == 0 then return end

	game.score = game.score + (2^(num-1)*100)
	gameaudio.clear1:play()
end

------------------------------------------------------------
function hard_drop()
	while true do
		if fall() then break end
	end

	if not rules.hard_drop_lock_delay then lock() end
end

function fall()-- todo check if floor is reached
	if not collides_with_blocks(figure.current, field, figure.x, figure.y + 1) then
		figure.y = figure.y + 1
		game.frame = 1 --reset lock delay
		return false
	else
		return true
	end
end

function move(dx)
	if not collides_with_blocks(figure.current, field, figure.x + dx, figure.y) then
		figure.x = figure.x + dx
	end

	if is_on_floor() then
		game.state = 'on_floor'
	else
		game.state = 'in_air'
	end

	if rules.move_reset then
		game.frame = 1
	end
end

-- returns rotated figure if it can be rotated
function rotate_fig_left()
	local new_fig = {}

	for y = 1, #figure.current[1] do
		new_fig[y] = ''
		for x = #figure.current, 1, -1 do
			if string.sub(figure.current[x], y, y) == '#' then
				new_fig[y] = new_fig[y]..'#'
			else
				new_fig[y] = new_fig[y]..' '
			end
		end
	end

	return new_fig
end

------------------------------------------------------------


function spawn_fig()
	figure.current = figure.next
	figure.next = game.random_fig()
	figure.x = math.ceil((#field[1])/2) - math.ceil((#figure.current[1])/2) + 1
	figure.y = -1
end

function full_lines()
	local lines_to_remove = {}

	for y = #field, 1, -1 do
		local all_filled = true
		for x = 1, #field[1] do
			if field[y][x] == 0 then
				all_filled = false
				break
			end
		end
		if all_filled then
			table.insert(lines_to_remove, y)
		end
	end
	
	return lines_to_remove
end

-- merges figure into field
function merge_figure(figure, field)
	for y = 1, #figure.current do
		for x = 1, #figure.current[1] do
			if string.sub(figure.current[y], x, x) == '#' then
				field[y+figure.y - 1][x+figure.x - 1] = figure.current.index
			end 
		end
	end
end

------------------------------------------------------------
--- Checks

function is_on_floor()
	return collides_with_blocks(figure.current, field, figure.x, figure.y+1)
end

function collides_with_spawn_zone(fig_to_test, field, test_x, test_y)
	return collision_at(fig_to_test, test_x, test_y,
		function (field_x, field_y)	
			if field_y < 1 then return true	end 
		end)
end

function collides_with_blocks(fig_to_test, field, test_x, test_y)
	return collision_at(fig_to_test, test_x, test_y,
		function (field_x, field_y)
			if field[field_y] == nil or
				field[field_y][field_x] == nil or
				field[field_y][field_x] ~= 0 then
				return true
			end
		end)
end

-- returns true if figure collides. tester_fun(field_x, field_y)
function collision_at(fig_to_test, test_x, test_y, tester_fun)
	for y = 1, #fig_to_test do
		for x = 1, fig_to_test[1]:len() do
			if string.sub(fig_to_test[y], x, x) == '#' then
				if tester_fun(x + test_x - 1, y + test_y - 1) then return true end
			end
		end
	end

	return false
end