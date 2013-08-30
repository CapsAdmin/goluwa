function love.conf(t)
	t.title = "Bolacha (Cookie) v.01"
	t.author 			= "zpankr"
	t.window.fullscreen = false
    t.window.vsync 		= true
    t.window.fsaa 		= 0
    t.window.height 	= 800
    t.window.width 		= 800
	love.filesystem.setIdentity("bolacha")
end