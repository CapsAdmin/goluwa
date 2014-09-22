local metatable = ... or _G.metatable

do
	local NULL = {}

	NULL.Type = "null"
	NULL.TypeX = "null"
	NULL.ClassName = "NULL"
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
		
	function NULL:__index(key)		
		if type(key) == "string" and key:sub(0, 2) == "Is" then
			return FALSE
		end

		error(("tried to index %q on a NULL value"):format(key), 2)
	end

	metatable.Register(NULL)
end

function metatable.MakeNULL(tbl)

	for k,v in pairs(tbl) do tbl[k] = nil end
	tbl.Type = "null"
	setmetatable(tbl, metatable.GetRegistered("null"))
	
	if metatable.created_objects then
		metatable.created_objects[tbl] = nil
	end
	
	return var
end

_G.NULL = setmetatable({Type  = "null", TypeX = "null", ClassName = "ClassName"}, metatable.GetRegistered("null"))