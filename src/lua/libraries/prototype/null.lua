local prototype = ... or _G.prototype

do
	local NULL = {}

	NULL.Type = "null"
	NULL.IsNull = true

	local function FALSE()
		return false
	end

	function NULL:IsValid()
		return false
	end

	function NULL:__tostring()
		return "NULL"
	end

	function NULL:__copy()
		return self
	end

	function NULL:__index(key)
		if type(key) == "string" and key:sub(0, 2) == "Is" then
			return FALSE
		end

		error(("tried to index %q on a NULL value"):format(key), 2)
	end

	prototype.Register(NULL)
end

function prototype.MakeNULL(tbl)
	table.clear(tbl)
	tbl.Type = "null"
	setmetatable(tbl, prototype.GetRegistered("null"))

	if prototype.created_objects then
		prototype.created_objects[tbl] = nil
	end
end

_G.NULL = setmetatable({Type  = "null", ClassName = "ClassName"}, prototype.GetRegistered("null"))