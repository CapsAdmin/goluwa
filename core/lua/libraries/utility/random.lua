do
	local vowels = {"e", "a", "o", "i", "u", "y"}
	local consonants = {
		"t",
		"n",
		"s",
		"h",
		"r",
		"d",
		"l",
		"c",
		"m",
		"w",
		"f",
		"g",
		"p",
		"b",
		"v",
		"k",
		"j",
		"x",
		"q",
		"z",
	}
	local first_letters = {
		"t",
		"a",
		"s",
		"h",
		"w",
		"i",
		"o",
		"b",
		"m",
		"f",
		"c",
		"l",
		"d",
		"p",
		"n",
		"e",
		"g",
		"r",
		"y",
		"u",
		"v",
		"j",
		"k",
		"q",
		"z",
		"x",
	}

	function utility.BuildRandomWords(word_count, seed)
		word_count = word_count or 8
		seed = seed or 0
		local text = {}
		local last_punctation = 1
		local capitalize = true

		for i = 1, word_count do
			math.randomseed(seed + i)
			local word = ""
			local consonant_start = 1
			local length = math.ceil((math.random() ^ 3) * 8) + math.random(2, 3)

			for i = 1, length do
				if i == 1 then
					word = word .. first_letters[math.floor((math.random() ^ 3) * #first_letters) + 1]

					if table.has_value(vowels, word[i]) then consonant_start = 0 end
				elseif i % 2 == consonant_start then
					word = word .. consonants[math.floor((math.random() ^ 4) * #consonants) + 1]
				else
					if i ~= length or math.random() < 0.25 then
						word = word .. vowels[math.floor((math.random() ^ 3) * #vowels) + 1]
					end
				end

				if capitalize then
					word = word:upper()
					capitalize = false
				end
			end

			text[i] = word
			last_punctation = last_punctation + 1

			if last_punctation > math.random(4, 16) then
				if math.random() > 0.9 then
					text[i] = text[i] .. ","
				else
					text[i] = text[i] .. "."
					capitalize = true
				end

				last_punctation = 1
			end

			text[i] = text[i] .. " "
		end

		return list.concat(text)
	end
end

function utility.BuildRandomString(length, min, max)
	length = length or 10
	min = min or 32
	max = max or 126
	local tbl = {}

	for i = 1, length do
		tbl[i] = string.char(math.random(min, max))
	end

	return list.concat(tbl)
end