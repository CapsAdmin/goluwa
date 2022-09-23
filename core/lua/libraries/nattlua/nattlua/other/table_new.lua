local table_new
local ok

if not _G.gmod--[[# as any]] then ok, table_new = pcall(require, "table.new") end

if not ok then
	table_new = function(size--[[#: number]], records--[[#: number]])
		return {}
	end
end

return table_new
