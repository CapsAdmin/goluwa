local love = ... or love

love.math = {}

for k,v in pairs(math) do
	love.math[k] = v
end

do
	local SEED = 0

	function love.math.setRandomSeed(seed)
		SEED = seed
	end

	function love.math.getRandomSeed(seed)
		return SEED
	end
	
	function love.math.random(min, max)
		math.randomseed(SEED)
		local val
		
		if min and max then
			val = math.random(min, max)
		elseif min and not max then
			val = math.random(1, min)
		else
			val = math.random()
		end
		
		math.randomseed(os.clock())
		return val
	end
end

do
	local RandomGenerator = {}
	
	RandomGenerator.Type = "RandomGenerator"
	
	RandomGenerator.seed = 0

	function RandomGenerator:setSeed(seed)
		self.seed = seed
	end
	
	function RandomGenerator:getSeed()
		return self.seed
	end
	
	function RandomGenerator:setState(state)
		self.seed = tonumber(state)
	end
	
	function RandomGenerator:getState()
		return tostring(self.seed)
	end
	
	function RandomGenerator:random(min, max)
		math.randomseed(self.seed)
		local val
		if min and max then
			val = math.random(min, max)
		elseif min and not max then
			val = math.random(1, min)
		else
			val = math.random()
		end
		math.randomseed(os.clock())
		return val
	end
	
	function RandomGenerator:randomNormal()
		
	end
	
	function love.math.newRandomGenerator()
		local self = lovemu.CreateObject(RandomGenerator)
		
		return self
	end	
end