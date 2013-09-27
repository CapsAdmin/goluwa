local steam = {}

function steam.GetInstallPath()
	if WINDOWS then
		return system.GetRegistryKey("Software\\Valve\\Steam", "SteamPath") or "C:\\Program Files (x86)\\Steam"
	elseif LINUX then
		return os.getenv("HOME") .. "/.local/share/Steam"
	end
end

return steam
