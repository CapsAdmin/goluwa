resource.Download("http://clu.uni.no/nta/ordlistf.zip", function(dir)
	local list = {}

	vfs.Read(dir .. "/ORDLISTF.TXT"):gsub("(%d+) (.-)\r\n", function(count, word)
		if tonumber(count) <= 10 or utf8.length(word) <= 2 or word:find("%d") then
			return
		end

		word = word:replace("-", "")

		table.insert(list, word)
	end)

	print(list)

	vfs.Write("/home/caps/ScrabblisUnity/Assets/Resources/word_lists/norwegian.txt", table.concat(list, "\n"))
end)