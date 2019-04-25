vfs.Search("lua/", {"lua"}, function(path)
	if path:find("framework/lua/build", nil, true) then return end
	if path:find("lua/modules", nil, true) then return end

	local str = vfs.Read(path)

	if str then
		str = str:totable()

		for i = 1, #str do
			local c = str[i]
			local b = c:byte()

			if b > 126 or (b < 32 and b ~= 10 and b ~= 9) then
				str[i] = ""
				print(path)
				print("removing byte " ..  b)
			end
		end

		vfs.Write(path, table.concat(str))
	end
end)

for i= 32, 126 do

end