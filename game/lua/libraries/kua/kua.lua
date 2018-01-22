local kua = {}

runfile("lexer.lua", kua)

local function test_lua_files()
	if true or not FILES then
		FILES = {}
		for _, path in pairs(vfs.Search("/home/caps/snabb/", {"lua"})) do

			local str, err = vfs.Read(path)
			if str then
				table.insert(FILES, {str=str, path=path})
			else
				print(err)
				print(path)
			end
		end
	end


	S""
	for i,v in ipairs(FILES) do
		local tokens, err = kua.Lexify(v.str)
		if not tokens then
			print(err)
			print(v.path)
		end
	end
	S""
end


local function test_string()
	local tokens, err = kua.Lexify(
	[========[#!asdawdawd
	local num = 0x4p4a
	]========]
)

	if tokens then
		kua.DumpTokens(tokens)
		--table.print2(tokens)
	else
		print(err, "!!")
	end
end

test_lua_files()
--test_string()

_G.kua = kua

return kua
