steam.MountSourceGame("csgo")

vfs.Search("models", {"mdl"}, function(path)
	print(path)
end)