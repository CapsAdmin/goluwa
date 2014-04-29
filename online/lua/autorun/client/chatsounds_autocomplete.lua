chatsounds.ac = {}
local ac = chatsounds.ac

ac.sounds = {}
ac.found = {}
ac.words = {}
ac.highlighted = 0
ac.last_search = "+"
ac.color = Color(255, 255, 255)
ac.color_highlighted = Color(127, 255, 127)
ac.color_shadow = Color(0, 0, 0, 255)
ac.font = "sans-serif"
ac.size = 14
ac.shadow = 2
ac.margin = 0
ac.debug = 0
ac.elasped = 0
ac.scroll = 0
ac.scroll_velocity = 0

local chatsounds_autocomplete = console.CreateVariable("chatsounds_autocomplete", true)

function ac.trace(...)
	local text = "[CHATSOUNDS AUTOCOMPLETE] " .. string.format(...)
	if ac.debug >= 1 then print(text) end
	if ac.debug >= 2 and chathud then chathud.AddText(text) end
	if ac.debug >= 3 and easylua then easylua.PrintOnServer(text) end
end

function ac.visible()
	return chat.IsVisible() and ac.last_search ~= "" and chatsounds_autocomplete:Get()
end

function ac.clean(text)
	return text:lower():gsub("[^%w ]+", ""):gsub("  +", " "):trim()
end

