local ffi = require("ffi")
local al = desire("al")
local alc = desire("alc")

if not al or not alc then return end

local audio = _G.audio or {}
al.debug = true
alc.debug = true
audio.effect_channels = audio.effect_channels or table.weak()

function audio.Initialize(name)
	vfs.Write("temp/al_config.ini", "slots = 256\nsends = 256\n")
	os.setenv("ALSOFT_CONF", R("temp/al_config.ini"))
	audio.Shutdown()

	if not name or name == "default" then
		name = audio.GetAllOutputDevices()[1]
	end

	if audio.debug then llog("opening device %q for sound output", name) end

	local device
	print(name, "?????????????")

	if name == "loopback" then
		device = alc.LoopbackOpenDeviceSOFT("default")
	else
		device = alc.OpenDevice(name)
	end

	print(name, "!!!!!!!!!!!!")

	if device == nil then
		llog("opening device failed: ", alc.GetErrorString(device))
		return
	end

	-- needed to provide debugging info for alc
	alc.device = device
	al.debug = true
	alc.debug = true

	if name == "loopback" then
		local channels = alc.e.STEREO_SOFT
		local frequency = 48000
		local format = alc.e.SHORT_SOFT
		audio.context = alc.CreateContext(
			device,
			ffi.new(
				"const int[16]",
				{
					alc.e.FORMAT_CHANNELS_SOFT,
					channels,
					alc.e.FORMAT_TYPE_SOFT,
					format,
					alc.e.FREQUENCY,
					frequency,
					0,
				}
			)
		)

		if alc.IsRenderFormatSupportedSOFT(device, frequency, channels, format) == 0 then
			llog("unable to initialize loopback audio context, format not supported")
			return
		end
	else
		audio.context = alc.CreateContext(device, nil)
	end

	audio.channels = 2
	alc.MakeContextCurrent(audio.context)
	audio.device = device
	event.AddListener("ShutDown", "openal", audio.Shutdown)
end

function audio.Shutdown()
	audio.Panic()

	if audio.context then alc.DestroyContext(audio.context) end

	if audio.device then alc.CloseDevice(audio.device) end
end

function audio.Panic()
	for _, v in pairs(prototype.GetCreated()) do
		if v:IsValid() and v.is_audio_object then v:Remove() end
	end
end

function audio.GetAllOutputDevices()
	local lst = ffi.cast("unsigned char *", alc.GetString(nil, alc.e.ALL_DEVICES_SPECIFIER))
	local devices = {}
	local temp = {}

	for i = 0, 1000 do
		local byte = lst[i]

		if byte == 0 then
			list.insert(devices, list.concat(temp))
			temp = {}
		else
			list.insert(temp, string.char(byte))
		end

		if byte == 0 and lst[i + 1] == 0 then break end
	end

	return devices
end

function audio.GetAvailableEffects()
	local effects = al.GetAvailableEffects()
	local out = {}

	for k, v in pairs(effects) do
		local tbl = {}

		for k, v in pairs(v.params) do
			tbl[k] = {max = v.max, min = v.min, default = v.default}
		end

		out[k] = tbl
	end

	return out
end

function audio.GetAvailableFilters()
	local effects = al.GetAvailableFilters()
	local out = {}

	for k, v in pairs(effects) do
		local tbl = {}

		for k, v in pairs(v.params) do
			tbl[k] = {max = v.max, min = v.min, default = v.default}
		end

		out[k] = tbl
	end

	return out
end

function audio.GetAllInputDevices()
	local lst = alc.GetString(nil, alc.e.CAPTURE_DEVICE_SPECIFIER)
	local devices = {}
	local temp = {}

	for i = 0, 1000 do
		local byte = lst[i]

		if byte == 0 then
			list.insert(devices, list.concat(temp))
			temp = {}
		else
			list.insert(temp, string.char(byte))
		end

		if byte == 0 and lst[i + 1] == 0 then break end
	end

	return devices
end

