local gmod = ... or _G.gmod

local chat = gmod.env.chat

function chat.AddText(...)
	local tbl = {...}
	for i, v in ipairs(tbl) do
		if gmod.env.IsColor(v) then
			tbl[i] = ColorBytes(v.r, v.g, v.b, v.a)
		elseif type(v) == "table" and v.__obj then
			tbl[i] = v.__obj
		end
	end
	chathud.AddText(unpack(tbl))
end

function chat.Close()
	_G.chat.Close()
end

function chat.Open()
	_G.chat.Open()
end

function chat.GetChatboxPos()
	return _G.chat.panel:GetPosition():Unpack()
end

function chat.GetChatboxSize()
	return _G.chat.panel:GetSize():Unpack()
end