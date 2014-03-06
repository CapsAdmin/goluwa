audio = _G.audio or {}

audio.effect_channels = audio.effect_channels or {}

function audio.Open()
	local device = alc.OpenDevice(nil)

	-- needed to provide debugging info for alc
	alc.device = device 
	al.debug = true
	alc.debug = true

	local context = alc.CreateContext(device, nil)
	alc.MakeContextCurrent(context)
	
	audio.device = device
	audio.context = context
		
	for i = 1, 4 do
		audio.effect_channels[i] = audio.CreateAuxiliaryEffectSlot()
	end
end

function audio.Close()	
	if audio.device then
		alc.CloseDevice(audio.device)
	end
	
	if audio.context then
		alc.DestroyContext(audio.context)	
	end
end

function audio.Decode(data)
	-- use a dummy file so we can read from memory...
	local file = assert(io.open("__temp", "wb"))
	file:write(data)
	file:close()   

	local info = ffi.new("SF_INFO[1]")
	local file = soundfile.Open("__temp", e.SFM_READ, info)
	info = info[0]

	local err = ffi.string(soundfile.StringError(file))
	
	if err ~= "No Error." then
		return false, err
	end	
	
	local typename
	local extension
	local subname
	
	do
		local data = ffi.new("SF_FORMAT_INFO[1]")
		data[0].format = info.format
		soundfile.Command(nil, e.SFC_GET_FORMAT_INFO, data, ffi.sizeof("SF_FORMAT_INFO"))
		
		typename = ffi.string(data[0].name)
		extension = ffi.string(data[0].extension)

		data[0].format = bit.band(info.format , e.SF_FORMAT_SUBMASK)
		soundfile.Command(nil, e.SFC_GET_FORMAT_INFO, data, ffi.sizeof("SF_FORMAT_INFO"))
		subname = ffi.string(data[0].name)
	end
	
	local info = {
		frames = tonumber(info.frames), 
		channels = info.channels,
		format = format,
		sections = info.sections,
		seekable = info.seekable ~= 0,
		subname = subname,
		extension = extension,
		typename = typename,
		samplerate = info.samplerate,
		buffer_length = info.frames * info.channels * ffi.sizeof("ALshort"),
	}
		
	local buffer = ffi.new("ALshort[?]", info.buffer_length)
	-- just read everything  
	-- maybe have a callback later using coroutines
	soundfile.ReadShort(file, buffer, info.buffer_length)
	
	soundfile.Close(file)  
	
	os.remove("__temp")
	
	return buffer, info
end


function audio.GetEffectChannel(i)
	i = i or 1
	return audio.effect_channels[i]
end

function audio.SetEffect(channel, effect)
	local aux = audio.GetEffectChannel(channel)
	aux:SetEffect(effect)
end

local function ADD_LISTENER_FUNCTION(name, func, enum, val, vec)
	if vec then
		audio["SetListener" .. name] = function(x, y, z)
			
			val[0] = x or 0
			val[1] = y or 0
			val[2] = z or 0
			
			al[func](enum, val)
		end
		
		audio["GetListener" .. name] = function()
			return val[0], val[1], val[2]
		end
	else
		audio["SetListener" .. name] = function(x)
			
			val[0] = x
			
			al[func](enum, val)
		end
		
		audio["GetListener" .. name] = function()
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
		local get = al["Get" .. object_name .. type]
		
		if not enum then
			enum = e[name]
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
			type = "v"
		elseif type == "fv" then
			number_type = "ALfloat"
			type = "v"
		end
		
		if type == "b" then
			set = al[object_name .. "i"]
			get = al["Get" .. object_name .. "i"]
		end
				
		if type == "v" then
			local val = ffi.new(number_type .. "[3]", 0, 0, 0)
			META["Set" .. name] = function(self, x, y, z)
				
				val[0] = x or 0
				val[1] = y or 0
				val[2] = z or 0
				
				set(self.id, enum, val)
			end
			
			META["Get" .. name] = function(self)
				get(self.id, enum, val)
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
					get(self.id, enum, val)
					return val[0] == 1
				end
			else
				META["Set" .. name] = function(self, x)
					
					val[0] = x
					
					set(self.id, enum, val[0])
				end
				
				META["Get" .. name] = function(self)
					get(self.id, enum, val)
					return val[0]
				end
			end
		end
	end
