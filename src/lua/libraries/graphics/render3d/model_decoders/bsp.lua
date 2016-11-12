local render3d = ... or _G.render3d

if not steam.LoadMap then return end

render3d.AddModelDecoder("bsp", function(path, full_path, mesh_callback)
	for _, mesh in ipairs(steam.LoadMap(full_path).render_meshes) do
		mesh_callback(mesh)
	end
end)

event.AddListener("PreLoad3DModel", "bsp_mount_games", steam.MountGamesFromMapPath)