function audio.ReadLoopbackOutput(samples)
	samples = samples or 4096
	local buffer = ffi.new("int16_t[?]", samples * audio.channels)
	alc.RenderSamplesSOFT(alc.device, buffer, samples)
	return buffer, samples
end

function audio.GetEffectChannel(i)
	i = i or 1
	audio.effect_channels[i] = audio.effect_channels[i] or audio.CreateAuxiliaryEffectSlot()
	return audio.effect_channels[i]
end

function audio.SetEffect(channel, effect)
	local aux = audio.GetEffectChannel(channel)
	aux:SetEffect(effect)
end

do
	local translate = {
		none = 0,
		inverse = e.AL_INVERSE_DISTANCE,
		inverse_clamped = e.AL_INVERSE_DISTANCE_CLAMPED,
		linear = e.AL_LINEAR_DISTANCE,
		linear_clamped = e.AL_LINEAR_DISTANCE_CLAMPED,
		exponent = e.AL_EXPONENT_DISTANCE,
		exponent_clamped = e.AL_EXPONENT_DISTANCE_CLAMPED,
	}

	function audio.SetDistanceModel(name)
		local enum = translate[name]

		if not enum then error("unknown distance model " .. name, 2) end

		al.DistanceModel(enum)
		audio.distance_model = name
	end

	function audio.GetDistanceModel()
		return audio.distance_model
	end
end

local function ADD_LISTENER_FUNCTION(name, func, enum, val, vec, sigh)
	if vec then
		if sigh then
			audio["SetListener" .. name] = function(x, y, z, a, b, c)
				val[0] = x or 0
				val[1] = y or 0
				val[2] = z or 0
				val[3] = a or 0
				val[4] = b or 0
				val[5] = c or 0
				func(enum, val)
			end
			audio["GetListener" .. name] = function()
				return val[0], val[1], val[2], val[3], val[4], val[5]
			end
		else
			audio["SetListener" .. name] = function(x, y, z)
				val[0] = x or 0
				val[1] = y or 0
				val[2] = z or 0
				func(enum, val)
			end
			audio["GetListener" .. name] = function()
				return val[0], val[1], val[2]
			end
		end
	else
		audio["SetListener" .. name] = function(x)
			val[0] = x
			func(enum, val)
		end
		audio["GetListener" .. name] = function()
			return val[0]
		end
	end
end

ADD_LISTENER_FUNCTION("Gain", al.Listenerfv, al.e.GAIN, ffi.new("float[1]"))
ADD_LISTENER_FUNCTION("Position", al.Listenerfv, al.e.POSITION, ffi.new("float[3]"), true)
ADD_LISTENER_FUNCTION("Velocity", al.Listenerfv, al.e.VELOCITY, ffi.new("float[3]"), true)
ADD_LISTENER_FUNCTION("Orientation", al.Listenerfv, al.e.ORIENTATION, ffi.new("float[6]"), true, true)

local function GET_BINDER(META, object_name)
	return function(name, type, enum)
		local set = al[object_name .. type]
		local get = al["Get" .. object_name .. type]

		if not enum then
			enum = al.e[name]
			name = name:gsub("", "")
			name = name:gsub(object_name:upper() .. "_", "")
			name = name:lower()
			name = name:gsub("(_%l)", function(char)
				return char:upper():sub(2, 2)
			end)
			name = name:sub(1, 1):upper() .. name:sub(2)
		end

		local number_type

		if type == "i" or type == "b" then
			number_type = ffi.typeof("int")
		elseif type == "f" then
			number_type = ffi.typeof("float")
		elseif type == "iv" then
			number_type = ffi.typeof("int")
			type = "v"
		elseif type == "fv" then
			number_type = ffi.typeof("float")
			type = "v"
		end

		if type == "b" then
			set = al[object_name .. "i"]
			get = al["Get" .. object_name .. "i"]
		end

		if type == "v" then
			local val = ffi.typeof("$[3]", number_type)(0, 0, 0)
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
			local val = ffi.typeof("$[1]", number_type)(0)

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

