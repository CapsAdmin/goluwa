timer.Delay(5, function()
	if vfs.IsFile("data/jit_dump.lua") then
		vfs.Write("data/old_jit_dump.lua", vfs.Read("data/jit_dump.lua"))
	end

	jit.dumpinfo(function()
		render2d.DrawRect(0, 0, 5, 5)
	end, R("data/") .. "jit_dump.lua")

	os.execute(
		"meld " .. R("data/") .. "jit_dump.lua" .. " " .. R("data/") .. "old_jit_dump.lua&"
	)
end)