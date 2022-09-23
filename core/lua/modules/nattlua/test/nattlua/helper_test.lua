local helpers = require("nattlua.other.helpers")

do
	local test = [[1]]
	local data = helpers.SubPositionToLinePosition(test, 1, 1)
	equal(data.line_start, 1)
	equal(data.line_stop, 1)
	equal(data.character_start, 1)
	equal(data.character_stop, 1)
	equal(test:sub(unpack(data.sub_line_before)), "")
	equal(test:sub(unpack(data.sub_line_after)), "")
end

do
	local test = [[foo
bar
faz]]
	local start, stop = test:find("bar")
	local data = helpers.SubPositionToLinePosition(test, start, stop)
	equal(data.line_start, 2)
	equal(data.line_stop, 2)
	equal(data.character_start, 1)
	equal(data.character_stop, 3)
	equal(test:sub(unpack(data.sub_line_before)), "\n")
	equal(test:sub(unpack(data.sub_line_after)), "\n")
end

do
	local test = [[foo
bar
faz]]
	local data = helpers.SubPositionToLinePosition(test, 1, #test)
	equal(data.line_start, 1)
	equal(data.line_stop, 3)
	equal(data.character_start, 1)
	equal(data.character_stop, #test)
	equal(test:sub(unpack(data.sub_line_before)), "")
	equal(test:sub(unpack(data.sub_line_after)), "")
end

do
	local test = [[foo
bar
faz]]
	local start, stop = test:find("faz")
	equal(test:sub(start, stop), "faz")
	local data = helpers.SubPositionToLinePosition(test, start, stop)
	equal(data.line_start, 3)
	equal(data.line_stop, 3)
	equal(data.character_start, 1)
	equal(data.character_stop, 3)
	equal(test:sub(unpack(data.sub_line_before)), "\n")
	equal(test:sub(unpack(data.sub_line_after)), "")
end

do
	local test = [[foo
wad
111111E
    waddwa
    FROM>baradwadwwda HERE awd wdadwa<TOwawaddawdaw
    22222E
new
ewww
faz]]
	local start, stop = test:find("FROM.-TO")
	equal(
		helpers.BuildSourceCodePointMessage(test, "script.txt", "hello world", start, stop, 2),
		[[    ________________________________________________________
 3 | 111111E
 4 |     waddwa
 5 |     FROM>baradwadwwda HERE awd wdadwa<TOwawaddawdaw
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 6 |     22222E
 7 | new
    --------------------------------------------------------
-> | script.txt:5:5
-> | hello world]]
	)
end

do
	local test = [[foo
wad
111111E
    waddwa
    FROM>baradwadwwda HE
    
    
    RE awd wdadwa<TOwawaddawdawafter
    22222E
new
ewww
faz]]
	local start, stop = test:find("FROM.-TO")
	equal(
		helpers.BuildSourceCodePointMessage(test, "script.txt", "hello world", start, stop, 2),
		[[    _________________________________________
 3 | 111111E
 4 |     waddwa
 5 |     FROM>baradwadwwda HE
         ^^^^^^^^^^^^^^^^^^^^
 6 |     
     ^^^^
 7 |     
     ^^^^
 8 |     RE awd wdadwa<TOwawaddawdawafter
     ^^^^^^^^^^^^^^^^^^^^
 9 |     22222E
10 | new
    -----------------------------------------
-> | script.txt:5:27
-> | hello world]]
	)
end


do
	local test = ("x"):rep(500) .. "FROM---TO" .. ("x"):rep(500)
	local start, stop = test:find("FROM.-TO")
	equal(helpers.BuildSourceCodePointMessage(test, "script.txt", "hello world", start, stop, 2), [[    _______________________________________________________________________________________________________________________________
 2 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 3 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 4 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxFROM---T
                                                                                                                            ^^^^^^^^
 5 | Oxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     ^
 6 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 7 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    -------------------------------------------------------------------------------------------------------------------------------
-> | script.txt:4:384
-> | hello world]])
end

do
	local test = [[]]
	local pos = helpers.LinePositionToSubPosition(test, 2, 6)
	equal(pos, #test)
end

do
	local test = [[foo]]
	local pos = helpers.LinePositionToSubPosition(test, 2, 6)
	equal(pos, #test)
end

do
	local test = [[foo]]
	local pos = helpers.LinePositionToSubPosition(test, 1, 1)
	equal(pos, 1)
end

do
	local test = [[foo]]
	local pos = helpers.LinePositionToSubPosition(test, 0, 0)
	equal(pos, 1)
end

do
	local test = [[foo]]
	local pos = helpers.LinePositionToSubPosition(test, 1, 2)
	equal(pos, 2)
end

do
	local test = [[foo
wddwaFOOdawdaw
dwadawadwdaw
dwdwadw
]]
	local pos = helpers.LinePositionToSubPosition(test, 2, 6)
	local start = pos
	local stop = pos + #"FOO" - 1
	equal(test:sub(start, stop), "FOO")
end