local function GEN_TEMPLATE(type, ctor, on_remove)
	local type2 = type:lower()
	local META = prototype.CreateTemplate("audio_" .. type2)
	local fmt = type2 .. "[%i]"

	function META:__tostring2()
		return (fmt):format(self.id)
	end

	local set_fv = al[type .. "fv"]
	local set_f = al[type .. "f"]
	-- todo: move this to metatable?
	META.is_audio_object = true

	function META:SetParam(key, x, y, z)
		local temp = ffi.new("float[3]")

		if self.params and self.params[key] then
			local val = x or self.params[key].default

			if self.params[key].min and self.params[key].max then
				val = math.clamp(val, self.params[key].min, self.params[key].max)
			end

			set_f(self.id, self.params[key].enum, val)
			self.params[key].val = val
		elseif y and z then
			temp[0] = x
			temp[1] = y
			temp[2] = z
			set_fv(self.id, key, x, y, z)
		elseif x then
			set_f(self.id, key, x)
		end

		if self.slots then
			for _, slot in pairs(self.slots) do
				slot:SetEffect(self)
			end
		end
	end

	local get_fv = al["Get" .. type .. "fv"]

	function META:GetParam(key)
		local temp = ffi.new("float[3]")

		if self.params and self.params[key] then
			local val = self.params[key].default

			if self.params[key].min and self.params[key].max then
				val = math.clamp(val, self.params[key].min, self.params[key].max)
			end

			get_fv(self.id, self.params[key].enum, temp)
			self.params[key].val = val
		else
			get_fv(self.id, key, temp)
		end

		return temp[0], temp[1], temp[2]
	end

	local key = "Gen" .. type
	local create = function(...)
		local self = META:CreateObject()
		self.id = al[key]()

		if ctor then ctor(self, ...) end

		return self
	end
	audio["Create" .. type] = create
	--_G[type] = create
	local delete = al["Delete" .. type .. "s"]
	local temp = ffi.new("int[1]", 0)

	function META:OnRemove()
		if on_remove then on_remove(self) end

		temp[0] = self.id
		delete(1, temp)
	end

	return META
end

local function ADD_SET_GET_OBJECT(META, ADD_FUNCTION, name, ...)
	ADD_FUNCTION(name .. "ID", ...)
	META:GetSet(name, NULL)
	local set = META["Set" .. name .. "ID"]
	META["Set" .. name] = function(self, var, ...)
		set(self, var and var.id or 0, ...)
		self[name] = var
	end
end

