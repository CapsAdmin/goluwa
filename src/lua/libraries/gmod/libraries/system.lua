local system = gine.env.system

function system.IsLinux()
	return false
end

function system.IsWindows()
	return true
end

function system.IsOSX()
	return false
end

function system.GetCountry()
	return "NO"
end

