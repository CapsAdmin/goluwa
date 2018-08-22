if not scrabble then
	local list = vfs.Read("/home/caps/ScrabblisUnity/Assets/Resources/word_lists/nsf2016.txt"):split("\r\n")

	local freq = {}

	local dict = {}

	for _, line in ipairs(list) do
		if line:ulength() > 2 then
			local node = dict
			for _, char in ipairs(line:utotable()) do
				node[char] = node[char] or {}
				node = node[char]

				freq[char] = (freq[char] or 0) + 1
			end
			node.word = true
		end
	end

	freq = table.tolist(freq, function(a, b) return a.val > b.val end)

	local letters = {}

	for k, v in ipairs(freq) do
		table.insert(letters, v.key)
	end

	local max = freq[1].val

	for _, v in ipairs(freq) do
		v.val = v.val / max
	end

	scrabble = {
		letters = letters,
		dict = dict,
		freq = freq,
	}
end

for _, v in ipairs(scrabble.freq) do
	logf("%s = %%%f\n", v.key, v.val * 100)
end

local total_matches = 0
local size = 8
local board = {}

local function get_letter()
	local found = {}

	for x = 1, size do
		if board[x] then
			for y = 1, size do
				if board[x][y] and board[x][y].char then
					found[board[x][y].char] = (found[board[x][y].char] or 0) + 1
				end
			end
		end
	end

	if next(found) then
		found = table.tolist(found, function(a, b) return a.val > b.val end)

		local max = found[1].val
		for _, v in ipairs(found) do
			v.val = v.val / max
		end

		local copy = {}
		for i,v in ipairs(scrabble.freq) do
			copy[i] = {key = v.key, val = v.val}
		end

		for _, a in ipairs(found) do
			for _, b in ipairs(copy) do
				if a.key == b.key then
					print(a.key, a.val, b.val)
					b.val = b.val - a.val
				end
			end
		end

		table.sort(copy, function(a, b) return a.val > b.val end)

		print("=========")
		for _, v in ipairs(copy) do
			logf("%s = %%%f\n", v.key, v.val * 100)
		end
		print("=========")

		local difficulty = 30

		return copy[1 + math.floor((math.random() ^ difficulty) * #copy)].key
	else
		return table.random(scrabble.letters)
	end

	local difficulty = 2

	return scrabble.letters[1 + math.floor((math.random() ^ difficulty) * #scrabble.letters)]
end

for x = 1, size do
	board[x] = board[x] or {}
	for y = 1, size do
		board[x][y] = board[x][y] or {}
		board[x][y] = {char = get_letter(), match = " "}
	end
end

for y = 1, size do
	for x = 1, size do
		local node = scrabble.dict

		for i = x, size do
			local letter = board[i][y].char

			if not node[letter] then
				break
			end

			node = node[letter]

			if node.word then
				for i = x, i do
					log(board[i][y].char)
					board[i][y].match = "→"
				end
				logn("!")
				total_matches = total_matches + 1
			end
		end
	end
end

for x = 1, size do
	for y = 1, size do
		local node = scrabble.dict

		for i = y, size do
			local letter = board[x][i].char

			if not node[letter] then
				break
			end

			node = node[letter]

			if node.word then
				for i = y, i do
					log(board[x][i].char)
					board[x][i].match = "↓"
				end
				logn("!")
				total_matches = total_matches + 1
			end
		end
	end
end

for y = 1, size do
	for x = 1, size do
		log(board[x][y].char, board[x][y].match)
	end
	log("\n")
end

logn("total matches = ", total_matches)