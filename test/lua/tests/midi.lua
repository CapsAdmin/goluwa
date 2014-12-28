local data = utility.MidiToTable("sounds/hyrule.mid")
local sf2 = utility.SF2ToTable("sounds/zelda.sf2")

local al = require("lj-openal.al")
sf2.sdta.data = ffi.cast("uint16_t *", sf2.sdta.data)

local bank = {}

for i, sample in ipairs(sf2.pdta.shdr) do
	if sample.sample_name == "EOS" then break end
		
	local size = (sample.stop - sample.start)*2
	local buffer = ffi.new("uint16_t[?]", size)
	ffi.copy(buffer, sf2.sdta.data + sample.start, size)
	
	local albuffer = audio.CreateBuffer()
	albuffer:SetFormat(al.e.AL_FORMAT_MONO16)
	albuffer:SetSampleRate(sample.sample_rate)
	albuffer:SetData(buffer, size)
	albuffer.buffer = buffer
	
	local a, b = sample.start_loop - sample.start, sample.stop_loop - sample.start
	albuffer:SetLoopPoints(a, b) 
		
	local inst = sf2.pdta.phdr[i]
	if inst then
		bank[inst.preset] = sample
	end
	
	sample.albuffer = albuffer
end

local function create_source(index)
	local sample = bank[index] or sf2.pdta.shdr[1]
		
	local source = audio.CreateSource()
	source:SetBuffer(sample.albuffer)
	source:SetLooping(true)
	source.sample_info = sample
	
	source:Play()
	source:SetGain(0)
		
	return source
end

local clock = -1

event.AddListener("Update", "asdf", function(dt)
	for _, track in ipairs(data.tracks) do	
		if not track.sound then
			local sound = create_source(_)
			track.sound = sound
			
			track.start_i = 1
			track.pitch_bend = 0
			track.volume = 1
		end
		
		for i = track.start_i, #track.events do
			local v = track.events[i]
			
			if v.time then
				local time = (tonumber(v.time) / data.time_division) / 2.5
				if time > clock then break end
				
				if v.subtype == "program_change" then
					track.sound:Remove()
					local sound = create_source(v.program_number-1)
					track.sound = sound
				elseif v.subtype == "note_on" then
					
					if track.sound.last_event ~= v.subtype then
						track.sound:Play()
						track.sound.last_event = v.subtype
					end

					track.sound:SetPitch((2 ^ (((track.sound.sample_info.original_pitch + v.note_number) - 24 + (track.pitch_bend * 8))/12) / 128))
					track.sound:SetGain((v.velocity/127) * track.volume * 0.75)
					track.pitch_bend = 0
					
				elseif v.subtype == "note_off" then 
					track.sound:Stop()
					track.sound.last_event = v.subtype					
				elseif v.subtype == "pitch_bend" then
					track.pitch_bend = (v.value/16383)
				elseif v.subtype == "controller" then
					if v.controller_type == 7 then
						track.volume = v.value/127
					elseif v.controller_type == 10 then
						track.sound:SetPosition(0, (v.value-64)/64, 0)
					else
					--	table.print(v)
					end
				else
					table.print(v)
				end
				
				track.start_i = i
			end
		end
	end
	
	clock = clock + dt
end)