function ac.update()
	local start = timer.clock()
	local unique = {}

	for k1, v1 in pairs(chatsounds.list) do
		for k2, v2 in pairs(v1) do
			unique[ac.clean(k2)] = true
		end
	end

	local count = 0

	for k, v in pairs(unique) do
		count = count + 1
		ac.sounds[count] = k
	end

	for i = count + 1, #ac.sounds do
		ac.sounds[i] = nil
	end

	table.sort(ac.sounds)

	for k, v in ipairs(ac.sounds) do
		local words = {}

		for i in v:gmatch("%w+") do
			words[i] = true
		end

		ac.words[k] = words
	end

	ac.trace("indexed %d sounds in %.3f seconds", #ac.sounds, timer.clock() - start)
end

function ac.search(text)	
	local start = timer.clock()

	if ac.isbad(text) then
		table.clear(ac.found)
		ac.highlighted = 0
		ac.last_search = ">>>>ERROR<<<"
		return
	end
	
	local count = 0
	local candidates = 0
	text = ac.clean(text)

	if text == "" or text == ac.last_text then
		return
	end

	local fast = text:find(ac.last_search, 1, true) == 1

	if fast then -- optimization: only look through the subset of the last search
		for k, v in ipairs(ac.found) do
			if ac.sounds[v]:find(text, 1, true) then
				count = count + 1
				ac.found[count] = v
			end

			candidates = candidates + 1
		end
	else
		for k, v in ipairs(ac.sounds) do
			if v:find(text, 1, true) then
				count = count + 1
				ac.found[count] = k
			end

			candidates = candidates + 1
		end
	end

	for i = #ac.found, count + 1, -1 do
		ac.found[i] = nil
	end

	ac.highlighted = 0

	for i = 1, #ac.found do
		local id = ac.found[i]
		local name = ac.sounds[id]

		for j in text:gmatch("%w+") do
			if ac.words[id][j] then
				ac.highlighted = ac.highlighted + 1
				ac.found[ac.highlighted], ac.found[i] = ac.found[i], ac.found[ac.highlighted]
				break
			end
		end
	end

	ac.last_search = text

	ac.elapsed = timer.clock() - start
	ac.trace("search for %q took %.3f seconds: %d matches out of %d candidates", text, ac.elapsed, count, candidates)
end

function ac.render(x, y, w, h)
	if ac.tabbed then
		ac.scroll = ac.scroll + ac.scroll_velocity
		ac.scroll_velocity = (ac.scroll_velocity + (ac.tabbed - ac.scroll) * timer.GetFrameTime() * 10) * 0.9
	end

	local max_lines = math.floor((h - ac.margin * 2) / ac.size)
	local lines = math.min(#ac.found, max_lines)

	local offset = math.min(math.max(ac.scroll - 1 - math.ceil(max_lines / 2), 0), math.max(#ac.found - max_lines, 0))

	surface.Color(1,1,1,1)
	surface.SetFont(ac.font)
			
	for i = 1, lines do
		local id = math.floor(offset) + i
		local text = string.format("%.3d - %s", id, ac.sounds[ac.found[id]] or "ERROR")
		local alpha = math.max(math.min(math.sin( math.min(math.max((0.5 + (ac.scroll - id - 0.5) / max_lines), 0), 1) * math.pi) * 255.5, 255), 0)
		
		surface.SetAlphaMultiplier(alpha / 255)
		
		-- todo
		
		--ac.size, 
		--id <= ac.highlighted and 700 or 300, 
		--ac.shadow,
		--id == ac.tabbed and ac.color_highlighted or ac.color, 
		--ac.color_shadow
	
		surface.SetTextPos(x + ac.margin, y + ac.margin + offset % 1 * -ac.size + ac.size * (i - 1))
		surface.DrawText(text)
		
	end
	
	surface.SetAlphaMultiplier(1)
end

local bad = {
	["!"] = true,
	["/"] = true,
	["\\"] = true,
	["."] = true,
	["-"] = true,
}
function ac.isbad(text)
	return bad[(text or ""):sub(1,1)]
end

event.AddListener("OnChatTab", "chatsounds_autocomplete", function(text, peek)
	if not chatsounds_autocomplete:Get() or ac.isbad(text) then return end
	
	local nopeek = peek~=true
	
	if ac.randommode then
		ac.ignore = ac.sounds[math.random(#ac.sounds)]
		return ac.ignore
	end
		
	local reverse = input.IsKeyDown("left_shift") or input.IsKeyDown("right_shift") or input.IsKeyDown("left_control")
	local prevmode = ac.tabbed
	local prevignore = ac.ignore
	
	if not ac.tabbed then
		if reverse then
			ac.tabbed = #ac.found
		else
			ac.tabbed = 1
		end
	else
		if reverse then
			ac.tabbed = ac.tabbed - 1
		else
			ac.tabbed = ac.tabbed + 1
		end
	end
	
	ac.tabbed = (ac.tabbed - 1) % #ac.found + 1

	
	ac.ignore = ac.sounds[ac.found[ac.tabbed]]
				
	--hack: revert to previous
	if not nopeek then
		local ret = ac.ignore
		
		ac.tabbed = prevmode
		ac.ignore = prevignore
		
		return ret
	end

	--WorldSound("garrysmod/balloon_pop_cute.wav", LocalPlayer():GetPos(), 50, 255)

	return ac.ignore
end)

event.AddListener("OnChatTextChanged", "chatsounds_autocomplete", function(text,lua_tab_change)
	if not chatsounds_autocomplete:Get() then return end
		
	-- this may cause future compatibility issues
	if lua_tab_change == true and string.find(text,"\n",1,true) then return end
	
	if text ~= "" and text ~= ac.ignore then
		ac.randommode = nil
	end

	if text ~= ac.ignore then
		ac.tabbed = nil
		ac.ignore = nil
		ac.search(text)
	end
end)

event.AddListener("OnDraw2D", "chatsounds_autocomplete", function()
	if ac.visible() then
		local x, y, w, h

		if false and chatgui then
			x, y = chatgui:GetPos()
			w, h = chatgui:GetSize()
			y, h = y + h, surface.ScreenHeight() - y - h
		else
			x, y = chat.GetInputPos():Unpack()
			w, h = 480, 180
			y, h = 0, y
		end

		ac.render(x, y, w, h)
	end
end)

event.AddListener("ChatsoundsUpdated", "chatsounds_autocomplete", ac.update)

if chatsounds.tree then
	ac.update()
end
