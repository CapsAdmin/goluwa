local render3d = ... or _G.render3d

if not steam.LoadModel then return end

render3d.AddModelDecoder("mdl", function(path, full_path, mesh_callback)
	steam.LoadModel(full_path, function(mesh)
		mesh_callback(mesh)
	end)
end)