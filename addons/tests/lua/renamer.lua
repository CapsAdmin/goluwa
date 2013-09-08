local dir = "C:/Users/CapsAdmin/Documents/Downloads/the house of the dead 1-3/The House of the Dead 2/SOUND/VOICE/ST6/" 

local files = vfs.Find(dir)
table.print(files)

local i = 1
local buffer = {}

local function ask()

	os.execute(([[start "" %q]]):format(dir .. files[i]))
	print(files[i])
	
	local file = io.open(dir .. files[i], "rb")
	local wav = file:read("*a")
	file:close()	
	
	event.AddListener("OnLineEntered", "renamer", function(name)	 
		local new = dir .. name .. ".wav"
		local file = io.open(new, "rb")
		if file then
			local wav = file:read("*a")
			file:close()
			lfs.mkdir(dir .. name)
			new = dir.. name .. "/" .. files[i]
			
			local file = io.open(dir .. name .. "/" .. name .. ".wav", "wb")   
			file:write(wav)
			file:close()
		end
		
		
		local file = io.open(new, "wb")   
		file:write(wav)
		file:close()
		
		ask()
		
		return false
	end)
	
	i = i + 1
end

ask() 