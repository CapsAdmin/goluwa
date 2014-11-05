local ffi_new = ffi.new or ffi.new_dbg_gc

local header = require("lj-ffmpeg.header")

ffi.cdef(header)  

local enums = require("lj-ffmpeg.enums")

header = header:gsub("%s+", " ")
header = header:gsub(";", "%1\n")

local ffmpeg = {
	libs = {
		avcodec = ffi.load("avcodec-56"),
		avformat = ffi.load("avformat-56"),
		avdevice = ffi.load("avdevice-56"),
		avutil = ffi.load("avutil-54"),
		swresample = ffi.load("swresample-1"),
		swscale = ffi.load("swscale-3"),
	},
	e = enums,
}

for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") then
		local name = line:match("(av.-)%s-%(") or line:match("(sw[rs]_.-)%s-%(")
		if name then
			for k,v in pairs(ffmpeg.libs) do
				local ok , err = pcall(function()
					ffmpeg[name] = v[name]
				end)
			end
			
			local func = ffmpeg[name]
			
			ffmpeg[name] = function(...)
				if ffmpeg.logcalls then
					setlogfile("ffmpeg_calls")
					logf("%s(%s)", name, table.concat(tostring_args(...), ",\t"))
				end
				
				local val = func(...)
				
				if ffmpeg.logcalls then
					logf(">> %s\n", serializer.GetLibrary("luadata").ToString(val))
					setlogfile()
				end
				
				return val
			end
		end
	end
end

function ffmpeg.lua_initialize()
	ffi.cdef[[int sprintf(char *str, const char *format, ...);]]

	ffmpeg.av_log_set_callback(function(huh, level, fmt, va_list)
		if not ffmpeg.debug then return end
		local buffer = ffi_new("char[256]")
		ffi.C.sprintf(buffer, fmt, va_list)
		log("[ffmpeg] ", ffi.string(buffer))
	end)

	ffmpeg.av_register_all() 
end

function ffmpeg.lua_table_to_dictionary(tbl)	
	local dict = ffi_new("AVDictionary *[1]")
	
	if not tbl then return dict[0] end
	
	for key, val in pairs(tbl) do
		ffmpeg.av_dict_set(dict, tostring(key), tostring(tonumber(val)), 0)
	end
	
	return dict[0]
end

function ffmpeg.lua_dictionary_to_table(dict)	
	local tbl = {}
	
	if dict == nil then return tbl end
	
	local entry = ffi_new("AVDictionaryEntry *")
	while true do 
		entry = ffmpeg.av_dict_get(dict, "", entry, enums.AV_DICT_IGNORE_SUFFIX)
		if entry == nil then break end
		local str = ffi.string(entry.value)
		tbl[ffi.string(entry.key)] = tonumber(str) or str
	end
	
	return tbl
end

local errors = {
	"bitstream filter not found",
	"internal bug, should not have happened",
	"internal bug, should not have happened",
	"buffer too small",
	"decoder not found",
	"demuxer not found",
	"encoder not found",
	"end of file",
	"immediate exit requested",
	"generic error in an external library",
	"filter not found",
	"invalid data found when processing input",
	"muxer not found",
	"option not found",
	"not yet implemented in ffmpeg, patches welcome",
	"protocol not found",
	"stream not found",
	"unknown error occurred",
	"experimental feature",
}

local last_err
local last_code

local function check_error(err)
	if err and errors[-err] then
		last_err = errors[-err]
		last_code = err
	end
	return err
end

local function get_last_error()
	if last_err then
		return last_err .. " (error code: " ..  last_code .. ")"
	end
	
	return "unknown error"
end

ffmpeg.lua_initialize()

