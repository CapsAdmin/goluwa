local render = ... or _G
render.texture_decoders = render.texture_decoders or {}

function render.AddTextureDecoder(id, callback)
	render.RemoveTextureDecoder(id)
	list.insert(render.texture_decoders, {id = id, callback = callback})
end

function render.RemoveTextureDecoder(id)
	for _, v in pairs(render.texture_decoders) do
		if v.id == id then
			list.remove(render.texture_decoders)
			return true
		end
	end
end

function render.DecodeTexture(data, path_hint)
	local errors = {"\n"}

	for _, decoder in ipairs(render.texture_decoders) do
		local ok, data, err = pcall(decoder.callback, data, path_hint)

		if ok then
			if data then
				return data
			elseif not err:lower():find("unknown format", nil, true) then
				list.insert(errors, "\t" .. decoder.id .. ": " .. err)
			end
		else
			list.insert(errors, "\tlua error: " .. data)
		end
	end

	return nil, list.concat(errors, "\n")
end