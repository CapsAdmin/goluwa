local ffmpeg = include("libraries/low_level/ffi_binds/ffmpeg/init.lua")

local INBUF_SIZE = 4096
local AUDIO_INBUF_SIZE = 20480
local AUDIO_REFILL_THRESH = 4096
local FF_INPUT_BUFFER_PADDING_SIZE = 16
local CODEC_CAP_DELAY = 0x0020
local AV_CH_LAYOUT_STEREO = 3
local AV_CH_LAYOUT_MONO = 0x00000004

local e = ffi.C

local out_sample_fmt = e.AV_SAMPLE_FMT_S16            
local out_channels = 2 
local out_sample_rate = 44100

local audio_chunk

local dbg = function() end
   
ffmpeg.av_register_all() 
ffmpeg.avcodec_register_all() 

audio.AddDecoder("ffmpeg", function(data, length, path_hint)
	local buffer_out = {}
		
	-- make a dummy file
	local temp_name = os.tmpname()
	local file = io.open(temp_name, "wb")
	file:write(data)
	file:close()
	
	dbg("created file")

	local frame = ffmpeg.avcodec_alloc_frame()--ffi.new("AVFrame[1]")
	if frame == nil then
		return nil, "error allocating the frame"
	end
	
	dbg("allocated frame")
	 
	-- open the dummy file
	local format_context = ffi.new("AVFormatContext*[1]", ffmpeg.avformat_alloc_context())
	if ffmpeg.avformat_open_input(format_context, temp_name, nil, nil) ~= 0 then
		ffmpeg.av_free(frame)
		return nil, "could not open the file"
	end
	
	dbg("opened dummy file")
	
	-- figure out the format
	local codec = ffi.new("AVCodec*[1]", ffi.new("AVCodec*"))
	if ffmpeg.avformat_find_stream_info(format_context[0], nil) < 0 then
		ffmpeg.av_free(frame)
		ffmpeg.avformat_close_input(format_context)
		return nil, "error finding the stream info"
	end
	
	dbg("found stream info")
	
	-- find the audio stream
	local stream_index = ffmpeg.av_find_best_stream(format_context[0], e.AVMEDIA_TYPE_AUDIO, -1, -1, codec, 0)
	
	if stream_index < 0 then
		ffmpeg.av_free(frame)
		ffmpeg.avformat_close_input(format_context)
		return nil, "could not find any audio stream in the file"
	end
	
	dbg("found audio stream")
	
	local audio_stream = format_context[0].streams[stream_index]
	local codec_context = audio_stream.codec
	codec_context.codec = codec[0]
	codec_context.request_sample_fmt = out_sample_fmt
	
	if ffmpeg.avcodec_open2(codec_context, codec_context.codec, nil) < 0 then
		ffmpeg.av_free(frame)
		ffmpeg.avformat_close_input(format_context)
		return nil, "couldn't open the context with the decoder"
	end
	
	dbg("opened decoder")
	
	local info = {}
	info.channels = codec_context.channels
	info.samplerate = codec_context.sample_rate
	info.format = ffi.string(ffmpeg.av_get_sample_fmt_name(codec_context.sample_fmt))
	info.channel_layout = codec_context.channel_layout
	
	local swr_ctx = ffi.new("SwrContext*[1]", ffmpeg.swr_alloc())
					
	ffmpeg.av_opt_set_int(swr_ctx[0], "in_channel_layout", codec_context.channel_layout, 0)
	
	if codec_context.channel_layout == 0 then
		ffmpeg.av_opt_set_int(swr_ctx[0], "in_channel_layout",	ffmpeg.av_get_channel_layout(out_channels == 1 and "mono" or "stereo" ), 0 );
	else
		ffmpeg.av_opt_set_int(swr_ctx[0], "in_channel_layout",	codec_context.channel_layout, 0 );
	end
	
	ffmpeg.av_opt_set_int(swr_ctx[0], "in_channels", codec_context.channels, 0)
	ffmpeg.av_opt_set_int(swr_ctx[0], "in_sample_rate", codec_context.sample_rate, 0)
	ffmpeg.av_opt_set_sample_fmt(swr_ctx[0], "in_sample_fmt", codec_context.sample_fmt, 0)
	
	ffmpeg.av_opt_set_int(swr_ctx[0], "out_channels", codec_context.channels, 0)
	ffmpeg.av_opt_set_int(swr_ctx[0], "out_channel_layout", codec_context.channel_layout, 0)
	ffmpeg.av_opt_set_int(swr_ctx[0], "out_sample_rate", codec_context.sample_rate, 0)
	ffmpeg.av_opt_set_sample_fmt(swr_ctx[0], "out_sample_fmt", out_sample_fmt, 0)
	
	local ret = ffmpeg.swr_init(swr_ctx[0])
	
	dbg("initialized resampler")
	
	if ret < 0 then
		return nil, "failed to initialize the resampling context"
	end
		
	local packet = ffi.new("AVPacket[1]")
	ffmpeg.av_init_packet(packet)
			 
	while ffmpeg.av_read_frame(format_context[0], packet) == 0 do
		dbg("read frame")
		
		if packet[0].stream_index == audio_stream.index then		
			while packet[0].size > 0 do
				local got_frame = ffi.new("int[1]")
				local result = ffmpeg.avcodec_decode_audio4(codec_context, frame, got_frame, packet)

				if result >= 0 and got_frame[0] == 1 then
					
					dbg("found frame")
					
					packet[0].size = packet[0].size - result
					packet[0].data = packet[0].data + result
										
					local length = ffmpeg.av_samples_get_buffer_size(nil, codec_context.channels, frame.nb_samples, out_sample_fmt, 1)
					local buffer = ffi.new("uint8_t*[1]", ffi.new("uint8_t[?]", length))
					
					local ret = ffmpeg.swr_convert(
						swr_ctx[0], 
						
						buffer, 
						length,
						
						ffi.cast("const uint8_t **", frame.data), 
						frame.nb_samples
					)
					
					if ret < 0 then		
						ffmpeg.av_free(frame)
						ffmpeg.avcodec_close(codec_context)
						ffmpeg.avformat_close_input(format_context)
						return nil, ffmpeg.get_last_error()
					end
										
					table.insert(buffer_out, ffi.string(buffer[0], length))
				else
					packet[0].size = 0
					packet[0].data = nil
				end
			end
		end
		
		ffmpeg.av_free_packet(reading_packet)
	end
	 
	if bit.band(codec_context.codec.capabilities, CODEC_CAP_DELAY) ~= 0 then
		ffmpeg.init_packet(reading_packet)
		
		local got_frame = ffi.new("int[1]")
		while ffmpeg.decode_audio4(codec_context, frame, got_frame, reading_packet) >= 0 and got_frame[0] == 1 do
			print("????")
			break
		end
	end
	
	ffmpeg.av_free(frame)
	ffmpeg.avcodec_close(codec_context)
	ffmpeg.avformat_close_input(format_context)
	ffmpeg.swr_free(swr_ctx) 
	
	local str = table.concat(buffer_out, "")
	
	local len = #str
	local buffer = ffi.cast("uint8_t*", str)
		
	info.frames = len
		
	return buffer, len, info
end)