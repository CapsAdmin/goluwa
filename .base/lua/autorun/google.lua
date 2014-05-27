if CLIENT then
    message.AddListener("google_say", function(str)
		local tbl = chat.AddTimeStamp()
		table.insert(tbl, Color(29,113,239))
		table.insert(tbl, "G")
		table.insert(tbl, Color(214,68,48))
		table.insert(tbl, "o")
		table.insert(tbl, Color(255,184,10))
		table.insert(tbl, "o")
		table.insert(tbl, Color(29,113,239))
		table.insert(tbl, "g")
		table.insert(tbl, Color(5,163,94))
		table.insert(tbl, "l")
		table.insert(tbl, Color(214,68,48))
		table.insert(tbl, "e")		
		table.insert(tbl, Color(255, 255, 255, 255))
		table.insert(tbl, ": ")
		table.insert(tbl, str)
		chathud.AddText(unpack(tbl))
    end)
end

if SERVER then
    event.AddListener("PlayerChat", "google", function(ply, question)
		question = question:lower()
		if question:find("google.+?") then
			question = question:match("google.-(%a.+)?")

			if not question then return end

			local _q = question
			question = question:gsub("(%A)", function(char) return "%"..("%x"):format(char:byte()) end)

			sockets.Get(
				"http://suggestqueries.google.com/complete/search?client=firefox&q=" .. question .. "%20",
				function(data)
					local str = data.content
					:gsub("%[%[", "")
					:gsub("%]%]", "")
					:gsub('"', "")
					:gsub("[^%a, ]", "")
					:gsub(_q:lower() .. " ", "")
					
					local tbl = str:explode(',')
					table.remove(tbl, 1)

					local msg = table.random(tbl)
					
					chat.Append("Google", msg)
					
					message.Broadcast("google_say", msg)
				end
			)
		end
	end)
end