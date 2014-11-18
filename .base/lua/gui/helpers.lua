local gui = ... or _G.gui

function gui.StringInput(msg, default, callback, check)
	msg = msg or "no message"
	default = default or " "
	callback = callback or logn
	
	local frame = gui.CreatePanel("frame")
	frame:SetTitle("Text Input Request")
	frame:SetSize(Vec2(250, 120)) -- Should probably be based off their screen size...
	
	local pad = Rect()+frame:GetSkin().scale*4
	
	local label = frame:CreatePanel("text")
	label:SetText(msg)
	label:SetPadding(pad)
	label:SetupLayoutChain("bottom", "left", "top")
	
	local textinput = frame:CreatePanel("text_edit")
	textinput:SetText(default)
	textinput:SizeToText()
	textinput:SetPadding(pad)
	textinput:SetupLayoutChain("bottom", "left", "top", "fill_x")
	
	local text_button = frame:CreatePanel("text_button")
	text_button:SetText("Ok")
	text_button:SizeToText()
	text_button:SetPadding(pad)
	text_button:SetupLayoutChain("bottom", "left", "top", "fill_x")	
	
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
	
	frame:Center()
end



