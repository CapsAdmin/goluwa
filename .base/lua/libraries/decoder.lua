local ffmpeg = include("libraries/low_level/ffi_binds/ffmpeg/init.lua")

local AVSEEK_FLAG_ANY = 4
local AV_TIME_BASE = 1000000
local AV_DICT_IGNORE_SUFFIX = 2
local AV_NOPTS_VALUE = ffi.cast("uint64_t", math.huge)
local AV_TIME_BASE_Q = ffi.new("AVRational", {num = 1, den = AV_TIME_BASE})
local CODEC_CAP_DELAY = 0x0020

local e = ffi.C

local stream_enum_translate = {
	[-1] = "unknown",
	[0] = "video",
	[1] = "audio",
	[2] = "data",
	[3] = "subtitle",
	[4] = "attachment",
	[5] = "nb",
}

ffi.cdef("void free(void *); void *malloc(size_t size);")

local function get_converter(codec_context, type, config)
	if type == "audio" then
		local format = config.audio_format or e.AV_SAMPLE_FMT_S16
		local sample_rate = config.sample_rate or 44100
		local channels = config.channels or 2
		
		local converter = ffi.new("SwrContext*[1]", ffmpeg.swr_alloc())
		
		-- input config
		local in_channel_layout = codec_context.channel_layout == 0 and ffmpeg.av_get_channel_layout(channels == 1 and "mono" or "stereo" ) or codec_context.channel_layout
		ffmpeg.av_opt_set_int(converter[0], "in_channel_layout", in_channel_layout, 0 );
		ffmpeg.av_opt_set_int(converter[0], "in_channels", codec_context.channels, 0)
		ffmpeg.av_opt_set_int(converter[0], "in_sample_rate", codec_context.sample_rate, 0)
		ffmpeg.av_opt_set_sample_fmt(converter[0], "in_sample_fmt", codec_context.sample_fmt, 0)
		
		-- output config
		ffmpeg.av_opt_set_int(converter[0], "out_channel_layout", codec_context.channel_layout, 0)
		ffmpeg.av_opt_set_int(converter[0], "out_channels", channels, 0)
		ffmpeg.av_opt_set_int(converter[0], "out_sample_rate", sample_rate, 0)
		ffmpeg.av_opt_set_sample_fmt(converter[0], "out_sample_fmt", format, 0)
				
		if flags then
			ffmpeg.av_opt_set_int(converter[0], "swr_flags", flags, 0);
		end
					
		if ffmpeg.swr_init(converter[0]) < 0 then
			return nil, "failed to initialize the audio converter (swr)"
		end
		
		config.audio_format = format
		config.sample_rate = sample_rate
		config.channels = channels
				
		return converter
	elseif type == "video" then
		local format = config.video_format or e.AV_PIX_FMT_BGRA
		local width = config.width or codec_context.width
		local height = config.height or codec_context.height
		
		local converter = ffmpeg.sws_alloc_context()
		
		-- input config
		ffmpeg.av_opt_set_int(converter, "srcw", codec_context.width, 0)
		ffmpeg.av_opt_set_int(converter, "srch", codec_context.height, 0)
		ffmpeg.av_opt_set_int(converter, "src_format", codec_context.pix_fmt, 0)

		-- output config
		ffmpeg.av_opt_set_int(converter, "dstw", width, 0)
		ffmpeg.av_opt_set_int(converter, "dsth", height, 0)
		ffmpeg.av_opt_set_int(converter, "dst_format", format, 0)

		if flags then
			converter.flags = flags
		end
		
		if ffmpeg.sws_init_context(converter, nil, nil) < 0 then
			return nil, "failed to initialize the video converter (sws)"
		end
		
		config.video_format = format
		config.width = width
		config.height = height
			
		return converter
	end
end

local META = utilities.CreateBaseMeta("decoder")

