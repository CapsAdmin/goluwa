local insert=table.insert
local assert=assert
local type=type
local find=string.find
local sub=string.sub
function string.split(s, delim)
	assert (type (delim) == "string" and #delim > 0,
	"bad delimiter")
	local start = 1
	local t = {}
	while true do
		local pos = find (s, delim, start, true)
		if not pos then
			break
		end
		insert (t, sub (s, start, pos - 1))
		start = pos + #delim
	end 
	insert (t, sub (s, start))
	return t
end