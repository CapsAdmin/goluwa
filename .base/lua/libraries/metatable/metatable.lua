local metatable = _G.metatable or {}

metatable.registered = {}

function metatable.Get(id)
	return metatable.registered[id:lower()]
end

function metatable.Register(tbl, id)
	check(tbl, "table")
	check(tbl.Type, "string")
	
	id = id or tbl.Type
	id = id:lower()
	
	metatable.registered[id] = tbl
end

function metatable.GetAll()
	return metatable.registered
end

include("base_template.lua", metatable)
include("get_is_set.lua", metatable)
include("templates/*", metatable)

return metatable