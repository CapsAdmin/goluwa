local steam = ... or steam 

for k, v in pairs(requirew("libraries.ffi.steamworks")) do
	steam[k] = v
end