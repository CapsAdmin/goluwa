-----------------------------------------------------------------------------------------------------------------------
------ Data

settings = {
	
}

-- block look
block = {
	w = 15,
	h = 15,
	offset = 1 -- space between blocks
}

-- tetris color scheme
colors = {
	{0, 255, 255},
	{32, 64, 255},
	{255, 128, 0},
	{255, 255, 16},
	{255, 16, 255},
	{0, 255, 0},
	{255, 0, 0},
	{128, 0, 128}
}

init_audio = function ()
	for i,v in pairs(audiofiles) do
		gameaudio[v] = love.audio.newSource(v..'.ogg', 'static')
	end
end

audiofiles = {
	'clear1',
	'drop',
	'gameover',
	--[[
	'spin',
	'move',
	'clear1',
	'clear2',
	'clear3',
	'clear4'
	]]
}

gameaudio = {
}

-- list of possible figures
-- they are colored by their index in 'colors' list
figures = {
	{'    ', '####', '    '},
	{'#  ', '###', '   '},
	{'  #', '###', '   '},
	{'##', '##'},
	{' ##', '## ', '   '},
	{'## ', ' ##', '   '},
	{' # ', '###', '   '}
}

rules = {
	fps = 60,				-- frames per second
	shadow = true, 			-- shadow piece
	gravity = 0,			-- 0-disabled, 1-sticky, 2-cascade (only 0 implemented)
	next_visible = 1, 		-- number of preview pieces
	move_reset = false,		-- reset timer on horizontal moves
	spin_reset = false,		-- reset timer on rotation
	hard_drop_lock_delay = false, -- delay piece locking after hard drop
	wall_kick = false, 		-- wall kicks (not implemented)

	frame_delay = 1/60, 	-- defines framerate
	lock_delay = 30, 		-- delay before piece locks
	spawn_delay = 1, 		-- delay before piece spawns
	clear_delay = 10, 		-- delay after piece locks and before next piece spawns
	autorepeat_delay = 15, 	-- initilal delay
	autorepeat_interval = 4, -- delay between moves

	playfield_width = 10,	-- width of the playfield.
	playfield_height = 20,	-- height of the playfield. 2 invisible rows will be added.

	rotation_system = 'simple', -- 'srs', 'dtet', 'tgm'. simple is only implemented
	randomizer = 'rg',-- 'stupid'-just math.random, 'rg'-7-bag, 'tgm'(not implemented)

	soft_gravity = {delay = 3, distance = 1} -- G = distance / delay. Params of the soft drop.
	-- delay means how frequent will piece fall. distance - number of blocks.
}

-- stores game info, such as score, game speed etc.
game = {
	state = '',--'running', 'clearing', 'game_over', 'spawning', 'paused', 'on_floor'(when lock delay>0)
	state_names = {on_floor = 'On floor', clearing = 'Clearing full lines',
					game_over = 'Game over', paused = 'Paused', in_air = 'Falling', spawning = 'Spawning'},
	last_state = '', -- stores state before pausing

	timer = 0, --in seconds
	
	frame = 1, -- in frames
	autorepeat_timer = 1, -- in frames
	hold_timer = 1, --in frames, frames since left or right is holded

	gravity = 1,
	gravities = {{delay = 64, distance = 1}, rules.soft_gravity}, -- delay with which figure fall occurs.

	hold_dir = 0, -- -1 left, 1 right, 0 none

	lines_to_remove = {},

	score = 0,
	level = 1,

	init = function()
		game.score = 0
		game.level = 1
		game.curr_interval = 0
		game.frame_delay = 1/rules.fps
		game.frame_timer = 0
		game.gravities = {{delay = 64, distance = 1}, rules.soft_gravity}
		game.history = {}
		game.random_gen_data = {}
		figure.next = game.random_fig()
		spawn_fig()
	end,

	history = {},
	random_gen_data = {},

	random_fig = function()
		local result = randomizers[rules.randomizer](game.history, game.random_gen_data)

		local figure = {}
		for _, line in ipairs(figures[result]) do
			table.insert(figure, line)
		end
		figure.index = result
		table.remove(game.history)
		table.insert(game.history, 1, result)
		return figure
	end
}

-- field size and position
-- also stores blocks as two-dimentional array
-- '1' means no block, others are blocks and colored by the 'colors' table
field = {
	w = 0,
	h = 0,
	offset = {x = 100, y = 100},

	init = function ()
		field.w = rules.playfield_width
		field.h = rules.playfield_height
		for y = -1, field.h do
			field[y] = {}
			for x = 1, field.w do
				field[y][x] = 0
			end
		end
	end
}

figure = {
	x = 0,
	y = 0,
	current = {},
	next = {},
}

randomizers = {
	stupid = function(history, data)
		local index = math.random(1, #figures)
		return index
	end,
	rg = function(history, bag)
		if #bag == 0 then
			for i=1, #figures do
				bag[i] = i
			end
			shuffle_array(bag)
		end
		result = bag[1]
		table.remove(bag, 1)
		
		return result
	end
}

function shuffle_array(array)
	local counter = #array
    while counter > 1 do
        local index = math.random(counter)
        array[counter], array[index] = array[index], array[counter]
        counter = counter - 1
    end
end