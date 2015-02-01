local panel = gui.CreatePanel("text_button", nil, "notification")
panel:SetSize(Vec2(300, 100))
panel:SetPosition(render.GetScreenSize() - Vec2(panel:GetSize().w, -panel:GetSize().h))
panel:Animate("DrawPositionOffset", {"from", Vec2(0, panel:GetSize().h)}, 0.5, "+", 1)

do return end

sockets.Get("https://github.com/search?l=Lua&o=desc&p=1&q=extension%3Alua&ref=advsearch&s=updated&type=Repositories&utf8=%E2%9C%93", function(data)
	for chunk in data.content:gmatch("<h3 class=\"repo%-list%-name\">(.-)</h3>") do
		local repo_name = chunk:match("href=(%b\"\")"):sub(2, -2)
		local url = "https://github.com" .. repo_name
		local author = repo_name:match("^/(.-)/")
		sockets.Get(url, function(data)			
			local description = data.content:match("<meta name=\"description\" content=\"(.-)\""):gsub("&#(.-);", function(num) return string.char(num) end)
			local message = data.content:match("commit%-title.-title=\"(.-)\"")
			
			local year,month,day,hour,min,sec = data.content:match("datetime=\"(.-)%-(.-)%-(.-)T(.-):(.-):(.-)Z\"")
			local time = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
			local time_text = os.date("%H hours %M minutes and %S seconds ago", os.time() - time)
			
			logf("%s\ndesc:\t%q\nmsg:\t%q\nauthor:\t%s\nurl:\t%s\n", time_text, description, message, author, url)
		end)
	end
end)