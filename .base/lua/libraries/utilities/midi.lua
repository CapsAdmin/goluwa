local utility = _G.utility or ...

do
	local frame_rate_flags = {
		[0x00] = 24, 
		[0x20] = 25, 
		[0x40] = 29, 
		[0x60] = 30,
	}

	function utility.MidiToTable(path)
		local file = vfs.Open(path)

		local midi = file:ReadStructure([[
			string header_id[4] = MThd;
			swap unsigned long header_size = 6;
			
			swap unsigned short format_type;
			swap unsigned short track_count;
			swap unsigned short time_division;
		]])

		midi.tracks = {}

		local last_event_type

		for i = 1, midi.track_count do	
			local info = file:ReadStructure([[
				string track_id[4] = MTrk;
				swap unsigned long track_size;
			]])
			
			info.track_size = file:GetPosition() + info.track_size 
			
			local track = {}
			track.events = {}
				
			for i = 1, 1000000 do		
				local event = {}
						
				local delta_time = file:ReadVarInt()
				local event_type = file:ReadByte()
				
				if bit.band(event_type, 0xf0) == 0xf0 then
					if event_type == 0xff then							
						local sub_type = file:ReadByte()
						local length = file:ReadVarInt()
									
						if sub_type == 0x00 then
							track.sequence_number = file:ReadInt()
						elseif sub_type == 0x01 then
							track.text = file:ReadBytes(length)
						elseif sub_type == 0x02 then
							track.copyright_notice = file:ReadBytes(length)
						elseif sub_type == 0x03 then
							track.track_name = file:ReadBytes(length)
						elseif sub_type == 0x04 then
							track.insrument_name = file:ReadBytes(length)
						elseif sub_type == 0x05 then
							track.lyrics = file:ReadBytes(length)
						elseif sub_type == 0x06 then
							track.marer = file:ReadBytes(length)
						elseif sub_type == 0x07 then
							track.cueoint = file:ReadBytes(length)
						elseif sub_type == 0x20 then
							event.subtype = "midi_channel_prefix"
							if length ~= 1 then 
								error("Expected length for midiChannelPrefix event is 1, got " .. length) 
							end
							event.channel = file:ReadByte();
						elseif sub_type == 0x2f then
							--event.subtype = "end_of_track"
							if length ~= 0 then 
								error("Expected length for endOfTrack event is 0, got " .. length) 
							end
							break
						elseif sub_type == 0x51 then
							track.set_tempo = bit.lshift(file:ReadByte(), 16) + bit.lshift(file:ReadByte(), 8) + file:ReadByte()
							if length ~= 3 then 
								error("Expected length for setTempo event is 3, got " .. length) 
							end
						elseif sub_type == 0x54 then
							track.smpte_offset = {}
							if length ~= 5 then 
								error("Expected length for smpteOffset event is 5, got " .. length) 
							end
							local hour_byte = file:ReadByte()
							track.smpte_offset.frame_rate = frame_rate_flags[bit.band(hour_byte, 0x60)]
							track.smpte_offset.hour = bit.band(hour_byte, 0x1f)
							track.smpte_offset.min = file:ReadByte()
							track.smpte_offset.sec = file:ReadByte()
							track.smpte_offset.frame = file:ReadByte()
							track.smpte_offset.subframe = file:ReadByte()
						elseif sub_type == 0x58 then
							track.time_signature = {}
							if length ~= 4 then 
								error("Expected length for timeSignature event is 4, got " .. length) 
							end
							track.time_signature.numerator = file:ReadByte()
							track.time_signature.denominator = file:ReadByte() ^ 2
							track.time_signature.metronome = file:ReadByte()
							track.time_signature.thirtyseconds = file:ReadByte()
						elseif sub_type == 0x59 then
							track.key_signature = {}
							if length ~= 2 then 
								error("Expected length for keySignature event is 2, got " .. length) 
							end
							track.key_signature.key = file:ReadByte(true)
							track.key_signature.scale = file:ReadByte()
						elseif sub_type == 0x7f then
							track.sequencer_specific = file:ReadBytes(length)
						else
							track.unknown = file:ReadBytes(length)
						end
					elseif event_type == 0xf0 then
						event.type = "sysex"
						local length = file:readVarInt()
						event.data = file:ReadBytes(length)
					elseif event_type == 0xf7 then
						event.type = "divided_sysex"
						local length = file:readVarInt()
						event.data = file:ReadBytes(length)
					else
						error("Unrecognised MIDI event type byte: " .. event_type)
					end
				else
					local param1
					
					if bit.band(event_type, 0x80) == 0 and last_event_type then
						param1 = event_type
						event_type = last_event_type
					else
						param1 = file:ReadByte()
						last_event_type = event_type
					end		
					
					track.channel = bit.band(event_type, 0x0f)
					
					local event = {}

					local event_type = bit.rshift(event_type, 4)
					
					if event_type == 0x08 then
						event.subtype = "note_off"
						event.noteNumber = param1
						event.velocity = file:ReadByte()
					elseif event_type == 0x09 then
						event.noteNumber = param1
						event.velocity = file:ReadByte()
						if event.velocity == 0 then
							event.subtype = "note_off"
						else
							event.subtype = "note_on"
						end
					elseif event_type == 0x0a then
						event.subtype = "note_aftertouch"
						event.noteNumber = param1;
						event.amount = file:ReadByte()
					elseif event_type == 0x0b then
						event.subtype = "controller"
						event.controllerType = param1
						event.value = file:ReadByte()
					elseif event_type == 0x0c then
						event.subtype = "program_change"
						event.programNumber = param1;
					elseif event_type == 0x0d then
						event.subtype = "channel_aftertouch"
						event.amount = param1;
					elseif event_type == 0x0e then
						event.subtype = "pitch_bend"
						event.value = param1 + bit.lshift(file:ReadByte(), 7)
					else
						error("Unrecognised MIDI event type: " .. event_type)
					end
					
					table.insert(track.events, event)
				end
				
				if next(event) then
					events[i] = event
				end
				
				if file:GetPosition() >= info.track_size then 
					break
				end
			end
			
			midi.tracks[i] = track
		end

		midi.header_id = nil
		midi.header_size = nil
		midi.track_count = nil

		-- if the first track is just info merge it with the root table
		if not midi.tracks[1].events[1] then
			midi.tracks[1].events = nil
			table.merge(midi, midi.tracks[1])
			table.remove(midi.tracks, 1)
		end

		return midi
	end
end