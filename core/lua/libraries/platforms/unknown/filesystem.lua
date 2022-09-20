local fs = _G.fs or {}

function fs.get_files(name)
	local out = {}
	return out
end

function fs.get_current_directory()
	return "."
end

function fs.set_current_directory(path) end

function fs.create_directory(path) end

function fs.get_attributes(path)
	return false
end

return fs