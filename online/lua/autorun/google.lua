if CLIENT then
    message.AddListener("google_say", function(str)
		chat.Append("Google", str)		
    end)
end

if SERVER then
    event.AddListener("OnPlayerChat", "google", function(ply, question)
		question = question:lower()
		if question:find("google.+?") then
			question = question:match("google.-(%a.+)?")

			if not question then return end

			local _q = question
			question = question:gsub("(%A)", function(char) return "%"..("%x"):format(char:byte()) end)

			luasocket.Get(
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