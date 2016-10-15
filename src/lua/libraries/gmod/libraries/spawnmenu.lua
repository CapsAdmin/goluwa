local spawnmenu = gine.env.spawnmenu

function spawnmenu.PopulateFromTextFiles()
	return {}
end

do -- presets
	function gine.env.LoadPresets()
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

	function gine.env.SavePresets()

	end
end
