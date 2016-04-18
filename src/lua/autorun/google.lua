google = {}

do
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
end

do
	local base_url = "http://translate.google.com/translate_tts?tl=%s&q=%s"

	function google.SayTTS(lang, str)
		local url = base_url:format(lang, sockets.EscapeURL(str))

		local source = audio.CreateSource(url)
		source:Play()
	end
end

function google.AutoComplete(question, callback)
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

			callback(tbl)
		end
	)
end

function google.YoutubeSearch(query, callback)
	sockets.Get(("http://gdata.youtube.com/feeds/api/videos?q=%s&max-results=1&v=2&prettyprint=flase&alt=json"):format(query), function(data)
		local hashed = serializer.Decode("json", data.content)

		if not hashed.feed or not hashed.feed.entry then return end

		local page_url = "https://www.youtube.com/results?search_query=#" .. query

		local name = hashed["feed"]["entry"][1]["media$group"]["media$title"]["$t"]
		local id = hashed["feed"]["entry"][1]["media$group"]["yt$videoid"]["$t"]
		local views = hashed["feed"]["entry"][1]["yt$statistics"]["viewCount"] or 0
		local likes = hashed["feed"]["entry"][1]["yt$rating"] and hashed["feed"]["entry"][1]["yt$rating"]["numLikes"] or 0
		local dislikes = hashed["feed"]["entry"][1]["yt$rating"] and hashed["feed"]["entry"][1]["yt$rating"]["numDislikes"] or 0
		local length = hashed["feed"]["entry"][1]["media$group"]["yt$duration"]["seconds"]

		--local embed = hashed["feed"]["entry"][0]["yt$accessControl"].find{|i| i["action"] == "embed"}

		--local views = add_commas(views)
		callback({name = name, id = id, views = views, likes = likes, dislikes = dislikes, length = length})
	end)
end

if not SOCKETS then return end

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
			google.AutoComplete(question, function(tbl)
				local msg = table.random(tbl)

				chat.Append("Google", msg)

				message.Broadcast("google_say", msg)
			end)
		end
	end)
end

commands.Add("yt", function(query)
	google.YoutubeSearch(query, function(info)
		local votes = info.likes + info.dislikes

		local rating = ((info.likes+0.0)/votes)*100
		rating = math.round(rating) .. "%"

		chat.Append("Google", ("YouTube | %s | %s | %s views | %s | http://youtu.be/%s | More results: %s"):format(info.name, info.length, info.views, info.rating, info.id, info.page_url))
	end)
end)

commands.Add("gauto", function(line)
	google.AutoComplete(line, function(tbl)
		local msg = table.random(tbl)
		chat.Append("Google", msg)
	end)
end)

commands.Add("t", function(line, from, to, str)
	local client = commands.GetClient()

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

commands.Add("g", function(query)
	system.OpenURL(print(("http://www.google.com/search?&q=%s"):format(sockets.EscapeURL(query))))
end)