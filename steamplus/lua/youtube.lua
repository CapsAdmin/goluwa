event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if not txt:find("youtube") then return end
	
	local query = sockets.EscapeURL(txt)
	sockets.Get(("http://gdata.youtube.com/feeds/api/videos?q=#%s&max-results=1&v=2&prettyprint=flase&alt=json"):format(query), function(data)
		local hashed = serializer.Decode("json", data.content)

		local page_url = shorten_url("https://www.youtube.com/results?search_query=#{query}")

		local name = hashed["feed"]["entry"][0]["media$group"]["media$title"]["$t"]
		local id = hashed["feed"]["entry"][0]["media$group"]["yt$videoid"]["$t"]
		local views = hashed["feed"]["entry"][0]["yt$statistics"]["viewCount"]
		local likes = hashed["feed"]["entry"][0]["yt$rating"] and hashed["feed"]["entry"][0]["yt$rating"]["numLikes"]
		local dislikes = hashed["feed"]["entry"][0]["yt$rating"] and hashed["feed"]["entry"][0]["yt$rating"]["numDislikes"]
		local length = hashed["feed"]["entry"][0]["media$group"]["yt$duration"]["seconds"]

		--local embed = hashed["feed"]["entry"][0]["yt$accessControl"].find{|i| i["action"] == "embed"}

		--local views = add_commas(views) 
		local votes = likes.to_i + dislikes.to_i
		
		--rating = ((likes.to_i+0.0)/votes)*100
		--rating = rating.round.to_s + "%"
		--length = length_in_minutes(length.to_i)

		local reply = ("YouTube | %s | %s | %s views | %s | http://youtu.be/%s | More results: %s"):format(name, length, views, rating, id, page_url)
		print(reply)
	end)
end)