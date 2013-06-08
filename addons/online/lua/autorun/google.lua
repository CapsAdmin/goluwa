if CLIENT then
    message.AddListener("google_say", function(str)
		chat.Append("Google", str)		
    end)
end

if SERVER then

    local function GoogleSay(msg)
		message.Broadcast("google_say", msg)
		chat.Append("Google", msg)
    end

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

					GoogleSay(table.random(tbl))
				end
			)
		end
	end)

end