end

local function GEN_TEMPLATE(type, ctor)
	local type2 = type:lower()
	
	local META = {}
	
	local META = {}
	META.__index = META
	
	META.Type = type2
	
	local fmt = type2 .. "[%i]"
	function META:__tostring()
		return (fmt):format(self.id)
	end
	
	local set_fv = al[type.."fv"]
	local set_f = al[type.."f"]
	local temp = ffi.new("float[3]")
	
	function META:SetParam(key, x, y, z)
		
		if y and z then
			temp[0] = x
			temp[1] = y
			temp[2] = z
			
			set_fv(self.id, key, x, y, z)
		elseif x then
			set_f(self.id, key, x)
		end
		
	end
	
	local get_fv = al[type.."Getfv"]
	local temp = ffi.new("float[3]")

	function META:GetParam(key)
		get_fv(self.id, key, temp)
		
		return temp[0], temp[1], temp[2]
	end
	
	local gen = al["Gen" .. type]
	
	local create = function(...)
		local self = setmetatable({}, META)
		
		self.id = gen()
		
		if ctor then
			ctor(self, ...)
		end
		
		utilities.SetGCCallback(self)
		
		return self
	end

	audio["Create".. type] = create
	--_G[type] = create
	
	function META:IsValid() return true end
	
	local delete = al["Delete"..type.."s"]
	local temp = ffi.new("int[1]", 0)
	function META:Remove()		
		if self.Stop then
			self:Stop()
		end
		
		temp[0] = self.id
		delete(1, temp)
		utilities.MakeNULL(self)
	end
		
	return META
end

local function ADD_SET_GET_OBJECT(META, ADD_FUNCTION, name, ...)
	ADD_FUNCTION(name.."ID", ...)	
			
	class.GetSet(META, name, NULL)
	
	local set = META["Set"..name.."ID"]
	META["Set"..name] = function(self, var, ...)
		set(self, var and var.id or 0, ...)
		self[name] = var
	end
end

do -- sound meta
	local META = GEN_TEMPLATE("Source", function(self, var, ...)
		if type(var) == "cdata" then
			local buffer = audio.CreateBuffer()
			buffer:SetBufferData(var, ...)
			self:SetBuffer(buffer)
		elseif type(var) == "string" then
			local data = vfs.Read(var, "rb")
			
			if not vfs.Exists(var) then
				data = var
			end
			
			local data, info = audio.Decode(data)
			
			if data then
				local buffer = audio.CreateBuffer()
				buffer:SetFormat(info.channels == 1 and e.AL_FORMAT_MONO16 or e.AL_FORMAT_STEREO16)  
				buffer:SetSampleRate(info.samplerate)
				buffer:SetBufferData(data, info.buffer_length)
				
				self:SetBuffer(buffer)
				
				self.decode_info = info
			end
			
			return data, info
		end
	end)
		
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
		local buffers = ffi.new("ALuint[1]")
		local pushed = {}
		
		function META:PushBuffer(buffer)
			buffers[0] = buffer.id
			pushed[buffer.id] = buffer
			al.SourceQueueBuffers(self.id, 1, buffers)
		end
			
		local buffers = ffi.new("ALuint[1]")

		function META:PopBuffer()	
			al.SourceUnqueueBuffers(self.id, 1, buffers)	
			return pushed[buffers[0]]
		end
	end 
	
	do
		-- http://wiki.delphigl.com/index.php/alGetSource
		
		local ADD_FUNCTION = GET_BINDER(META, "Source")
		
		ADD_FUNCTION("AL_SAMPLE_OFFSET", "i")
		ADD_FUNCTION("AL_GAIN", "f")
		ADD_FUNCTION("AL_LOOPING", "b")
		ADD_FUNCTION("AL_MAX_GAIN", "f")
		ADD_FUNCTION("AL_MAX_DISTANCE", "f")
		ADD_FUNCTION("AL_PITCH", "f")
		ADD_FUNCTION("AL_SOURCE_RELATIVE", "b")
		ADD_FUNCTION("AL_SOURCE_STATE", "i")
		ADD_FUNCTION("AL_SOURCE_TYPE", "i")
		ADD_FUNCTION("AL_VELOCITY", "fv")
		ADD_FUNCTION("AL_DIRECTION", "fv")
		ADD_FUNCTION("AL_POSITION", "fv")
		ADD_FUNCTION("AL_BYTE_OFFSET", "i")
		
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "AuxiliaryEffectSlot", "iv", e.AL_AUXILIARY_SEND_FILTER)	
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "Buffer", "i", e.AL_BUFFER)	
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "Filter", "i", e.AL_DIRECT_FILTER)	
	end
	
	function META:SetChannel(channel, ...)
		self:SetAuxiliaryEffectSlot(audio.GetEffectChannel(channel), ...)
	end
