local serializer = ...
local sigh = _G.sigh or {}

sigh.END = "\1"

sigh.decimals = 5

sigh.types = {}

-- 1 is reserved
local idx_counter = 2

function sigh.AddType(type, encode, decode)
	if idx_counter >= 32 then
		error("cannot add more types to sigh!", 2)
	end

	local data = {}

	data.id = idx_counter
	data.encode = encode
	data.decode = decode

	sigh.types[type] = data

	idx_counter = idx_counter + 1
end

sigh.AddType(
	"number",
	function(var)
		return "\2" .. var .. sigh.END
	end,
	function(var)
		return tonumber(var)
	end
)
sigh.AddType(
	"string",
	function(var)
		return "\3" .. sigh.EncodeString(var) .. sigh.END
	end,
	function(var)
		return sigh.DecodeString(var)
	end
)
sigh.AddType(
	"boolean",
	function(var)
		var = var and "\2" or "\3"

		return "\4" .. var .. sigh.END
	end,
	function(var)
		return var == "\2" and true or false
	end
)
sigh.AddType(
	"nil",
	function(var)
		return "\5" .. sigh.END
	end,
	function(var)
		return nil
	end
)
sigh.AddType(
	"null",
	function(var)
		return "\6" .. sigh.END
	end,
	function(var)
		return NULL
	end
)



function sigh.SetDecimals(num)
	check(num, "number", "nil")

	sigh.decimals = num or 5
end

--local shift_offset = 32

function sigh.EncodeString(str)
	--[[local new = ""

	for char in str:gmatch("(.)") do
		new = new .. string.char((char:byte() + shift_offset) % 255 + shift_offset)
	end

	return new]]

	return crypto.Base64Encode(str)
end

function sigh.DecodeString(str)
	--[[local new = ""

	for char in str:gmatch("(.)") do
		new = new .. string.char((char:byte() - (shift_offset * 2)) % 255)
	end

	return new]]
	return crypto.Base64Decode(str)
end

function sigh.GetTypeFromID(id)
	for type, data in pairs(sigh.types) do
		if data.id == id then
			return type
		end
	end
end

function sigh.Encode(...)
	local buffer = ""

	for key, arg in pairs({...}) do
		local T = typex(arg)

		if not sigh.types[T] and (hasindex(arg) and arg.GetId) then
			T = "entity"
		end

		if sigh.types[T] then
			buffer = buffer .. sigh.types[T].encode(arg)
		else
			error("cannot encode '" .. T .. "'", 2)
		end
	end

	return buffer
end

function sigh.Decode(str)
	local args = {}

	for line in str:gmatch("(.-)[\1]") do
		local id = tonumber(line:sub(1,1):byte() or nil)
		if id then
			line = line:sub(2)

			local T = sigh.GetTypeFromID(id)
			if sigh.types[T] then
				table.insert(args, sigh.types[T].decode(line))
			else
				warning("cannot decode '" .. T .. "'")
			end
		end
	end

	return args
end

serializer.AddLibrary("sigh", function(...) return sigh.Encode(...) end, function(...) return sigh.Decode(...) end, sigh)