local function insert_video_data(self, stream)
	-- rescale the video
	-- todo: do this later?
	if ffmpeg.sws_scale(
		stream.converter, 					
		ffi.cast("const uint8_t **", self.frame.data), 
		self.frame.linesize,
		0,
		stream.codec_context.height,					
		stream.image_buffer.data, 
		stream.image_buffer.linesize
	) < 0 then
		return nil, "failed to rescale video frame"
	end
	
	-- get the buffer
	--buffer = stream.image_buffer.data[0]
	local length = ffmpeg.av_image_get_buffer_size(self.config.video_format, self.config.width, self.config.height, 4)
	local buffer = ffi.new("uint8_t[?]", length)
	ffi.copy(buffer, stream.image_buffer.data[0], length)
		
	-- get the the timestamp for this frame
	local clock = ffmpeg.av_rescale_q(self.packet[0].pts, stream.stream.time_base, AV_TIME_BASE_Q)
	
	table.insert(stream.queue, {
		buffer = buffer,
		time_stamp = clock,
	})
	
	return clock
end

local function insert_audio_data(self, stream)
	-- convert the audio
	local length = ffmpeg.av_samples_get_buffer_size(
		self.frame.linesize, 
		stream.codec_context.channels, 
		self.frame.nb_samples, 
		self.config.audio_format, 
		1
	)
	
	if length < 0 then return nil, "failed to get sample buffer size" end
	
	buffer = ffi.new("uint8_t *[1]", ffi.new("uint8_t[?]", length))
	
	if ffmpeg.swr_convert(
		stream.converter[0], 
		
		buffer, 
		length,
		
		ffi.cast("const uint8_t **", self.frame.data), 
		self.frame.nb_samples
	) < 0 then
		return nil, "failed to resample audio frame"
	end
	local buffer = buffer[0]
	
	-- get the the timestamp for this frame
	local clock							
	if self.packet[0].pts ~= AV_NOPTS_VALUE then
		clock = ffmpeg.av_rescale_q(self.packet[0].pts, stream.stream.time_base, AV_TIME_BASE_Q)
	else
		local sample_time = length
		sample_time = sample_time * 1000000ll
		sample_time = sample_time / self.config.channels
		sample_time = sample_time / self.config.sample_rate
		sample_time = sample_time / ffmpeg.av_get_bytes_per_sample(self.config.audio_format);
		stream.clock = (stream.clock or 0) + sample_time
	end
	
	table.insert(stream.queue, {
		buffer = buffer,
		length = length,
		time_stamp = clock,
	})
	
	return clock, length
end

local function read_frame(self, buffer_size)
	
	local audio_length = 0
	local master_clock
	
	local video_frames = 0
	local audio_frames = 0
	
	local done = false
	
	::continue::
			
	while (not buffer_size or audio_length < buffer_size) and ffmpeg.av_read_frame(self.format_context[0], self.packet) == 0 and self.packet[0].size > 0 do
		local stream = self.streams[self.packet[0].stream_index]
		
		if stream then
			if self.config.audio_only and (stream.type ~= "audio" or self.packet[0].size == 1) then goto continue end
			if self.config.video_only and (stream.type ~= "video" or self.packet[0].size == 1) then goto continue end
			
			if stream.converter and stream.opened then			
				if stream.type == "video" then
					while self.packet[0].size > 0 do 
						
						local length = ffmpeg.avcodec_decode_video2(stream.codec_context, self.frame, self.got_frame, self.packet)
						
						if self.got_frame[0] == 1 then 
							
							if length >= 0 then
								self.packet[0].size = self.packet[0].size - length
								self.packet[0].data = self.packet[0].data + length
								
								local clock, err = insert_video_data(self, stream)
								if not clock then return nil, err end
								
								master_clock = master_clock or clock
								video_frames = video_frames + 1
							else
								self.packet[0].size = 0
								self.packet[0].data = nil
								done = true
								break
							end
							if not buffer_size then done = true break end
						end							
					end
				elseif stream.type == "audio" then	
					while self.packet[0].size > 0 do 
						local length = ffmpeg.avcodec_decode_audio4(stream.codec_context, self.frame, self.got_frame, self.packet)
					
						if self.got_frame[0] ~= 1 then goto continue end
						
						if length >= 0 then
							self.packet[0].size = self.packet[0].size - length
							self.packet[0].data = self.packet[0].data + length
								
							local clock, decoded_length = insert_audio_data(self, stream)
							if not clock then return nil, decoded_length end
							
							master_clock = master_clock or clock
								
							audio_length = audio_length + decoded_length
							audio_frames = audio_frames + 1							
						else
							self.packet[0].size = 0
							self.packet[0].data = nil
							done = true
							break
						end						
					end
				elseif stream.type == "subtitle" then
					local temp = ffi.new("AVSubtitle *")
					if ffmpeg.avcodec_decode_subtitle2(stream.codec_context, temp, self.got_frame, self.packet) and self.got_frame[0] == 1 then						
						table.insert(stream.queue, {
							subtitles = temp,
							length = length,
							time_stamp = clock,
						})
					end
				end
			end
		end
		
		ffmpeg.av_free_packet(self.packet)
		
		if done then break end
	end

	for i, stream in pairs(self.streams) do
		ffmpeg.av_init_packet(self.packet)
		
		if bit.band(stream.codec.capabilities, CODEC_CAP_DELAY) ~= 0 then
			if stream.type == "video" then
				while ffmpeg.avcodec_decode_video2(stream.codec_context, self.frame, self.got_frame, self.packet) and self.got_frame[0] == 1 do
					local ok, err = insert_video_data(self, stream)
					if not ok then return err end
					video_frames = video_frames + 1
				end
			elseif stream.type == "audio" then
				while ffmpeg.avcodec_decode_audio4(stream.codec_context, self.frame, self.got_frame, self.packet) and self.got_frame[0] == 1 do
					local ok, err = insert_audio_data(self, stream)
					if not ok then return err end
					audio_frames = audio_frames + 1
				end
			end
		end
	end

	
	ffmpeg.av_free_packet(self.packet)
	
	--print(audio_frames, video_frames)
	
	self.master_clock = master_clock or 0
		
	return true
