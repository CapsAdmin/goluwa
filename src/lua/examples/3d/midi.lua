
local ffi = require"ffi"
local data = audio.MidiToTable("sounds/oot_zeldatheme.mid")
local sf2 = audio.SF2ToTable("sounds/LttPSF2.sf2")

local al = require("libal")
al.e.LOOP_POINTS = 0x2015 -- FIX ME
sf2.sdta.data = ffi.cast("uint16_t *", sf2.sdta.data)

local bank = {}

for i, sample in ipairs(sf2.pdta.shdr) do
	if sample.sample_name == "EOS" then break end

	local size = (sample.stop - sample.start)*2
	local buffer = ffi.new("uint16_t[?]", size)
	ffi.copy(buffer, sf2.sdta.data + sample.start, size)

	local albuffer = audio.CreateBuffer()
	albuffer:SetFormat(al.e.FORMAT_MONO16)
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
		if not track.init then
			track.voices = {}
			track.start_i = 1
			track.pitch_bend = 0
			track.volume = 1
			track.init = true
		end

		for i = track.start_i, #track.events do
			local v = track.events[i]

			if v.time then
				local time = (tonumber(v.time) / data.time_division) / 2.5
				if time > clock then break end

				if v.subtype == "program_change" then
					track.program = v.program_number-1
					track.start_i = 1
					track.volume = 1
				elseif v.subtype == "note_on" then
					track.voices[v.note_number] = track.voices[v.note_number] or create_source(track.program)

					local sound = track.voices[v.note_number]

					if not sound:IsPlaying() then
						sound:Play()
					end
					sound.last_event = v.subtype

					sound.pitch = 2 ^ (((sound.sample_info.original_pitch + v.note_number) - 24)/12) / 128

					sound.gain = (v.velocity/127) * 0.75

					sound:SetPitch(sound.pitch)
					sound:SetGain(sound.gain)
				elseif v.subtype == "note_off" then
					local sound = track.voices[v.note_number]

					if sound then
						sound:Stop()
						sound.last_event = v.subtype
					end
				elseif v.subtype == "pitch_bend" then
					for _, sound in pairs(track.voices) do
						sound:SetPitch(sound.pitch + (track.pitch_bend))
					end
				elseif v.subtype == "controller" then
					if v.controller_type == 7 then
						for _, sound in pairs(track.voices) do
							sound:SetGain(sound.gain * (v.value/127))
						end
					elseif v.controller_type == 10 then
						for _, sound in pairs(track.voices) do
							sound:SetPosition(0, (v.value-64)/64, 0)
						end
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