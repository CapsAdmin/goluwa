local urlRewriters = {
	{ "^https?://imgur%.com/([a-zA-Z0-9_]+)$",      "http://i.imgur.com/%1.png" },
	{ "^https?://www%.imgur%.com/([a-zA-Z0-9_]+)$", "http://i.imgur.com/%1.png" }
}

local allowed = {
	gif = true,
	jpg = true,
	jpeg = true,
	png = true,
}

local sDCvar = pvars.Setup("chathud_image_slidesduration", 0.5)
local hDCvar = pvars.Setup("chathud_image_holdduration", 5)
local cvar = pvars.Setup("chathud_image_url", 1)

local queue = {}
local busy

local function show_image(url)
	busy = true

	-- Animation parameters
	local slideDuration = sDCvar:Get()
	local holdDuration = hDCvar:Get()
	local totalDuration = slideDuration * 2 + holdDuration

	-- Returns a value from 0 to 1
	-- 0: Fully off-screen
	-- 1: Fully on-screen
	local function getPositionFraction(t)
		if t < slideDuration then
			-- Slide in
			local normalizedT = t / slideDuration
			return math.cos((1 - normalizedT) * math.pi / 4)
		elseif t < slideDuration + holdDuration then
			-- Hold
			return 1
		else
			-- Slide out
			local t = t - slideDuration - holdDuration
			local normalizedT = t / slideDuration
			return math.cos(normalizedT * math.pi / 4)
		end
	end

	local tex = render.CreateTextureFromPath(url)

	local start = system.GetElapsedTime()

	event.AddListener("PreDrawGUI", "chathud_image_url", function()
		if tex:IsLoading() then
			start = system.GetElapsedTime()
			return
		end

		local t = system.GetElapsedTime() - start

		if t > totalDuration then
			event.RemoveListener("PreDrawGUI", "chathud_image_url")
			table.remove(queue, 1)
			busy = false
			return
		end

		render2d.SetColor(1,1,1,1)
		render2d.SetTexture(tex)
		render2d.DrawRect(10 + render2d.GetSize() * (getPositionFraction(t) - 1), 10, tex:GetSize().x / 2, tex:GetSize().y / 2)
	end)
end

event.AddListener("ClientChat", "chathud_image_url", function(client, str)

	if str == "" then return end

	local num = cvar:Get()

	if num == 0 then return end

	if str == "sh" then
		event.RemoveListener("PreDrawGUI", "chathud_image_url")
		queue = {}

		return
	end

	if str:find("http") then
		event.Timer("chathud_image_url_queue", 0.25, 0, function()
			if busy then return end
			local url = queue[1]
			if url then
				show_image(url)
			end
		end)

		str = str:gsub("https:", "http:")

		str = str .. " "
		local url = str:match("(http://.-)%s")
		if not url then return end

		for _, rewriteRule in ipairs(urlRewriters) do
			url = string.gsub(url, rewriteRule[1], rewriteRule[2])
		end

		local ext = url:match(".+%.(.+)")
		if not ext then return end

		if not allowed[ext] then return end

		for _,v in pairs(queue) do
			if v == url then return end
		end

		url = url:trim()

		table.insert(queue, url)
	end
end)