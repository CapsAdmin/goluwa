local kua = {}

runfile("tokenizer.lua", kua)
runfile("tree.lua", kua)

MINIFIED = MINIFIED or vfs.Read(e.BIN_FOLDER .. "main.lua")

--S""
local tokens = kua.Tokenize(MINIFIED)
--S""

table.print(tokens[#tokens])

commands.Add("tokenize=arg_line", function(str)
	kua.DumpTokens(kua.Tokenize(str))
end)

return kua