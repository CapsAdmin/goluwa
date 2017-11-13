steam.MountSourceGame("csgo")
render3d.Initialize()

if not _G.mdl_paths then
	local paths = {}
	_G.mdl_paths = paths
	vfs.Search("models", {"mdl"}, function(path) table.insert(paths, path) end)
end

S""

for i = 1, 20 do
	local path = table.random(_G.mdl_paths)
	local friendly = path:match("^.+/(models/.+)")

	utility.PushTimeWarning()
		print("loading ", friendly)
		render3d.LoadModel(path, function(meshes) end)
	utility.PopTimeWarning(friendly, 0)
end

S""