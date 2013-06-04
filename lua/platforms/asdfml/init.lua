include("header_parse/sfml.lua")
--include("header_parse/glew.lua")
include("libraries/gl_enums.lua")
gl, glu = include("libraries/opengl.lua")

addons.AutorunAll()

local settings = ContextSettings()

settings.depthBits = 24
settings.stencilBits = 8
settings.antialiasingLevel = 4
settings.majorVersion = 3
settings.minorVersion = 0

local window = RenderWindow(VideoMode(800, 600, 32), "ASDFML", bit.bor(e.RESIZE, e.CLOSE), settings)

asdfml = {}

function asdfml.OnClosed(params)
	window:Close()
	os.exit()
end

function asdfml.GetWindow()
	return window
end

do
	local temp = {}
	
	for key, val in pairs(_E) do
		if key:sub(1, 4) == "EVT_" then
			temp[val] = key
		end
	end
			
	local events = {}
	
	print("events that may be triggered are:")
	
	for k,v in pairs(temp) do	
		v = "On" .. v:gsub("EVT(.+)", function(str) 
			return str:lower():gsub("(_.)", function(char) 
				return char:sub(2):upper() 
			end) 
		end)
		
		print(v)
	
		events[k] = v
		events[v] = {v = k, k = v}
	end
		
	function asdfml.HandleEvent(params)
		local name = events[tonumber(params.type)]
		if name and event.Call(name, params) ~= false then
			if asdfml[name] then 
				asdfml[name](params)
			end
		end
	end
end

local params = Event()

function main()
	event.Call("Initialize")
		
	while true do
		if window:IsOpen() then
			if window:PollEvent(params) then
				asdfml.HandleEvent(params)
			end
		end
		
		event.Call("OnUpdate")
		timer.Update()
	end
	
	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)