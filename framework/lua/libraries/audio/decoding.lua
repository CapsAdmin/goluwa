local audio = ... or _G.audio or {}

audio.decoders = audio.decoders or {}

function audio.AddDecoder(id, callback)
	audio.RemoveDecoder(id)
	table.insert(audio.decoders, {id = id, callback = callback})
end

function audio.RemoveDecoder(id)
	for _, v in pairs(audio.decoders) do
		if v.id == id then
			table.remove(audio.decoders)
			return true
		end
	end
end

function audio.Decode(file, path_hint, id)
	local errors = {}
	for _, decoder in ipairs(audio.decoders) do
		if not id or id == decoder.id then
			file:SetPosition(0)
			local ok, buffer, length, info = pcall(decoder.callback, file, path_hint)
			if ok then
				if buffer and length then
					return buffer, length, info or {}
				elseif buffer == nil then
					llog("%s failed to decode %s: %s", decoder.id, path_hint or "", length)
				elseif buffer == false then
					table.insert(errors, decoder.id .. ": " .. length)
				end
			else
				llog("decoder %q errored: %s", decoder.id, buffer)
			end
		end
	end
	llog("failed to decode ", path_hint, ":\n\t", table.concat(errors, "\n\t"))
end

runfile("decoders/*", audio)

return audio