world = {}

local tiles = {}
solid = {}
local map = {}
local ts = 16
mapnum = 1
mapwidth = {}
mapwidth[1] = 1300
mapwidth[2] = 1200
mapwidth[3] = 1300
mapwidth[4] = 1300
mapwidth[5] = 1300

respawnX = 0 	
respawnY = 0

local fontS = love.graphics.newFont("fonts/1a.ttf", 14);
local showMessage = false
local timer = 0

function world:load()
	tiles[1] = love.graphics.newImage("pics/env/grass.png")
	tiles[1]:setFilter('nearest','nearest')
	tiles[2] = love.graphics.newImage("pics/env/dirt.png")
	tiles[2]:setFilter('nearest','nearest')

	tiles[3] = love.graphics.newImage("pics/env/stonePattern.png")
	tiles[3]:setFilter('nearest','nearest')
	tiles[4] = love.graphics.newImage("pics/env/stonePatternTop.png")
	tiles[4]:setFilter('nearest','nearest')
	tiles[17] = love.graphics.newImage("pics/env/stonePatternBack.png")
	tiles[17]:setFilter('nearest','nearest')

	tiles[5] = love.graphics.newImage("pics/env/sandBottom.png")
	tiles[5]:setFilter('nearest','nearest')
	tiles[6] = love.graphics.newImage("pics/env/sandTop.png")
	tiles[6]:setFilter('nearest','nearest')

	tiles[8] = love.graphics.newImage("pics/env/dirtBack.png")
	tiles[8]:setFilter('nearest','nearest')
	tiles[9] = love.graphics.newImage("pics/env/back_dirt.png")
	tiles[9]:setFilter('nearest','nearest')
	tiles[10] = love.graphics.newImage("pics/env/back_dirtTop.png")
	tiles[10]:setFilter('nearest','nearest')

	tiles[11] = love.graphics.newImage("pics/env/brick.png")
	tiles[11]:setFilter('nearest','nearest')
	tiles[12] = love.graphics.newImage("pics/env/brickTop.png")
	tiles[12]:setFilter('nearest','nearest')

	--spawns
	tiles[13] = love.graphics.newImage("pics/env/clear.png")
	tiles[13]:setFilter('nearest','nearest')
	tiles[16] = love.graphics.newImage("pics/env/stonePatternTop.png")
	tiles[16]:setFilter('nearest','nearest')

	tiles[14] = love.graphics.newImage("pics/env/spikes.png")
	tiles[14]:setFilter('nearest','nearest')
	tiles[15] = love.graphics.newImage("pics/env/crate.png")
	tiles[15]:setFilter('nearest','nearest')
	
	--bridge parts
	tiles[1000] = love.graphics.newImage("pics/env/bridgeLower.png")
	tiles[1000]:setFilter('nearest','nearest')
	tiles[1003] = love.graphics.newImage("pics/env/bridgeRail.png")
	tiles[1003]:setFilter('nearest','nearest')
	--left
	tiles[1001] = love.graphics.newImage("pics/env/bridgePostL.png")
	tiles[1001]:setFilter('nearest','nearest')
	--right
	tiles[1002] = love.graphics.newImage("pics/env/bridgePostR.png")
	tiles[1002]:setFilter('nearest','nearest')

		map[1] = {
		{0},
		{0},
		{0},
		{0},
		{0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10,10,10,10,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,8,8,8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,14,14,14,14,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
		}


		map[2] = {
		{0},
		{0},
		{0},
		{0},
		{0},
		{0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1001,1003,1003,1003,1003,1002,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,11,11,11,11,11,11,11,11,11,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1000,1000,1000,1000,11,11,11,11,11,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,9,9,9,9,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,9,9,9,9,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
		}

		map[3] = {
		{0},
		{0},
		{0},
		{0},
		{0},
		{0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
		{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
		}

		map[4] = {
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,16,4,4,4,4,4,4,4,4,4,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,17,17,17,17,17,17,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,14,14,14,14,14,14,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3}
		}

		map[5] = {
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,16,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,17,17,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,14,14,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3},
		{3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3}
		}
for rowIndex=1, #map[mapnum] do
    row = map[mapnum][rowIndex]
    for columnIndex=1, #row do
      local number = row[columnIndex]
        if number == 2 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 1 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 3 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 4 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 5 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 6 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 8 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 9 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 10 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 11 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 12 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 14 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 15 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 17 then
             solid:spawn((columnIndex-1)*ts, (rowIndex-1)*ts,tiles[number])
        end
        if number == 13 then
        	respawnX = (columnIndex-1)*ts
        	respawnY = (rowIndex-1)*ts
            solid:spawn(respawnX, respawnY,tiles[number])
        end
         if number == 16 then
        	respawnX = (columnIndex-1)*ts
        	respawnY = (rowIndex-1)*ts
            solid:spawn(respawnX, respawnY,tiles[number])
        end

        --pridge components
        if number == 1000 then
             solid:spawn((columnIndex-1)*16, (rowIndex-1)*16,tiles[number])
        end
        if number == 1001 then
             solid:spawn((columnIndex-1)*16, (rowIndex-1)*16,tiles[number])
        end
        if number == 1002 then
             solid:spawn((columnIndex-1)*16, (rowIndex-1)*16,tiles[number])
        end
        if number == 1003 then
             solid:spawn((columnIndex-1)*16, (rowIndex-1)*16,tiles[number])
        end

       end
  end

end

function solid:spawn(x,y,pic)
	table.insert(solid, {x = x, y = y,pic = pic,w = 16,h = 16,cancollide=true})
end

function world:draw()
	if mapnum == 4 or mapnum == 5 then 
		love.graphics.setColor(50,56,60)
		love.graphics.setBackgroundColor(60,70,60)
	else 
		love.graphics.setBackgroundColor(bg_r,bg_g,bg_b,250)
		love.graphics.setColor(sky_r,sky_g,sky_b,250)
	end
   for i,v in ipairs(solid) do
      love.graphics.draw(v.pic,v.x,v.y)
  end
  world:text()
end

function world:update(dt)
	for i,v in ipairs(solid) do 
	--tiles that dont collide with player
	if v.pic == tiles[1002] or v.pic == tiles[1003] or v.pic == tiles[1001] or v.pic == tiles[13] or v.pic == tiles[8] or v.pic == tiles[12] or v.pic == tiles[4] or v.pic == tiles[16] or v.pic == tiles[17] or v.pic == tiles[10] then
		v.cancollide = false
	end

	--spikes collision 
	if v.pic == tiles[14] and player.x + player.w > v.x and 
		player.x < v.x + v.w and 
		player.y + player.h > v.y and 
		player.y < v.y + v.h then 
		player.health = player.health - 1
	end
	--box collision detection for movement
	if v.pic == tiles[15] and player.givepunch and player.state == 'idleR' and 
		player.x + player.w + 8 >= v.x then  
		v.x = v.x + 80 * dt
	end
	if v.pic == tiles[15] and player.givepunch and player.state == 'idleL' and 
		player.x <= v.x + (v.w+v.w*.5) then  
		v.x = v.x - 80 * dt
	end
		-- player collision
		if v.cancollide then 
		--left                                       
		if player.x + player.w >= v.x and
		player.x <= v.x + v.w and
		player.y + v.h >= v.y + v.w and
		player.y  <= v.y + v.h then
			player.xvel = -player.xvel
		end
		--right
		if v.x + v.w * .5 < player.x + player.w * .5 and
		v.x + v.w * .5 >  player.x + player.w * .5 then
		if player.x + player.w > v.x and
		player.x + (player.w * .5) < v.x + (v.w * .5) and
		player.y + player.h > v.y + extra and
		player.y + extra < v.y + v.h then
			player.x = v.x - player.w
			player.xvel = 0
		end
	end
		if player.y + player.h > v.y and
		player.y + player.h < v.y + v.h  and
		player.x + player.w > v.x + extra and
		player.x + extra < v.x + v.w then
			player.y = v.y - player.h
			player.yvel = 0
			player.inAir = false
		end
	end
		--end player collison
	end

if showMessage then 
	timer = timer + dt
	if timer > 2 then 
		showMessage = false
		timer = 0
	end
end

end

function world:lvlTransition()
	for i=0,#solid do
		table.remove(solid, i)
	end

	if #solid == 0 then
		--advance to a new level only if every enemy is dead :)
		mapnum = mapnum + 1
		superJumpTimer = 0
		superSpeedTimer = 0
		world:load()
		anim:load()
		world:spawnEntities()
		--respawn player
		player.x = respawnX
		player.y = respawnY 
	end
end

function world:spawnEntities()
	if mapnum == 4 then 
		isnight = true
		loadAnimal = false
		loadClouds = false
		loadParalex = false
		loadAnimal = false
	end

	if mapnum == 3 then 
		loadAnimal = true
		loadVil = false
		loadShops = false
		loadKeepers = false
		for b = 1 , 2 do 
			enemy:spawn(math.random(200,300) + math.random(400,500),112,math.random(4,6),"beast",beastR[1])
			enemy:spawn(math.random(600,700) + math.random(200,230) - 30 + 102 - 40 + 20,112,math.random(4,6),"blob",blobL[1])
		end
	end

	if mapnum == 2 then 
		loadVil = true
		loadShops = true
		loadKeepers = true
		for k = 1 , 1 do 
		keeper:spawn(math.random(200,300),110,"baker")
		keeper:spawn(math.random(300,400),110,"blackSmith")
		keeper:spawn(math.random(400,600),110,"innL")
		keeper:spawn(math.random(600,800),110,"shopKeeperL")
		end
		for i = 1 , 2 do 
		vil:spawn(math.random(100,200)+math.random(300,600),109,1)
		end
		for i = 1 , 4 do  
		vil:spawn(math.random(200,400)+math.random(300,400),109,2)
		vil:spawn(math.random(170,360)+math.random(200,300),109,3)
	end
	if loadShops then 
		building:shopBuildingSpawn(60,64,1)
		building:shopBuildingSpawn(320,48,2)
		building:shopBuildingSpawn(700,48,3)
	end

	end
end


function world:text(dt)
	if mapnum == 1 then
		showMessage = true
		love.graphics.setFont(fontS) 
		if showMessage then 
		love.graphics.print("Jump the gap pressing Up key",166,70)
		end
	end
	if mapnum == 3 then
		showMessage = true
		love.graphics.setFont(fontS) 
		if showMessage then 
		love.graphics.print("You can sneak by pressing lCtrl",166,70)
		end
	end
	if mapnum == 4 then
		showMessage = true
		love.graphics.setFont(fontS) 
		if showMessage then 
		love.graphics.print("The Greate Mountain",320,40)
		end
	end
end




































































