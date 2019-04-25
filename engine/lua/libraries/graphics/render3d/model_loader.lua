local render3d = ... or _G.render3d

render3d.model_decoders = render3d.model_decoders or {}

function render3d.AddModelDecoder(id, callback, ext)
	render3d.RemoveModelDecoder(id)
	if ext == false then
		ext = ""
	else
		ext = "." .. id
	end
	table.insert(render3d.model_decoders, {id = id, ext = ext, callback = callback})
	table.sort(render3d.model_decoders, function(a, b) return #a.ext > #b.ext end)
end

function render3d.RemoveModelDecoder(id)
	for i, v in ipairs(render3d.model_decoders) do
		if v.id == id then
			table.remove(render3d.model_decoders, i)
			table.sort(render3d.model_decoders, function(a, b) return #a.ext > #b.ext end)
			return true
		end
	end
	return false
end

function render3d.FindModelDecoder(path)
	for _, decoder in ipairs(render3d.model_decoders) do
		if path:endswith(decoder.ext) or decoder.ext == "" then
			return decoder.callback
		end
	end
end

runfile("lua/libraries/graphics/render3d/model_decoders/*", render3d)

render3d.model_cache = {}
render3d.model_loader_cb = utility.CreateCallbackThing(render3d.model_cache)

function render3d.LoadModel(path, callback, callback2, on_fail)
	local cb = render3d.model_loader_cb
	if cb:check(path, callback, {mesh = callback2, on_fail = on_fail}) then return true end

	local data = cb:get(path)

	if data then
		if callback2 then
			for _, mesh in ipairs(data) do
				callback2(mesh)
			end
		end
		callback(data)
		return true
	end

	event.Call("PreLoad3DModel", path)

	cb:start(path, callback, {mesh = callback2, on_fail = on_fail})

	resource.Download(path, function(full_path)
		local out = {}

		local thread = tasks.CreateTask()
		thread.debug = true
		thread:SetName(path)

		local function mesh_callback(mesh)
			cb:callextra(path, "mesh", mesh)
			table.insert(out, mesh)
		end

		local decode_callback = render3d.FindModelDecoder(path)

		if decode_callback then
			function thread:OnStart()
				decode_callback(path, full_path, mesh_callback)

				cb:stop(path, out)
			end

			utility.PushTimeWarning()
			thread:Start()
			utility.PopTimeWarning("decoding " .. path, 0.5)
		else
			cb:callextra(path, "on_fail", "unknown format " .. path)
		end
	end, function(reason)
		cb:callextra(path, "on_fail", reason)
	end, nil, path:endswith(".mdl")) -- sigh

	return true
end