end
 
local function concatenate_queue(queue)
	local audio_buffer = {}
	
	for i = 1, math.huge do
		local data = table.remove(queue, 1)
		if not data then break end
		
		table.insert(audio_buffer, ffi.string(data.buffer, data.length))
	end
	
	local str = table.concat(audio_buffer, "")
	return ffi.cast("uint8_t *", str), #str
end

function META:Read(buffer_size)
	buffer_size = buffer_size or 4096*4
	self.start_time = self.start_time or ffmpeg.av_gettime()
	local cur_time = ffmpeg.av_gettime()
	local time = (cur_time - self.start_time)
	local reads = 0
	
	local audio_data
	local texture_buffer
	
	if self.config.video_only then	
		local ok, err = read_frame(self)
			
		if not ok then print(err) end
	else
		audio_data = {}
		if self.master_clock - time <= 0 then
			local ok, err = read_frame(self, buffer_size)
			
			if not ok then print(err) end
			
			for i, stream in pairs(self.streams) do
				if stream.type == "audio" then
					local buffer, length = concatenate_queue(stream.queue)
					table.insert(audio_data, {buffer = buffer, length = length})
				end
			end		
		end
	end
	
	if not self.config.audio_only then
		for i, stream in pairs(self.streams) do
			if stream.type == "subtitle" then
				--print()
			elseif stream.type == "video" then
				local data = stream.queue[1] 
								
				if data then
				
					if self.config.video_only then
						table.remove(stream.queue, 1)
						return data.buffer
					end						
					
					-- don't bother rendering it
					if #stream.queue > 3 then 
						table.remove(stream.queue, 1)
						self.frame_skips = self.frame_skips + 1
						return audio_data
					end
				
					if stream.last_remove and stream.last_remove > cur_time then 
						return audio_data
					end
					
					local next = 0
				
					if stream.queue[2] then
						next = stream.queue[2].time_stamp - data.time_stamp
					end
				
					table.remove(stream.queue, 1)
					
					stream.last_remove = cur_time + next
					
					texture_buffer = data.buffer
				end
			end
		end
	end
	
	return audio_data, texture_buffer
end

function META:ReadAll()
	return self:Read(math.huge)[1]
end

function META:GetCurrentTime()
	return self.clock
end

function META:Seek(pos)
	for i, stream in pairs(self.streams) do
		local pos = ffmpeg.av_rescale_q(pos, AV_TIME_BASE_Q, stream.stream.time_base)
		self.start_time = nil
		if ffmpeg.av_seek_frame(self.format_context[0], i, pos, AVSEEK_FLAG_ANY) < 0 then
			logf("could not seek the %s[i] stream", stream.type, i, 2)
		end
	end