do
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
			local format = config.audio_format or ffi.C.AV_SAMPLE_FMT_S16
			local sample_rate = config.sample_rate or 44100
			local channels = config.channels or 2
			
			local converter = ffi_new("SwrContext*[1]", ffmpeg.swr_alloc())
			
			--ffmpeg.av_opt_set(converter[0], "swr_flags", "res", 0)

			-- input config			
			local in_channel_layout = ffmpeg.av_get_channel_layout("mono")
			ffmpeg.av_opt_set_int(converter[0], "in_channel_layout", codec_context.channel_layout, 0 );
			ffmpeg.av_opt_set_sample_fmt(converter[0], "in_sample_fmt", codec_context.sample_fmt, 0)
			ffmpeg.av_opt_set_int(converter[0], "in_sample_rate", codec_context.sample_rate, 0)
			
			-- output config
			local out_channel_layout = ffmpeg.av_get_channel_layout(channels == 1 and "mono" or "stereo")
			ffmpeg.av_opt_set_int(converter[0], "out_channel_layout", out_channel_layout, 0)
			ffmpeg.av_opt_set_sample_fmt(converter[0], "out_sample_fmt", format, 0)
			ffmpeg.av_opt_set_int(converter[0], "out_sample_rate", sample_rate, 0)
			
			-- dunno what this is, i just took it from the source for swr_alloc_set_opts
			--ffmpeg.av_opt_set_int(converter[0], "uch", 0, 0)
					
			if config.flags then
				ffmpeg.av_opt_set_int(converter[0], "swr_flags", config.flags, 0);
			end
									
			if check_error(ffmpeg.swr_init(converter[0])) < 0 then
				
				if ffmpeg.debug then
					logn("in_channel_layout = ", in_channel_layout)
					logn("in_channels = ", codec_context.channels)
					logn("in_sample_rate = ", codec_context.sample_rate)
					logn("in_sample_fmt = ", codec_context.sample_fmt)

					logn("out_channel_layout = ", codec_context.channel_layout)
					logn("out_channels = ", channels)
					logn("out_sample_rate = ", sample_rate)
					logn("out_sample_fmt = ", format)
					
					logn("swr_flags = ", flags)
				end
				
				return nil, "failed to initialize the audio converter (swr): " .. get_last_error()
			end
				
			config.audio_format = format
			config.sample_rate = sample_rate
			config.channels = channels
					
			return converter
		elseif type == "video" then
			local format = config.video_format or ffi.C.AV_PIX_FMT_BGRA
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
			
			if check_error(ffmpeg.sws_init_context(converter, nil, nil)) < 0 then
				
				if ffmpeg.debug then
					logn("srcw = ", codec_context.width)
					logn("srch = ", codec_context.height)
					logn("src_format = ", codec_context.pix_fmt)
					
					logn("dstw = ", width)
					logn("dsth = ", height)
					logn("dst_format = ", format)
					
					logn("flags = ", flags)
				end
			
				return nil, "failed to initialize the video converter (sws): " .. get_last_error()
			end
			
			config.video_format = format
			config.width = width
			config.height = height
				
			return converter
		end
	end

	local META = prototype.CreateTemplate("decoder")

	local function insert_video_data(self, stream)
		-- rescale the video
		-- todo: do this later?
		if check_error(ffmpeg.sws_scale(
			stream.converter, 					
			ffi.cast("const uint8_t **", self.frame.data), 
			self.frame.linesize,
			0,
			stream.codec_context.height,					
			stream.image_buffer.data, 
			stream.image_buffer.linesize
		)) < 0 then
			return nil, "failed to rescale video frame: " .. get_last_error()
		end
		
		-- get the buffer
		--buffer = stream.image_buffer.data[0]
		local length = ffmpeg.av_image_get_buffer_size(self.config.video_format, self.config.width, self.config.height, 4)
		local buffer = ffi_new("uint8_t[?]", length)
		ffi.copy(buffer, stream.image_buffer.data[0], length)
			
		-- get the the timestamp for this frame
		local clock = ffmpeg.av_rescale_q(self.packet[0].pts, stream.stream.time_base, enums.AV_TIME_BASE_Q)
		
		table.insert(stream.queue, {
			buffer = buffer,
			time_stamp = clock,
		})
		
		return clock
	end

	local function insert_audio_data(self, stream)
		-- convert the audio

		local length = ffmpeg.av_samples_get_buffer_size(
			nil, 
			self.frame.channels, 
			self.frame.nb_samples, 
			self.config.audio_format, 
			1
		)
		
		if check_error(length) <= 0 then return nil, "failed to get sample buffer size: " .. get_last_error() end
		
		local buffer = ffi_new("uint8_t[?]", length)
		local box = ffi_new("uint8_t *[1]", buffer)
		
		if check_error(ffmpeg.swr_convert(
			stream.converter[0], 			
			box, 
			self.frame.nb_samples,			
			ffi.cast("const uint8_t **", self.frame.data), 
			self.frame.nb_samples
		)) < 0 then
			return nil, "failed to resample audio frame: " .. get_last_error()
		end

		-- get the the timestamp for this frame
		local clock							
		if self.packet[0].pts ~= enums.AV_NOPTS_VALUE then
			clock = ffmpeg.av_rescale_q(self.packet[0].pts, stream.stream.time_base, enums.AV_TIME_BASE_Q)
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
						local temp = ffi_new("AVSubtitle *")
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
			
			if bit.band(stream.codec.capabilities, enums.CODEC_CAP_DELAY) ~= 0 then
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
			local pos = ffmpeg.av_rescale_q(pos, enums.AV_TIME_BASE_Q, stream.stream.time_base)
			self.start_time = nil
			if ffmpeg.av_seek_frame(self.format_context[0], i, pos, enums.AVSEEK_FLAG_ANY) < 0 then
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
	
	prototype.Register(META)

	function ffmpeg.Open(data, config) 
		config = config or {}

		local file_name
		
		if #data < 512 and vfs.Exists(data) or data:find("://") then
			file_name = data
			config.file_ext = config.file_ext or data:match(".+%.(.+)")
		else
			-- make a dummy file
			-- ffmpeg doesn't like os.tmpname() names...
			file_name = os.tmpname()--lfs.currentdir() .. "\\" .. tostring(("%p"):format(data):gsub("%p", "")) .. "." .. config.file_ext
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
		local format_context = ffi_new("AVFormatContext *[1]", ffmpeg.avformat_alloc_context())
		local options = ffi_new("AVDictionary *[1]", ffmpeg.lua_table_to_dictionary(config.input_options))
		
		local format
		
		local format_name = ffmpeg.av_guess_format(nil, "temp." .. config.file_ext, nil)
		
		if format_name ~= nil then
			format = ffmpeg.av_find_input_format(format_name.name)
		end
		
		if config.file_ext and not format then
			return nil, "unknown format " .. config.file_ext
		end
		
		if check_error(ffmpeg.avformat_open_input(format_context, file_name, format, options)) ~= 0 then
			ffmpeg.av_free(frame)
			os.remove(file_name)
			return nil, "unable to open file " .. file_name .. ": " .. get_last_error()
		end
			
		-- find all the streams (audio streams, video streams, etc)
		if check_error(ffmpeg.avformat_find_stream_info(format_context[0], nil)) < 0 then
			ffmpeg.av_free(frame)
			ffmpeg.avformat_close_input(format_context)
			os.remove(file_name)
			return nil, "unable to find stream info: " .. get_last_error()
		end
		
		--ffmpeg.logcalls = true
		
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
			
			if codec == nil or check_error(ffmpeg.avcodec_open2(codec_context, codec, nil)) < 0 then
				streams[i] = {
					opened = false,
					reason = string.format("couldn't open the %s codec at stream position %i: %s\n", type, i, get_last_error()),
				}
			else
				local converter, err = get_converter(codec_context, type, config)
				if not converter then return nil, err end
				
				streams[i] = {
					opened = true,
					codec_context = codec_context,
					codec = codec,
					format_context = format_context,
					stream = stream,
					type = type,
					converter = converter,
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
					local buffer = ffi_new("uint8_t[?]", length)
					ffmpeg.avpicture_fill(ffi.cast("AVPicture *", image_buffer), buffer, config.video_format, config.width, config.height)

					streams[i].image_buffer = image_buffer
					streams[i].image_buffer_ref = buffer -- or it will crash!
				end
			end
			
			::continue::
		end	

		local self = prototype.CreateObject(META)
		
		self.frame_skips = 0 
		self.master_clock = 0
		self.frame = frame
		self.got_frame = ffi_new("int[1]")
		self.packet = ffi_new("AVPacket[1]") 
		self.streams = streams
		self.format_context = format_context
		self.config = config
		self.info = info
				
		return self
	end
end

return ffmpeg
