local system = gine.env.system

function system.IsLinux()
	return true
end

function system.IsWindows()
	return false
end

function system.IsOSX()
	return false
end

function system.GetCountry()
	return "NO"
end

