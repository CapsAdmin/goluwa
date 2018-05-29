local menu = {}

menu.panel = menu.panel or NULL

do -- open close
	function menu.Open()
		if menu.visible then return end
		window.SetMouseTrapped(false)
		input.disable_focus = 0
		event.Call("ShowMenu", true)
		menu.visible = true
	end

	function menu.Close()
		if not menu.visible then return end
		window.SetMouseTrapped(true)
		input.disable_focus = 0
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

	input.Bind("escape", "toggle_menu", function()
		menu.Toggle()
	end)

	input.Bind("escape+left_shift", "toggle_menu", function()
		menu.Toggle()
	end, true)

	event.AddListener("Disconnected", "main_menu", menu.Open)
end

return menu