local kua = {}

runfile("lexer.lua", kua)

if true or not FILES then
	FILES = {}
	for path in pairs(vfs.GetLoadedLuaFiles()) do
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

do return end
if tokens then
	--kua.DumpTokens(tokens)
	--table.print2(tokens)
else
	print(err, "!?!")
end

_G.kua = kua

return kua
