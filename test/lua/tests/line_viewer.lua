window.Open(1280,1024)

local history = {}

if ltestframe ~= nil and ltestframe:IsValid() then
	history = ltestframe.history or {}
	ltestframe:Remove()
end

ltestframe = aahh.Create("frame")
ltestframe.history = history

local frame = ltestframe

frame:SetMargin(Rect(4, 17, 4, 4))
frame:SetTitle("Lineviewer Test")
frame:SetSize(Vec2(512, 512))
frame:Center()

lineviewer = aahh.Create("lineviewer", frame)
--linviewer:SetTrapInsideParent(false)
lineviewer:Dock("fill")
lineviewer:SetByWord(true)

local bottompnl = aahh.Create("container", frame)
bottompnl:SetTrapInsideParent(false)
bottompnl:Dock("bottom")
bottompnl:SetSize(Vec2(20, 20))

local textinput = aahh.Create("text_input", bottompnl)
textinput:SetTrapInsideParent(false)
textinput:Dock("fill")
textinput:SetSize(Vec2(20, 20))

local buttonmode = aahh.Create("text_button", bottompnl)
buttonmode:SetTrapInsideParent(false)
buttonmode:Dock("left")
buttonmode:SetText("Lua")
buttonmode:SetSize(Vec2(60, 20))

frame:RequestLayout()

local MODE_LUA = 1
local MODE_CONSOLE = 2
local MODE_CHAT = 3

local function ModeToString(mode)
	if mode == MODE_LUA then
		return "Lua"
	elseif mode == MODE_CONSOLE then
		return "Console"
	elseif mode == MODE_CHAT then
		return "Chat"
	else
		return "Unknown"
	end
end

local mode = 1

local purple = Color(0.7, 0.1, 0.8, 1)
local red = Color(0.9, 0.1, 0.2, 1)
local blue = Color(0.5, 0.5, 1, 1)
local pink = Color(1, 0.5, 0.5, 1)
local white = Color(0.9, 0.9, 0.9, 1)
local gold = Color(0.8, 0.8, 0.2, 1)

local randompersonas = {
	{"CapsAdmin"	, pink},
	{"Python"		, pink},
	{"Morten"		, purple},
	{"Ronny"		, purple},
	{"Shell32"		, purple},
	{"Garry"		, gold},
}

local randommessages = {
	"!l me:SetPos(there)",
	"Pac3 is working again.",
	"Time for some oohh!",
	"Garry's Mod is outdated.",
	"Meshes anyone?",
	"More CryEngine3 documentation now!",
	"Sleep much?",
	"Sometimes, I dream about cheese.",
	"Dreams are very odd and scary.",
	"WWWWWWW Ugly right? WWWWWWW",
}

local lastchoice

local function GetRandomPersona()
	local rand = math.random(1, #randompersonas)
	if randompersonas[rand] == lastchoice then
		rand = rand+1
		if rand > #randompersonas then rand = 1 end
		return randompersonas[rand]
	end
	
	return randompersonas[rand]
end

local function GetRandomMessage()
	local rand = math.random(1, #randommessages)
	return randommessages[rand]
end

local function add_0(n)
	return n < 10 and "0"..n or n
end

local function GetTimeStamp()
	local time = os.date("*t")
	local timestamp = " "..string.format("%s:%s", add_0(time.hour), add_0(time.min)) .. " - "
	
	return timestamp
end

local first = true

local function NewLine()
	if not first then lineviewer:AddNewLine() else first = false end
end

local function AddTimeStamp()
	lineviewer:AddText(GetTimeStamp(), blue, nil, nil, 8)
end

local function AddChatText(message)
	
	local message = message or GetRandomMessage()
	local persona = GetRandomPersona()
	
	NewLine()
	
	AddTimeStamp()
	lineviewer:AddText(persona[1], persona[2], bg, nil, 9)
	lineviewer:AddText(": "..message, white, bg, nil, 9)
	lineviewer:RequestLayout()
end

local function AddErrorMsg(msg)
	
	NewLine()
	
	AddTimeStamp()
	lineviewer:AddText(msg, red, nil, nil, 9)
end

local function AddText(msg)
	
	NewLine()
	
	AddTimeStamp()
	lineviewer:AddText(msg, white, nil, nil, 9)
end

AddChatText()

-- 300 elements woooo!
for i = 1, 300 do
	AddChatText()
end

local histind = 0

textinput.OnUnhandledKey = function(self, key)
	
	if #history == 0 then return end
	
	if key == "up" then
		histind = histind+1
	elseif key == "down" then
		histind = histind-1
	else
		return
	end
	
	if histind < 0 then
		histind = #history
	elseif histind > #history then
		histind = 1
	end
	
	self:SetText(history[histind])
end

textinput.OnEnter = function(self, str)
	if str == "" then return end
	local func, err = loadstring(str, "Lineviewer Lua Execute")
	
	histind = 0
	table.insert(history, 1, str)
	
	if mode == MODE_LUA then
		AddText("lua> "..str)
		if type(func) == "function" then
			local success, err = xpcall(func, OnError)
			if success then
				-- null
			else
				AddErrorMsg(err)
			end
		else
			AddErrorMsg(err)
		end
	elseif mode == MODE_CONSOLE then
		AddText("con> "..str)
		console.RunString(str)
		self:Clear()
	elseif mode == MODE_CHAT then
		AddChatText(str)
		self:Clear()
	end
end

buttonmode.OnPress = function(self)
	mode = mode+1
	if mode > 3 then mode = 1 end
	
	self:SetText(ModeToString(mode))
end

event.AddListener("ConsolePrint", "Lineviewer", function(text)
	AddText(text)
end)
