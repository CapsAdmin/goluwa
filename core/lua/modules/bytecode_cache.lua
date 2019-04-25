-- run this file before loading any other files

local bytecode = {}
BYTECODE_CACHE = bytecode

local t = os.clock()
local f = io.open("./bcodecache", "rb")
if f then
	while true do
		local hex = f:read(8)
		if not hex then break end
		local len = tonumber(hex, 16)
		local key = f:read(len)

		local len = tonumber(f:read(8), 16)
		local val = f:read(len)

		bytecode[key] = val
	end
	f:close()
end

print("[bytecode cache] spent ", os.clock() - t, " loading bytecode cache")

local function set_bcode(key, str)
	bytecode[key] = str

	local f = io.open("./bcodecache", "wb")
	for k,v in pairs(bytecode) do
		f:write(("%08x"):format(#tostring(k)))
		f:write(k)

		f:write(("%08x"):format(#v))
		f:write(v)
	end
	f:close()
end

local function get_bcode(key)
	return bytecode[key]
end

local real_loadstring = loadstring
function loadstring(str, debugname)
	if #str < 100 then return real_loadstring(str, debugname) end

	local bcode = get_bcode(str)
	if bcode then
		return real_loadstring(bcode)
	end

	local func, err = real_loadstring(str, debugname)
	if func then
		set_bcode(str, string.dump(func))
	end

	return func, err
end

function loadfile(name)
	local f, err = io.open(name)
	if not f then return f, err end

	local str = f:read("*all")
	f:close()

	return loadstring(str, "@" .. name)
end

function dofile(name, ...)
	return loadfile(name)(...)
end
