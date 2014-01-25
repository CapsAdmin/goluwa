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
		local frm = aahh.Create("frame")
		frm:SetTitle(tester.name)
		frm:SetSize(Vec2(200, 200))
		frm:Center()
		
		frm.OnClose = function()
			frm:Remove()
			for event, id in pairs(tester.hooks) do
				_G.event.RemoveListener(event, id)
			end
		end

		local grd = aahh.Create("grid", frm)
		grd:SetSize(Vec2(100, 100))
		grd:Dock("fill")
		grd:SetSizeToWidth(true)
		grd:SetItemSize(Vec2()+25)

		for k,v in pairs(tester.hooks) do			
			local lbl = aahh.Create("textbutton", grd)
			lbl:SetText(k .. " " .. v)
		end
		
		grd:RequestLayout()
		frm:RequestLayout(true)
		frm:MakeActivePanel()
		
		function frm:OnKeyInput(key)
			if key == "escape" then
				frm:OnClose()
				frm:Remove()
			end
		end
	end
end