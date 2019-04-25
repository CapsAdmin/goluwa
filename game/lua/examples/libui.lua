local ui = require("libui")
local ffi = require("ffi")

local o = ffi.new("struct uiInitOptions")
ui.Init(o)

local wnd = ui.NewWindow("libui Control Gallery", 640, 480, 1)
ui.MainSteps()
ui.ControlShow(ffi.cast("struct uiControl *", wnd))

print(ffi.string(ui.OpenFile(wnd)))

event.AddListener("Update", "libui", function()
	ui.MainStep(0)
end)