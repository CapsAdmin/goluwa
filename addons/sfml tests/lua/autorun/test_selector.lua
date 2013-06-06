do return end
local tests = {}

for name in vfs.Iterate("lua/sfml_tests/.") do
	table.insert(tests, name)
end

local last
local current_test
local i = 0

event.AddListener("OnUpdate", "test_selector", function()
	if wait(0.1) then
		if keyboard.IsKeyPressed(e.KEY_UP) then
			i = i + 1
		elseif keyboard.IsKeyPressed(e.KEY_DOWN) then
			i = i - 1
		end
		
		if keyboard.IsKeyPressed(e.KEY_RETURN) then
			include("sfml_tests/" .. current_test)
			
			event.RemoveListener("OnUpdate", "test_selector")
			return
		end
				
		current_test = tests[i%#tests + 1]
		
		if last ~= current_test then
			logn(("\n"):rep(1000)) -- lol
			logn("press up or down to select a test")
			logn("press enter to run it")
			logn(current_test)
			last = current_test
		end
	end
end)