do -- source
	local META = GEN_TEMPLATE("Source", function(self, var, length, info)
		self.effects = {}

		if type(var) == "cdata" and type(length) == "cdata" or type(length) == "number" then
			local buffer = audio.CreateBuffer()

			if type(info) == "table" and info.samplerate and info.channels then
				buffer:SetFormat(info.channels == 1 and al.e.FORMAT_MONO16 or al.e.FORMAT_STEREO16)
				buffer:SetSampleRate(info.samplerate)
				self.decode_info = info
			end

			buffer:SetData(var, length)
			self:SetBuffer(buffer)
		elseif typex(var) == "audio_buffer" then
			self:SetBuffer(var)
		elseif type(var) == "string" then
			resource.Download(var):Then(function(path)
				local file = vfs.Open(path)
				local data, length, info = audio.Decode(file, var)
				file:Close()

				if data then
					local buffer = audio.CreateBuffer()
					buffer:SetFormat(info.channels == 1 and al.e.FORMAT_MONO16 or al.e.FORMAT_STEREO16)
					buffer:SetSampleRate(info.samplerate)
					buffer:SetData(data, length)
					self:SetBuffer(buffer)
					self.decode_info = info
					self.ready = true

					-- in case it's instantly loaded and OnLoad is defined the same frame
					timer.Delay(0, function()
						if self:IsValid() then
							if self.OnLoad then self:OnLoad(info) end

							if self.play_when_ready then
								self:Play()
								self.play_when_ready = nil
							end
						end
					end)
				end
			end)
		end
	end, function(self)
		self:Stop()

		for _, v in pairs(self.effects) do
			if v.slot:IsValid() then v.slot:Remove() end
		end

		if self.Filter:IsValid() then self.Filter:Remove() end
	end)

	function META:IsReady()
		return self.ready
	end

	function META:Play()
		al.SourcePlay(self.id)

		if not self.ready then self.play_when_ready = true end
	end

	function META:Pause()
		al.SourcePause(self.id)
	end

	function META:Stop()
		al.SourceStop(self.id)
	end

	function META:Rewind()
		al.SourceRewind(self.id)
	end

	function META:IsPlaying()
		return self:GetState() == al.e.PLAYING
	end

	do -- length stuff
		function META:Seek(offset, type)
			if type ~= "samples" then
				offset = offset * self:GetBuffer():GetSampleRate()
			end

			self:SetSampleOffset(offset)
		end

		function META:Tell(type)
			if type == "samples" then
				return self:GetSampleOffset()
			else
				return self:GetSampleOffset() / self:GetBuffer():GetSampleRate()
			end
		end

		function META:GetLength()
			return select(2, self:GetBuffer():GetData())
		end

		function META:GetDuration()
			if self.decode_info then
				if self.decode_info.duration then
					return self.decode_info.duration
				elseif self.decode_info.frames then
					return tonumber(self.decode_info.frames) / self.decode_info.samplerate
				end
			end

			if self:GetBuffer():IsValid() then
				return tonumber(select(2, self:GetBuffer():GetData())) / self:GetBuffer():GetSampleRate()
			end

			return 0
		end
	end

	do
		META:GetSet("BufferCount", 4)
		META:GetSet("BufferFormat", al.e.FORMAT_STEREO16)
		local pushed = {}

		function META:PushBuffer(buffer)
			local buffers = ffi.new("unsigned int[1]")
			buffers[0] = buffer.id
			pushed[buffer.id] = buffer
			al.SourceQueueBuffers(self.id, 1, buffers)
		end

		function META:PopBuffer()
			local buffers = ffi.new("unsigned int[1]")
			al.SourceUnqueueBuffers(self.id, 1, buffers)
			return pushed[buffers[0]] or NULL
		end

		function META:FeedBuffer(buffer, length)
			if not self.pushed_feed_buffers or self.pushed_feed_buffers < self.BufferCount then
				local b = audio.CreateBuffer()
				b:SetFormat(self.BufferFormat)
				b:SetData(buffer, length)
				self:PushBuffer(b)
				self.pushed_feed_buffers = (self.pushed_feed_buffers or 0) + 1
			else
				local val = self:GetBuffersProcessed()

				for _ = 1, val do
					local b = self:PopBuffer()

					if b:IsValid() then
						b:SetData(buffer, length)
						self:PushBuffer(b)
					end
				end
			end

			if not self:IsPlaying() then self:Play() end
		end
	end

	do
		-- http://wiki.delphigl.com/index.php/alGetSource
		local ADD_FUNCTION = GET_BINDER(META, "Source")
		ADD_FUNCTION("SAMPLE_OFFSET", "i")
		ADD_FUNCTION("GAIN", "f")
		ADD_FUNCTION("LOOPING", "b")
		ADD_FUNCTION("MAX_GAIN", "f")
		ADD_FUNCTION("MAX_DISTANCE", "f")
		ADD_FUNCTION("REFERENCE_DISTANCE", "f")
		ADD_FUNCTION("ROLLOFF_FACTOR", "f")
		ADD_FUNCTION("PITCH", "f")
		ADD_FUNCTION("SOURCE_RELATIVE", "b")
		ADD_FUNCTION("SOURCE_STATE", "i")
		ADD_FUNCTION("SOURCE_TYPE", "i")
		ADD_FUNCTION("VELOCITY", "fv")
		ADD_FUNCTION("DIRECTION", "fv")
		ADD_FUNCTION("POSITION", "fv")
		ADD_FUNCTION("BYTE_OFFSET", "i")
		ADD_FUNCTION("BUFFERS_PROCESSED", "i")
		ADD_FUNCTION("BUFFERS_QUEUED", "i")
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "AuxiliaryEffectSlot", "iv", al.e.AUXILIARY_SEND_FILTER)
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "Buffer", "i", al.e.BUFFER)
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "Filter", "i", al.e.DIRECT_FILTER)
	end

	function META:GetBuffersQueuedLeft()
		return self:GetBuffersQueued() - self:GetBuffersProcessed()
	end

	do
		local old = META.SetPitch

		function META:SetPitch(num)
			if num < 0 then
				if not self.reverse_source then
					local data, size = self:GetBuffer():GetData()
					local buffer = ffi.new(ffi.typeof(data), size)
					local length = size

					for i = 0, tonumber(length) - 1 do
						buffer[i] = data[-i + length + 1]
					end

					self.reverse_source = audio.CreateSource(buffer, size)
				end

				if self:IsPlaying() then
					self.reverse_source:Play()
					self:Stop()
				end

				self.reverse_source:SetPitch(-num)
				return
			end

			old(self, num)
		end
	end

	function META:SetChannel(channel, ...)
		self:SetAuxiliaryEffectSlot(audio.GetEffectChannel(channel), ...)
	end

	function META:AddEffect(effect, id)
		id = id or effect
		self:RemoveEffect(id)
		local slot = audio.CreateAuxiliaryEffectSlot()
		slot:SetEffect(effect)
		effect.slots[id] = slot
		list.insert(self.effects, {id = id, slot = slot, effect = effect})
		self:SetAuxiliaryEffectSlot(slot, #self.effects)
	end

	function META:RemoveEffect(id)
		for i, v in pairs(self.effects) do
			if v.id == id then
				v.effect.slots[id] = nil
				v.slot:Remove()
				self:SetAuxiliaryEffectSlot(nil, i)
				list.remove(self.effects, i)

				break
			end
		end
	end

	META:Register()
end

do -- buffer
	local META = GEN_TEMPLATE("Buffer", function(self, data, size, format, sample_rate, start_loop, stop_loop)
		if data and size then
			if format then self:SetFormat(format) end

			if sample_rate then self:SetSampleRate(sample_rate) end

			if start_loop and stop_loop then
				self:SetLoopPoints(start_loop, stop_loop)
			end

			self:SetSize(size)
			self:SetData(data, size)
		end
	end)
	META:GetSet("Format", al.e.FORMAT_MONO16)
	META:GetSet("SampleRate", 44100)

	do
		-- http://wiki.delphigl.com/index.php/alGetBuffer
		local ADD_FUNCTION = GET_BINDER(META, "Buffer")
		ADD_FUNCTION("BITS", "i")
		ADD_FUNCTION("CHANNELS", "i")
		ADD_FUNCTION("FREQUENCY", "i")
		ADD_FUNCTION("SIZE", "i")
		ADD_FUNCTION("LOOP_POINTS", "iv")
	end

	function META:GetLength()
		return self:GetSize() * 8 / (self:GetChannels() * self:GetBits())
	end

	function META:GetDuration()
		return self:GetLength() / self:GetFrequency()
	end

	function META:SetData(data, size)
		al.BufferData(self.id, self.Format, data, size, self.SampleRate)
		self.buffer_data = {data, size}
	end

	function META:GetData()
		if self.buffer_data then return unpack(self.buffer_data) end

		return nil, nil
	end

	META:Register()
end

do -- effect
	local available = al.GetAvailableEffects()
	local META = GEN_TEMPLATE("Effect", function(self, var, override_params)
		self.slots = {}

		if available[var] then
			self:SetType(available[var].enum)
			self.params = table.copy(available[var].params)

			if override_params then
				for k, v in pairs(override_params) do
					self:SetParam(k, v)
				end
			else
				for _, v in pairs(self.params) do
					v.val = v.default
				end
			end
		else
			self:SetType(var)
		end
	end)

	do
		local ADD_FUNCTION = GET_BINDER(META, "Effect")
		ADD_FUNCTION("Type", "i", al.e.EFFECT_TYPE)
	end

	function META:BindToChannel(channel)
		audio.SetEffect(channel, self)
	end

	function META:UnbindFromChannel()
		audio.SetEffect(nil, self)
	end

	function META:GetParams()
		return self.params
	end

	META:Register()
end

do -- filter
	local available = al.GetAvailableFilters()
	local META = GEN_TEMPLATE("Filter", function(self, var, override_params)
		if available[var] then
			self:SetType(available[var].enum)
			self.params = table.copy(available[var].params)

			if override_params then
				for k, v in pairs(override_params) do
					self:SetParam(k, v)
				end
			else
				for _, v in pairs(self.params) do
					v.val = v.default
				end
			end
		else
			self:SetType(var)
		end
	end)

	do
		local ADD_FUNCTION = GET_BINDER(META, "Filter")
		ADD_FUNCTION("Type", "i", al.e.FILTER_TYPE)
	end

	META:Register()
end

do -- auxiliary effect slot
	local META = GEN_TEMPLATE("AuxiliaryEffectSlot", function(self, effect)
		if typex(effect) == "effect" then self:SetEffect(effect) end
	end)

	do
		local ADD_FUNCTION = GET_BINDER(META, "AuxiliaryEffectSlot")
		ADD_FUNCTION("EFFECTSLOT_GAIN", "f")
		ADD_SET_GET_OBJECT(META, ADD_FUNCTION, "Effect", "i", al.e.EFFECTSLOT_EFFECT)
	end

	function META:GetParams()
		return self.params
	end

	META:Register()
end

_G.Sound = audio.CreateSource

do -- microphone
	local META = prototype.CreateTemplate("audio_capture")

	function META:Start()
		alc.CaptureStart(self.id)
	end

	function META:Stop()
		alc.CaptureStop(self.id)
		self.stopped = true
	end

	function META:FeedSource(source)
		source:SetLooping(false)
		-- fill it with some silence first so we can pop safely (???)
		source:PushBuffer(audio.CreateBuffer(ffi.new("short[4]"), 4))

		timer.Thinker(function()
			if not self:IsValid() or self.stopped then return true end

			if self:IsFull() then
				local buffer = source:PopBuffer()

				if buffer:IsValid() then
					local data, size = self:Read()

					if self.OnBufferData then
						local a, b = self:OnBufferData(data, size)

						if a and b then
							data = a
							size = b
						end
					end

					buffer:SetData(data, size)
					source:PushBuffer(buffer)
				end
			end
		end)
	end

	local val = ffi.new("int[1]")

	function META:GetCapturedSamples()
		alc.GetIntegerv(self.id, alc.e.CAPTURE_SAMPLES, 1, val)
		return val[0]
	end

	function META:IsFull()
		return self:GetCapturedSamples() >= self.buffer_size
	end

	function META:Read()
		local size = self:GetCapturedSamples()
		local buffer = ffi.new("short[?]", size)
		alc.CaptureSamples(nil, buffer, size)
		return buffer, size
	end

	function META:OnRemove()
		alc.CaptureCloseDevice(self.id)
	end

	function audio.CreateAudioCapture(name, sample_rate, format, buffer_size)
		sample_rate = sample_rate or 44100
		format = format or al.e.FORMAT_MONO16
		buffer_size = buffer_size or 4096

		if not name then name = audio.GetAllInputDevices()[1] end

		llog("opening device %q for input", name)
		local self = META:CreateObject()
		self.buffer_size = buffer_size
		self.id = alc.CaptureOpenDevice(name, sample_rate, format, buffer_size)
		return self
	end

	META:Register()
end

runfile("decoding.lua", audio)
return audio