end

function META:GetConfig()
	return self.config
end

function META:GetInfo()
	return self.info
end

function ffmpeg.Open(data, config)
	config = config or {}
		
	local file_name
	
	if #data < 512 and vfs.Exists(data) or data:find("://") then
		file_name = data
	else
		ffmpeg.logcalls = true
		-- make a dummy file
		-- ffmpeg doesn't like os.tmpname() names...
		file_name = lfs.currentdir() .. "\\" .. tostring(("%p"):format(data):gsub("%p", "")) .. "." .. config.file_ext
		local file = io.open(file_name, "wb")
		file:write(data)
		file:close()
	end
	
	local frame = ffmpeg.avcodec_alloc_frame()
	if frame == nil then
		os.remove(file_name)
		return nil, "error allocating frame"
	end
		 
	-- open the dummy file
	local format_context = ffi.new("AVFormatContext *[1]", ffmpeg.avformat_alloc_context())
	local options = ffi.new("AVDictionary *[1]", ffmpeg.lua_table_to_dictionary(config.input_options))
	
	if ffmpeg.avformat_open_input(format_context, file_name, ffmpeg.av_find_input_format(config.file_format), options) ~= 0 then
		ffmpeg.av_free(frame)
		os.remove(file_name)
		return nil, "unable to open file " .. file_name
	end
		
	-- find all the streams (audio streams, video streams, etc)
	if ffmpeg.avformat_find_stream_info(format_context[0], nil) < 0 then
		ffmpeg.av_free(frame)
		ffmpeg.avformat_close_input(format_context)
		os.remove(file_name)
		return nil, "unable to find stream info"
	end
	
	local info = {}
	
	-- try to open all the codecs
	local streams = {}
	
	for i = 0, format_context[0].nb_streams-1 do
		local stream = format_context[0].streams[i]
		local codec_context = stream.codec
		
		local codec = ffmpeg.avcodec_find_decoder(codec_context.codec_id)
		local type = stream_enum_translate[tonumber(codec_context.codec_type)]
		
		if config.audio_only and type ~= "audio" then goto continue end
		if config.video_only and type ~= "video" then goto continue end
		
		if codec == nil or ffmpeg.avcodec_open2(codec_context, codec, nil) < 0 then
			streams[i] = {
				opened = false,
				reason = string.format("couldn't open the %s codec at stream position %i\n", type, i),
			}
		else
			streams[i] = {
				opened = true,
				codec_context = codec_context,
				codec = codec,
				format_context = format_context,
				stream = stream,
				type = type,
				converter = get_converter(codec_context, type, config),
				metadata = ffmpeg.lua_dictionary_to_table(stream.metadata),
				queue = {},
			}
			
			if type == "audio" then
				info[type] = {
					channels = codec_context.channels,
					samplerate = codec_context.sample_rate,
					format = ffi.string(ffmpeg.av_get_sample_fmt_name(codec_context.sample_fmt)),
					channel_layout = codec_context.channel_layout,
					duration = tonumber(stream.duration) / (tonumber(stream.time_base.num) / tonumber(stream.time_base.den)),
				}
			end
			
			if streams[i].converter and type == "video" then
				-- missing config parameters are filled by get_converter
				
				local image_buffer = ffmpeg.avcodec_alloc_frame()
				local length = ffmpeg.avpicture_get_size(config.video_format, config.width, config.height)
				local buffer = ffi.new("uint8_t[?]", length)
				ffmpeg.avpicture_fill(ffi.cast("AVPicture *", image_buffer), buffer, config.video_format, config.width, config.height)

				streams[i].image_buffer = image_buffer
				streams[i].image_buffer_ref = buffer -- or it will crash!
			end
		end
		
		::continue::
	end	

	local self = setmetatable({}, META)
	
	self.frame_skips = 0 
	self.master_clock = 0
	self.frame = frame
	self.got_frame = ffi.new("int[1]")
	self.packet = ffi.new("AVPacket[1]") 
	self.streams = streams
	self.format_context = format_context
	self.config = config
	self.info = info
	
	os.remove(file_name)
	
	return self
end