tester = {}

function tester.Begin(name)
	tester.hooks = {}
	tester.name = name
	tester.show_frame = false
	
	tester.__OLD_HOOK_ADD = event.AddListener
	
	function event.AddListener(event, id, ...)
		tester.hooks[event] = id
		tester.show_frame = true
		return tester.__OLD_HOOK_ADD(event, id, ...)
	end
end

function tester.End()
	event.AddListener = tester.__OLD_HOOK_ADD
	if tester.show_frame then 	
		local frm = gui2.CreatePanel("frame")
		frm:SetTitle(tester.name)
		frm:SetSize(Vec2(200, 200))
		frm:Center()
		
		frm.OnClose = function()
			frm:Remove()
			for event, id in pairs(tester.hooks) do
				_G.event.RemoveListener(event, id)
			end
		end

		local grd = gui2.CreatePanel("base", frm)
		grd:SetupLayoutChain("fill_x", "fill_y")
		grd:SetSizeStackToWidth(true)
		grd:SetForcedStackSize(Vec2(0,25))

		for k,v in pairs(tester.hooks) do			
			local lbl = gui2.CreatePanel("text_button", grd)
			lbl:SetText(k .. " " .. v)
		end
				
		function frm:OnKeyInput(key)
			if key == "escape" then
				frm:OnClose()
				frm:Remove()
			end
		end
	end
end