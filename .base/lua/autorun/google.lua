google = {}

local base_url = "http://translate.google.com/translate_a/t?client=t&sl=%s&tl=%s&ie=UTF-8&oe=UTF-8&q=%s"

function google.Translate(from, to, str, callback)
	from = from or "auto"
	to = to or "en"
	str = str or ""

	local url = base_url:format(from, to, sockets.EscapeURL(str))

	sockets.Get(url, function(data)
		local out = {translated = "", transliteration = "", from = ""}
		local content = data.content:match(".-%[(%b[])"):sub(2, -2)
		
		for part in content:gmatch("(%b[])") do
			local to, from, trl = part:match("%[(%b\"\"),(%b\"\"),(%b\"\")")
			out.translated = out.translated .. to:sub(2,-2)
			out.from = out.from .. from:sub(2,-2)
			out.transliteration = out.transliteration .. trl:sub(2,-2)
		end
		
		callback(out)
	end)
end

function google.AutoComplete(question)
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

if CLIENT then
    message.AddListener("google_say", function(str)
		local tbl = chat.AddTimeStamp()
		table.insert(tbl, ColorBytes(29,113,239))
		table.insert(tbl, "G")
		table.insert(tbl, ColorBytes(214,68,48))
		table.insert(tbl, "o")
		table.insert(tbl, ColorBytes(255,184,10))
		table.insert(tbl, "o")
		table.insert(tbl, ColorBytes(29,113,239))
		table.insert(tbl, "g")
		table.insert(tbl, ColorBytes(5,163,94))
		table.insert(tbl, "l")
		table.insert(tbl, ColorBytes(214,68,48))
		table.insert(tbl, "e")		
		table.insert(tbl, ColorBytes(255, 255, 255, 255))
		table.insert(tbl, ": ")
		table.insert(tbl, str)
		
		if chathud then
			chathud.AddText(unpack(tbl))
		else
			print(unpack(tbl))
		end
    end)
end

if SERVER then
    event.AddListener("ClientChat", "google", function(client, question)
		question = question:lower()
		if question:find("google.+?") then
			question = question:match("google.-(%a.+)?")

			if not question then return end
			google.AutoComplete(question)
		end
	end)
end

console.AddCommand("t", function(line, from, to, str)
	local client = console.GetClient()
			
	if from and not to and not str then
		str = from
		to = "en"
		from = "auto"
	end
	
	google.Translate(from, to, str, function(data)
		chat.ClientSay(client, data.translated)
		
		if STEAM_FRIENDS_SUBJECT and STEAM_FRIENDS_SUBJECT:IsValid() then
			steam.SendChatMessage(STEAM_FRIENDS_SUBJECT:GetUniqueID(), data.translated)
		end
	end)
end)

console.AddCommand("g", function(query) 
	os.execute(([[explorer "https://www.google.no/search?&q=%s"]]):format(sockets.EscapeURL(query))) 
end)