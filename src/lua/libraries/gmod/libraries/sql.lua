local lib = require("lsqlite3")
gine.sql_db = gine.sql_db or lib.open(R("data/") .. "gmod_" .. (CLIENT and "cl" or SERVER and "sv") .. ".db")

local function query(str)
	local out = {}
	gine.sql_db:exec(str, function(tbl)
		local row = {}
		for k,v in ipairs(tbl) do
			row[v.key] = v.value
		end
		table.insert(out, row)
	end)
	if out[1] then
		return out
	end
end

function gine.env.sql.Query(str)
	local ok, msg = pcall(query, str)

	if not ok then
		gine.env.sql.m_strError = gine.sql_db:errmsg()
		return false
	end

	return msg
end