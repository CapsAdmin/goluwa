jit.off(true, true)

SERVER = true
DISABLE_CURSES = true
OnUpdate = function() end
SCITE = true

local old_print = print

loadfile("../../../lua/init.lua")()

console.Print = old_print

vfs.AutorunAddons("scite/")

local function call_event(name)
	local name = "SciTE" .. name
	
	return function(...)
		return event.Call(name, ...)
	end
end

OnOpen = call_event("Open")
OnClose = call_event("Close")
OnSwitchFile = call_event("SwitchFile")
OnSave = call_event("Save")
OnBeforeSave = call_event("BeforeSave")
OnChar = call_event("Char")
OnKey = call_event("Key")
OnSavePointReached = call_event("SavePointReached")
OnSavePointLeft = call_event("SavePointLeft")
OnDwellStart= call_event("DwellStart")
OnDoubleClick= call_event("DoubleClick")
OnMarginClick= call_event("MarginClick")
OnUpdateUI= call_event("UpdateUI")
OnUserListSelection = call_event("UserListSelection")

print("!")