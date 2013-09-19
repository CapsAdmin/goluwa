_G.sound = _G.sound or {}

function sound.Initialize()
	local device = alc.OpenDevice(nil)

	-- needed to provide debugging info for alc
	alc.device = device 
	alc.debug = true

	local context = alc.CreateContext(device, nil)
	alc.MakeContextCurrent(context)
	
	sound.device = device
	sound.context = context
end

local function ADD_LISTENER_FUNCTION(name, func, enum, val, vec)
	if vec then
		sound["SetListener" .. name] = function(x, y, z)
			
			val[0] = x
			val[1] = y
			val[2] = z
			
			al[func](enum, val)
		end
		
		sound["GetListener" .. name] = function()
			return val[0], val[1], val[2]
		end
	else
		sound["SetListener" .. name] = function(x)
			
			val[0] = x
			
			al[func](enum, val)
		end
		
		sound["GetListener" .. name] = function()
			return val[0]
		end
	end
end

ADD_LISTENER_FUNCTION("Position", al.Listenerfv, ffi.new("float[3]", 0, 0, 0), true)
ADD_LISTENER_FUNCTION("Velocity", al.Listenerfv, ffi.new("float[3]", 0, 0, 0), true)
ADD_LISTENER_FUNCTION("Orientation", al.Listenerfv, ffi.new("float[3]", 0, 0, 0), true)

local function GET_BINDER(META, object_name)
	return function(name, type, enum)

		local set = al[object_name .. type]
		local get = al[object_name .. "Get" .. type]
		
		if not enum then
			enum = _E[name]
			name = name:gsub("AL_", "")
			name = name:gsub(object_name:upper() .. "_", "")
			name = name:lower()
			name = name:gsub("(_%l)", function(char) return char:upper():sub(2,2) end)
			name = name:sub(1,1):upper() .. name:sub(2)
		end
		
		local number_type
		
		if type == "i" or type == "b" then
			number_type = "ALint"
		elseif type == "f" then
			number_type = "ALfloat"
		elseif type == "iv" then
			number_type = "ALint"
			type = v
		elseif type == "fv" then
			number_type = "ALfloat"
			type = v
		end
		
		if type == "v" then
			local val = ffi.new(number_type .. "[3]", 0, 0, 0)
			META["Set" .. name] = function(self, x, y, z)
				
				val[0] = x
				val[1] = y
				val[2] = z
				
				set(self.id, enum, val)
			end
			
			META["Get" .. name] = function(self)
				get(self.id, val)
				return val[0], val[1], val[2]
			end
		else
			local val = ffi.new(number_type .. "[1]", 0)
			
			if type == "b" then
				META["Set" .. name] = function(self, bool)
					
					val[0] = bool and 1 or 0
					
					set(self.id, enum, val[0])
				end
				
				META["Get" .. name] = function(self)
					get(self.id, val)
					return val[0] == 1
				end
			else
				META["Set" .. name] = function(self, x)
					
					val[0] = x
					
					set(self.id, enum, val[0])
				end
				
				META["Get" .. name] = function(self)
					get(self.id, val)
					return val[0]
				end
			end
		end
	end
end

do -- sound meta
	local META = {}
	META.__index = META
	
	META.Type = "sound"
		
	function META:__tostring()
		return ("sound[%i]"):format(self.id)
	end
	
	function META:Play()
		al.SourcePlay(self.id)
	end
	
	function META:Stop()
		al.SourceStop(self.id)
	end
	
	function META:Rewind()
		al.SourceRewind(self.id)
	end
	
	do
		-- http://wiki.delphigl.com/index.php/alGetSource
		
		local ADD_SOURCE_FUNCTION = GET_BINDER(META, "Source")
		
		ADD_SOURCE_FUNCTION("AL_SAMPLE_OFFSET", "i")
		ADD_SOURCE_FUNCTION("AL_GAIN", "f")
		ADD_SOURCE_FUNCTION("AL_LOOPING", "b")
		ADD_SOURCE_FUNCTION("AL_MAX_GAIN", "f")
		ADD_SOURCE_FUNCTION("AL_MAX_DISTANCE", "f")
		ADD_SOURCE_FUNCTION("AL_PITCH", "f")
		ADD_SOURCE_FUNCTION("AL_SOURCE_RELATIVE", "b")
		ADD_SOURCE_FUNCTION("AL_SOURCE_STATE", "i")
		ADD_SOURCE_FUNCTION("AL_SOURCE_TYPE", "i")
		ADD_SOURCE_FUNCTION("AL_VELOCITY", "fv")
		ADD_SOURCE_FUNCTION("AL_DIRECTION", "fv")
		ADD_SOURCE_FUNCTION("AL_BYTE_OFFSET", "i")
		ADD_SOURCE_FUNCTION("BufferID", "i", e.AL_BUFFER)	
		
		
		class.GetSet(META, "Buffer", NULL)
		
		function META:SetBuffer(buffer)
			self:SetBufferID(buffer.id)
			self.Buffer = buffer
		end
	end
	
	function sound.CreateSound(data, size)
		local self = setmetatable({}, META)
		
		self.id = al.GenSource()
		
		if data then
			local buffer = sound.CreateBuffer()
			buffer:SetBufferData(data, size)
			self:SetBuffer(buffer)
		end
		
		return self
	end
	
	function META:Remove()
		al.DeleteSources(1, ffi.new("int[1]", self.id))
		utilities.MakeNULL(self)
	end
end

do -- buffer
	local META = {}
	META.__index = META
	
	META.Type = "buffer"
		
	function META:__tostring()
		return ("buffer[%i]"):format(self.id)
	end
	
	class.GetSet(META, "Format", e.AL_FORMAT_MONO8)
	class.GetSet(META, "SampleRate", 44100)

	do
		-- http://wiki.delphigl.com/index.php/alGetBuffer
		
		local ADD_BUFFER_FUNCTION = GET_BINDER(META, "Buffer")
		
		ADD_BUFFER_FUNCTION("AL_BITS", "iv")
		ADD_BUFFER_FUNCTION("AL_CHANNELS", "i")
		ADD_BUFFER_FUNCTION("AL_FREQUENCY", "i")
		ADD_BUFFER_FUNCTION("AL_SIZE", "i")
		
	end
	
	function META:SetBufferData(data, size)	
		al.BufferData(self.id, self.Format, data, size, self.SampleRate)
	end
	
	function sound.CreateBuffer()
		local self = setmetatable({}, META)
		
		self.id = al.GenBuffer()
		
		return self
	end
	
	function META:Remove()
		al.DeleteBuffers(1, ffi.new("int[1]", self.id))
		utilities.MakeNULL(self)
	end
end

_G.Sound = sound.CreateSound
_G.Buffer = sound.CreateBuffer
sound.Initialize()
