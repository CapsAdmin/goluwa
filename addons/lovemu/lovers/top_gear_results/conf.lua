function love.conf(t) --partial
	if t.screen then
		t.screen.width = 1280
		t.screen.height = 720
		t.screen.vsync = false
	else
		t.window.width = 1280
		t.window.height = 720
		t.window.vsync = false
	end
	t.title = "LovEmu - The Love2D for GOLUWA"      
	t.author = "Shell32"
end