end

do -- buffer
	local META = GEN_TEMPLATE("Buffer", function(self, data, size)
		if data and size then
			self:SetBufferData(data, size)
		end
	end)
	
	class.GetSet(META, "Format", e.AL_FORMAT_MONO8)
	class.GetSet(META, "SampleRate", 44100)

	do
		-- http://wiki.delphigl.com/index.php/alGetBuffer
		
		local ADD_FUNCTION = GET_BINDER(META, "Buffer")
		
		ADD_FUNCTION("AL_BITS", "iv")
		ADD_FUNCTION("AL_CHANNELS", "i")
		ADD_FUNCTION("AL_FREQUENCY", "i")
		ADD_FUNCTION("AL_SIZE", "i")
		
	end
	
	function META:SetBufferData(data, size)	
		al.BufferData(self.id, self.Format, data, size, self.SampleRate)
	end
end 

do -- effect
	local META = GEN_TEMPLATE("Effect", function(self, type)
		self:SetType(type)
	end)
	
	do
		local ADD_FUNCTION = GET_BINDER(META, "Effect")
		
		ADD_FUNCTION("Type", "i", e.AL_EFFECT_TYPE)
	end
	
	function META:BindToChannel(channel)
		audio.SetEffect(channel, self)
	end
	
	function META:UnbindFromChannel()
		audio.SetEffect(channel, self)
	end
end

do -- filter
	local META = GEN_TEMPLATE("Filter", function(self, type)
		self:SetType(type)
	end)
	
	do
		local ADD_FUNCTION = GET_BINDER(META, "Filter")
		
	end
end


do -- auxiliary effect slot 
	local META = GEN_TEMPLATE("AuxiliaryEffectSlot", function(self, effect)
		if typex(effect) == "effect" then
			self:SetEffect(effect)
		end
	end)
	
	do
		local ADD_FUNCTION = GET_BINDER(META, "AuxiliaryEffectSlot")
		
		ADD_FUNCTION("AL_EFFECTSLOT_GAIN", "f")
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "Effect", "iv", e.AL_EFFECTSLOT_EFFECT)
	end

end
 
_G.Sound = audio.CreateSource

do -- microphone
	
	function audio.CreateAudioCapture(sample_rate, format, max_size)
		sample_rate = sample_rate or 44100
		format = format or e.AL_FORMAT_MONO8
		max_size = max_size or 4096
		
		local self = utilities.CreateBaseObject("audio_capture")
		
		local id = alc.CaptureOpenDevice(nil, sample_rate, format, max_size)
		
		self.id = id
		
		function self:OnRemove(s)
			alc.CaptureCloseDevice(self.id)
		end
		
		function self:Start()
			alc.CaptureStart(self.id)
		end
		
		function self:Stop()
			alc.CaptureStop(self.id)
		end
		
		local val = ffi.new("ALint[1]")
		
		function self:GetCapturedSamples()			
			alc.GetIntegerv(id, e.ALC_CAPTURE_SAMPLES, 1, val)	
			return val[0]
		end
		
		function self:IsFull()
			return self:GetCapturedSamples() >= max_size
		end
		
		function self:Read()
			local size = self:GetCapturedSamples()
			local buffer = ffi.new("ALshort[?]", size)
			
			alc.CaptureSamples(id, buffer, size)
			
			return buffer, size
		end
				
		return self
	end
	
end

audio.Close()

timer.Delay(0.1, function() 
	audio.Open() 
end)