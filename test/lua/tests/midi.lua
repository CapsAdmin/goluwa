local data = utility.MidiToTable("C:/Windows/Media/onestop.mid")
local sf2 = utility.SF2ToTable("C:/Users/caps/Pictures/zelda.sf2")
	
local function create_source(index)
	local sample = sf2.pdta.shdr[index]
	
	local buffer = audio.CreateBuffer()		
	buffer:SetData(sf2.sdta.data, sf2.sdta.size)
	buffer:SetLoopPoints(sample.start_loop, sample.stop_loop) 
	
	local source = audio.CreateSource()
	source:SetBuffer(buffer) 
	source:SetLooping(true)
	source:SetSampleOffset(sample.start)
	source.sample_info = sample
		
	return source
end

local clock = -1

event.AddListener("Update", "asdf", function(dt)
	for _, track in ipairs(data.tracks) do
	
		if not track.sound then
			local sound = create_source(_)

			sound:Play()
			sound:SetGain(0)
			
			track.start_i = 1
			track.sound = sound
			track.pitch_bend = 0
		end
		
		for i = track.start_i, #track.events do
			local v = track.events[i]
			
			if v.time then
				local time = (tonumber(v.time) / data.time_division / 2)
				if time > clock then break end
				
				if v.subtype == "program_change" then

				elseif v.subtype == "note_on" then
					track.sound:SetPitch((2 ^ ((v.note_number + track.sound.sample_info.original_pitch - (12*3))/12)/ 127) + track.pitch_bend)
					track.sound:SetGain(v.velocity/128)
					track.pitch_bend = 0
				elseif v.subtype == "note_off" then 
					track.sound:SetGain(0)
				elseif v.subtype == "pitch_bend" then
					track.pitch_bend = v.value/16000
				elseif v.subtype == "controller" then
					
				else
					table.print(v)
				end
				
				track.start_i = i
			end
		end
	end
	
	clock = clock + dt
end)