jit.off(true, true)

CLIENT = true
SERVER = false
DISABLE_CURSES = true
OnUpdate = function() end
SCITE = true

local old_print = print

loadfile("../../../lua/init.lua")()

console.Print = old_print

event.Delay(0.1, function() vfs.AutorunAddons("scite/") end)

local function call_event(name)
	local name = "SciTE" .. name
	
	return function(...)
		return event.Call(name, ...)
	end
end

OnClear = call_event("Clear")
OnOpen = call_event("Open", filename)
OnSwitchFile = call_event("SwitchFile", filename)
OnBeforeSave = call_event("BeforeSave", filename)
OnSave = call_event("Save", filename)
OnChar = call_event("Char", chs)
OnSavePointReached = call_event("SavePointReached")
OnSavePointLeft = call_event("SavePointLeft")
OnStyle = call_event("Style")
OnDoubleClick = call_event("DoubleClick")
OnUpdateUI = call_event("UpdateUI")
OnMarginClick = call_event("MarginClick")
OnUserListSelection = call_event("UserListSelection", listType, selection)
OnKey = call_event("Key")
OnDwellStart = call_event("DwellStart", pos, word)
OnClose = call_event("Close", filename)
OnStrip = call_event("Strip", control, change)

system.SetCursor = function() end

event.Delay(0, function() include("libraries/extensions/scite.lua") end)

print("goluwa loaded")