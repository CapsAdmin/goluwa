local tests = {}
local path = "addons/sfml tests/lua/sfml_tests/"

for k, v in pairs(file.Find(path .. "*")) do
	table.insert(tests, k)
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
			dofile("sfml_tests/" .. current_test)
			
			event.RemoveListener("OnUpdate", "test_selector")
			return
		end
				
		current_test = tests[i%#tests + 1]
		
		if last ~= current_test then
			print(("\n"):rep(1000)) -- lol
			print("press up or down to select a test")
			print("press enter to run it")
			print(current_test)
			last = current_test
		end
	end
end)
