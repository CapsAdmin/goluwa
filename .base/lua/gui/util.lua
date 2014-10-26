
function gui.StringInput(msg, default, callback, check)
	msg = msg or "no message"
	default = default or ""
	callback = callback or logn
	
	local frame = gui.Create("frame")
	frame:SetResizingAllowed(false)
	frame:SetTitle("Text Input Request")
	frame:SetSize(Vec2(420, 125)) -- Should probably be based off their screen size...
	
	local x = 8
	local y = 8
	
	local label = gui.Create("label", frame)
	label:SetTrapInsideParent(false)
	label:SetText(msg)
	label:SetPosition(Vec2(x, y))
	label:SetSize(Vec2(400, 20))
	label:SizeToText()
	label:SetSize(label:GetSize()+Vec2(0, 4))
	label:AppendToBottom(4)
	
	local textinput = gui.Create("text_input", frame)
	textinput:SetTrapInsideParent(false)
	textinput:SetText(default)
	textinput:SetPosition(Vec2(x, y))
	textinput:SetSize(Vec2(400, 20))
	textinput:AppendToBottom(4)
	
	local text_button = gui.Create("text_button", frame)
	text_button:SetTrapInsideParent(false)
	text_button:SetText("Ok")
	text_button:SetPosition(Vec2(x, y))
	text_button:SetSize(Vec2(400, 20))
	text_button:AppendToBottom(4)
	
	
	text_button.OnPress = function(self)
		callback(textinput:GetText())
		frame:Remove()
	end
	
	textinput.OnEnter = function(self)
		local str = textinput:GetText()
		if not check or check(str, self) ~= false then
			callback(str)
			frame:Remove()
		end
	end
	
	frame:OnRequestLayout()
	frame:SizeToContents(4, 4)
	frame:Center()
end



