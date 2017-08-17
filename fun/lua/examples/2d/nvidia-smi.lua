local font = fonts.CreateFont({size = 16, monospace = true, spacing = 7})
local str

event.Timer("nvidia-smi", 1, 0, function()
	str = io.popen("nvidia-smi"):read("*all")
end)

event.AddListener("PreDrawGUI", "nvidia-smi", function()
	gfx.SetFont(font)
	gfx.DrawText(str)
end)