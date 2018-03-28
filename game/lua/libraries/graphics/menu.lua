local menu = {}

do -- open close
	function menu.Open()
		if menu.visible then return end
		window.SetMouseTrapped(false)
		event.Call("ShowMenu", true)
		menu.visible = true
	end

	function menu.Close()
		if not menu.visible then return end
		window.SetMouseTrapped(true)
		event.Call("ShowMenu", false)
		menu.visible = false
	end

	function menu.IsVisible()
		return menu.visible
	end

	function menu.Toggle()
		if menu.visible then
			menu.Close()
		else
			menu.Open()
		end
	end

	input.Bind("escape", "toggle_menu")

	commands.Add("toggle_menu", function()
		menu.Toggle()
	end)

	event.AddListener("Disconnected", "main_menu", menu.Open)
	event.AddListener("WindowResize", "main_menu", function()
		if menu.IsVisible() then
			menu.Close()
			menu.Open()
		end
	end)
end

return menu