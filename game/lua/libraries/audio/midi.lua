local audio = _G.audio or ...

local ffi = require("ffi")

do
	local frame_rate_flags = {
		[0x00] = 24,
		[0x20] = 25,
		[0x40] = 29,
		[0x60] = 30,
	}

	function audio.MidiToTable(path)
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

			local time = 0ULL

			for _ = 1, 1000000 do
				local event = {}

				time = time + file:ReadVarInt()
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
								error("Expected length for midi_channel_prefix event is 1, got " .. length)
							end
							event.channel = file:ReadByte();
						elseif sub_type == 0x2f then
							--event.subtype = "end_of_track"
							if length ~= 0 then
								error("Expected length for end_of_track event is 0, got " .. length)
							end
							break
						elseif sub_type == 0x51 then
							track.set_tempo = bit.lshift(file:ReadByte(), 16) + bit.lshift(file:ReadByte(), 8) + file:ReadByte()
							if length ~= 3 then
								error("Expected length for set_tempo event is 3, got " .. length)
							end
						elseif sub_type == 0x54 then
							track.smpte_offset = {}
							if length ~= 5 then
								error("Expected length for smpte_offset event is 5, got " .. length)
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
							track.time_signature.thirty_seconds = file:ReadByte()
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
						local length = file:ReadVarInt()
						event.data = file:ReadBytes(length)
					elseif event_type == 0xf7 then
						event.type = "divided_sysex"
						local length = file:ReadVarInt()
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
					event.time = time

					local event_type = bit.rshift(event_type, 4)

					if event_type == 0x08 then
						event.subtype = "note_off"
						event.note_number = param1
						event.velocity = file:ReadByte()
					elseif event_type == 0x09 then
						event.note_number = param1
						event.velocity = file:ReadByte()
						if event.velocity == 0 then
							event.subtype = "note_off"
						else
							event.subtype = "note_on"
						end
					elseif event_type == 0x0a then
						event.subtype = "note_aftertouch"
						event.note_number = param1
						event.amount = file:ReadByte()
					elseif event_type == 0x0b then
						event.subtype = "controller"
						event.controller_type = param1
						event.value = file:ReadByte()
					elseif event_type == 0x0c then
						event.subtype = "program_change"
						event.program_number = param1
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

do
	local function mod_bits_to_table(mod_bits)
		return {
			type = bit.rshift(mod_bits, 10),
			p = bit.band(bit.rshift(mod_bits, 9), 1),
			d = bit.band(bit.rshift(mod_bits, 9), 1),
			cc = bit.band(bit.rshift(mod_bits, 7), 1),
			index = bit.band(mod_bits, 0x3f),
		}
	end

	function audio.SF2ToTable(path)
		local sf2 = vfs.Open(path)

		sf2:ReadStructure([[
			string magic[4] = RIFF;
			unsigned int size;
			string magic2[4] = sfbk;
		]])

		local out = {}

		-- list
		for _ = 1, 3 do
			local header = sf2:ReadStructure([[
				string magic[4] = LIST;
				unsigned int size;
				char type[4];
			]])

			local the_end = sf2:GetPosition() + header.size - 4

			local chunk = {}

			for _ = 1, 1024 do
				if sf2:GetPosition() >= the_end then break end

				local id = sf2:ReadBytes(4)
				local size = sf2:ReadLong()

				local the_end = sf2:GetPosition() + size

				if id == "ifil" then
					chunk.version = sf2:ReadShort() .. "." .. sf2:ReadShort()
				elseif id == "INAM" then
					chunk.name = sf2:ReadString(size, true)
				elseif id == "isng" then
					chunk.engine = sf2:ReadString(size, true)
				elseif id == "IENG" then
					chunk.engineers = sf2:ReadString(size, true)
				elseif id == "ISFT" then
					chunk.tools = sf2:ReadString(size, true)
				elseif id == "ICMT" then
					chunk.comments = sf2:ReadString(size, true)
				elseif id == "ICOP" then
					chunk.copyright = sf2:ReadString(size, true)
				elseif id == "smpl" then
					chunk.data =  ffi.cast("uint8_t *", sf2:ReadBytes(size))
					chunk.size = size
				elseif id == "phdr" then
					local list = {}

					repeat
						local info = {}
						info.preset_name = sf2:ReadString(20, true)
						info.preset = sf2:ReadShort()
						info.bank = sf2:ReadShort()
						info.preset_bag_index = sf2:ReadShort()
						info.library = sf2:ReadLong()
						info.genre = sf2:ReadLong()
						info.morphology_genre = sf2:ReadLong()
						table.insert(list, info)
					until sf2:GetPosition() >= the_end

					chunk.phdr = list
				elseif id == "pbag" then
					local list = {}

					repeat
						local info = {}
						info.gen_index = sf2:ReadShort()
						info.mod_index = sf2:ReadShort()
						table.insert(list, info)
					until sf2:GetPosition() >= the_end

					chunk.pbag = list
				elseif id == "pmod" then
					sf2:Advance(size)
				elseif id == "iver" then
					sf2:Advance(size)
				elseif id == "IPRD" then
					sf2:Advance(size)
				elseif id == "ICRD" then
					sf2:Advance(size)
				elseif id == "irom" then
					sf2:Advance(size)
				elseif id == "imod" then
					local list = {}

					repeat
						local info = {}

						info.mod_src_oper = mod_bits_to_table(sf2:ReadShort())

						info.mod_dest_oper = sf2:ReadShort()
						info.mod_amount = sf2:ReadShort()
						info.mod_amt_src_oper = mod_bits_to_table(sf2:ReadShort())

						info.mod_trans_oper = sf2:ReadShort()
						table.insert(list, info)
					until sf2:GetPosition() >= the_end

					chunk.imod = list
				elseif id == "pgen" then
					sf2:Advance(size)
				elseif id == "igen" then
					local list = {}

					repeat
						local gen = {}
						local gen_operator = sf2:ReadShort()

						gen.operator = gen_operator

						if gen_operator == 43 or gen_operator == 44 then
							gen.lo = sf2:ReadByte()
							gen.hi = sf2:ReadByte()
						else
							gen.amount = sf2:ReadShort()
						end

						table.insert(list, gen)
					until sf2:GetPosition() >= the_end

					chunk.igen = list
				elseif id == "inst" then
					local list = {}

					repeat
						local info = {}
						info.instrument_name = sf2:ReadString(20, true)
						info.instrument_bag_index = sf2:ReadShort()
						table.insert(list, info)
					until sf2:GetPosition() >= the_end

					chunk.inst = list

				elseif id == "ibag" then
					local list = {}

					repeat
						local info = {}
						info.GenNdx = sf2:ReadShort()
						info.ModNdx = sf2:ReadShort()
						table.insert(list, info)
					until sf2:GetPosition() >= the_end

				   chunk.ibag = list
				elseif id == "shdr" then
					local list = {}
					repeat
						local info = {}
						info.sample_name = sf2:ReadString(20, true)

						info.start = sf2:ReadUnsignedLong()
						info.stop = sf2:ReadUnsignedLong()

						info.start_loop = sf2:ReadLong()
						info.stop_loop = sf2:ReadLong()

						info.sample_rate = sf2:ReadLong()
						info.original_pitch = sf2:ReadByte()
						info.pitch_correction = sf2:ReadByte()
						info.sample_link = sf2:ReadShort()
						info.sample_type = sf2:ReadShort()
						table.insert(list, info)
					until sf2:GetPosition() >= the_end

					chunk.shdr = list
				else
					break
				end
			end

			out[header.type] = chunk
		end

		return out
	end
end