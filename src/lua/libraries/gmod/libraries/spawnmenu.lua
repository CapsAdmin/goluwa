local spawnmenu = gmod.env.spawnmenu

function spawnmenu.PopulateFromTextFiles()
	return {}
end

do -- presets
	function gmod.env.LoadPresets()
		local out = {}

		for folder_name in vfs.Iterate("settings/presets/") do
			if vfs.IsDirectory("settings/presets/"..folder_name) then
				out[folder_name] = {}
				for file_name in vfs.Iterate("settings/presets/"..folder_name.."/") do
					table.insert(out[folder_name], steam.VDFToTable(vfs.Read("settings/presets/"..folder_name.."/" .. file_name)))
				end
			end
		end

		return out
	end

	function gmod.env.SavePresets()

	end
end