local data = {
	total_lines = 0,
	total_words = 0,
	total_chars = 0,
	words = {},
	files = {},
}

local blacklist = {
	"gmod/exported.lua",
	"ffi/bullet.lua",
	"header.lua",
	"enums.lua",
	"utf8data.lua",
	"_emotes.lua",
	"icons.lua",
	"capsadmin",
}

local blacklist_dir = {
	"/modules",
	"/capsdamin",
	"/gmod",
	"/love",
	"/build",
	"/repo",
}

local words = {}
local done = {}

for _, path in ipairs(vfs.Search("os:/media/caps/ssd_840_120gb/goluwa/src/lua/", ".lua", nil, blacklist_dir)) do
	for i,v in ipairs(blacklist) do
		if path:find(v) then
			goto continue
		end
	end

	if done[path] then goto continue end

	local str = vfs.Read(path)

	if str then
		local lines = str:gsub("[\n]+", "\n"):count("\n")
		data.total_lines = data.total_lines + lines
		str = str:gsub("%s+", " ")
		data.total_words = data.total_words + str:count(" ")
		data.total_chars = data.total_chars + #str

		for i, word in ipairs(str:split(" ")) do
			words[word] = (words[word] or 0) + 1
		end

		table.insert(data.files, {path = path, lines = lines})
	else
		print(path)
	end

	done[path] = true

	::continue::
end

data.total_chars = data.total_chars - data.total_words

table.sort(data.files, function(a, b) return a.lines > b.lines end)

for word, count in pairs(words) do
	table.insert(data.words, {word = word, count = count})
end

table.sort(data.words, function(a, b) return a.count > b.count end)

for i = 50 + 1, #data.words do
	data.words[i] = nil
	data.files[i] = nil
end

table.print(data)