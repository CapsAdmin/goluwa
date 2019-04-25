google = {}

do
	local base_url = "https://translate.google.com/translate_a/single?client=t&sl={FROM}&tl={TO}&hl={FROM}&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=2&rom=1&ssel=0&tsel=0&kc=3&tk={TOKEN}&q="

	local xr = function(a, chunk)
		for offset = 0, #chunk - 3, 3 do
			local b = chunk:byte(offset + 3)
			b = ("a"):byte() <= b and b - 87 or b
			b = "+" == chunk:byte(offset + 2) and bit.rshift(a, b) or bit.lshift(a, b)
			a = "+" == chunk:byte(offset + 1) and a + bit.band(b, 4294967295) or bit.bxor(a, b)
		end

		return a
	end

	function gen_token(input)
		local b = {}
		local bi = 0
		for i = 0, #input - 1 do
			local frame = input:byte(i+1)
			if 128 > frame then
				b[bi] = frame
				bi = bi + 1
			else
				if 2048 > frame then
					b[bi] = bit.bor(bit.rshift(frame, 6), 192)
					bi = bi + 1
				else
					if 55296 == bit.band(frame, 64512) and (i + 1 < #input and 56320 == bit.band(input:byte(i + 1), 64512)) then
						frame = 65536 + bit.lshift(bit.band(frame, 1023), 10) + bit.band(input:byte(i + 1), 1023)

						b[bi] = bit.bor(bit.rshift(frame, 18), 240)
						bi = bi + 1
						b[bi] = bit.bor(bit.band(bit.rshift(frame, 12), 63), 128)
						bi = bi + 1
					else
						b[bi] = bit.bor(bit.rshfit(frame, 12), 224)
						bi = bi + 1
					end

					b[bi] = bit.bor(bit.band(bit.rshift(frame, 6), 63), 128)
					bi = bi + 1
				end

				b[bi] = bit.bor(bit.band(frame, 63), 128)
				bi = bi + 1
			end
		end

		local out = 0

		for bi = 0, #b - 1 do
			out = out + b[bi]
			out = xr(out, "+-a^+6")
		end
		out = xr(out, "+-3^+b+-f")
		out = bit.bxor(out, base_token[1]) or 0
		if 0 > out then
			out = bit.band(out, 2147483647) + 2147483648
		end
		out = out % 1E6
		return out .. "." .. bit.bxor(out, base_token[2])
	end

	--[[local eval_str = "('((function(){var a\x3d2504491494;var b\x3d-797604507;return 409749+\x27.\x27+(a+b)})())')"
	local a = eval_str:match("var a=(.-);")
	local b = eval_str:match("var b=(.-);")
	local c = eval_str:match("return (%d+)")

	base_token = c .. "." .. (a+b)
	base_token = base_token:split(".")]]

	function google.Translate(from, to, str, callback)

		if not base_token then
			-- i get 403 for some reason but if i can get past that getting the base token should work
			http.Get("http://translate.google.com", function(data)
				local eval_str = data.content:match("TKK=eval(%b())")

				local a = eval_str:match("var a=(.-);")
				local b = eval_str:match("var b=(.-);")
				local c = eval_str:match("return (%d+)")

				base_token = c .. "." .. (a+b)
				base_token = base_token:split(".")
			end)
			return
		end

		from = from or "auto"
		to = to or "en"
		str = str or ""


		local url = base_url
		url = url:gsub("{FROM}", from)
		url = url:gsub("{TO}", to)
		url = url:gsub("{TOKEN}", gen_token(str)) -- untested, copied from js source
		url = url .. sockets.EscapeURL(str)

		http.Get(url, function(data)
			table.print(data)
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

	http.Get(
		"http://suggestqueries.google.com/complete/search?client=firefox&q=" .. question .. "%20",
		function(data)
			local str = data.content
			:gsub("%[%[", "")
			:gsub("%]%]", "")
			:gsub('"', "")
			:gsub("[^%a, ]", "")
			:gsub(_q:lower() .. " ", "")

			local tbl = str:split(',')
			table.remove(tbl, 1)

			callback(tbl)
		end
	)
end

function google.YoutubeSearch(query, callback)
	http.Get(("http://gdata.youtube.com/feeds/api/videos?q=%s&max-results=1&v=2&prettyprint=flase&alt=json"):format(query), function(data)
		local hashed = serializer.Decode("json", data.content)

		if not hashed.feed or not hashed.feed.entry then return end

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

commands.Add("yt=string", function(query)
	google.YoutubeSearch(query, function(info)
		local votes = info.likes + info.dislikes

		local rating = ((info.likes+0.0)/votes)*100
		rating = math.round(rating) .. "%"

		chat.Append("Google", ("YouTube | %s | %s | %s views | %s | http://youtu.be/%s | More results: %s"):format(info.name, info.length, info.views, info.rating, info.id, info.page_url))
	end)
end)

commands.Add("gauto=arg_line", function(str)
	google.AutoComplete(str, function(tbl)
		local msg = table.random(tbl)
		chat.Append("Google", msg)
	end)
end)

commands.Add("translate|tr|t=string|nil,string|nil,string_rest", function(from, to, str)
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

commands.Add("g=arg_line", function(query)
	system.OpenURL(print(("http://www.google.com/search?&q=%s"):format(sockets.EscapeURL(query))))
end)