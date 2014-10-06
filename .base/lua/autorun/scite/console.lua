local history = {}

for _, str in ipairs(serializer.ReadFile("luadata", "%DATA%/cmd_history.txt")) do
	table.insert(history, 1, str)
end

local console_input = ""

event.AddListener("SciTEStrip", "scite_cmd", function()
	console_input = scite.StripValue(1)
end)

event.AddListener("SciTEKey", "scite_cmd", function(key)
	if key == 13 and console_input ~= "" then
		console.RunString(console_input, nil, nil, true)
		table.insert(history, 1, console_input)
		
		console_input = ""
		scite.StripShow("'console:'{}")
		scite.StripSetList(1, table.concat(history, "\n"))
	end
end)

function debug.openscript(script, line)
	scite.Open(R(script) or script)
	if line then scite.SendEditor(SCI_GOTOLINE, line) end
end

scite.StripShow("'console:'{}") 
scite.StripSetList(1, table.concat(history, "\n"))