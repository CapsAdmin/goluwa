local SKIN = {}

local PAD = 4
local MPOS

SKIN.Padding = PAD -- padding which is also used for scaling

local c = {}
	local dark_shift = Color(0.75, 0.85, 0.95, 1)
	local light_shift = Color(1, 1, 1, 1)
	
	dark_shift.a = 1
	light_shift.a = 1

	c.dark3 = 		Color(0.00, 0.00, 0.00, 1.00) * dark_shift
	c.dark2 = 		Color(0.10, 0.10, 0.10, 1.00) * dark_shift
	c.dark = 		Color(0.20, 0.20, 0.20, 1.00) * dark_shift
	
	c.medium = 		Color(0.30, 0.30, 0.30, 1.00) * dark_shift
	
	c.light = 		Color(0.80, 0.80, 0.80, 1.00) * light_shift
	c.light2 = 		Color(0.90, 0.90, 0.90, 1.00) * light_shift
	c.light3 = 		Color(1.00, 1.00, 1.00, 1.00) * light_shift

	c.line = 		Color(0.10, 0.10, 0.10, 0.25)
	c.border = 		Color(0.25, 0.25, 0.25, 1.00)
	c.shadow = 		Color(0.10, 0.10, 0.10, 0.20)
	c.inactive = 	Color(0.50, 0.50, 0.50, 0.10) * light_shift
	c.inactive2 = 	Color(0.50, 0.50, 0.50, 0.50) * light_shift

	c.highlight1 =	Color(0.50, 0.50, 0.75, 0.125) * light_shift
	c.highlight2 =	Color(0.50, 0.50, 0.50, 0.50) * light_shift

	c.bar = 		c.medium:Copy()

	local intensity = 0.75
	local brightness = 0.05
	
	c.button2 =		Color(c.medium.b^intensity, c.medium.r^intensity, c.medium.g^intensity, 1) + brightness
	c.button1 =		Color(c.medium.g^intensity, c.medium.b^intensity, c.medium.r^intensity, 1) + brightness
	c.button0 =		Color(c.medium.r^intensity, c.medium.g^intensity, c.medium.b^intensity, 1) + brightness
	
	c.button2.a = 1
	c.button1.a = 1
	c.button0.a = 1
	
	c.text 		 = 	c.medium:Copy()
	
	c.textinput1 = 	c.light3:Copy()
	c.textinput0 = 	Color(0.75, 0.75, 0.75) * light_shift

	c.border =		Color(0.40, 0.40, 0.40, 0.50) * light_shift
SKIN.Colors = c

do--skin
	function SKIN:Think()
		MPOS = gui.GetMousePosition()
		PAD = SKIN.Padding
	end
end

do--panel
	function SKIN:PanelDrawInactive(pnl, c)
		if not pnl:IsInFront() then
			gui.Draw("rect", Rect(Vec2(0,0), pnl:GetSize()), c.inactive)
		end
	end
	
	function SKIN:PanelDraw(pnl, c)		
		gui.Draw("rect", 
			Rect(Vec2(0,0), pnl:GetSize()),
			c.light,
			PAD/2,
			PAD/4,
			c.border,
			Vec2() + PAD / 2,
			c.shadow,
			false,
			nil,
			false,
			false
		)
	end
end

do--frame
	local bar_size = PAD * 4

	function SKIN:FrameCanDrag(pnl, pos)
		return pos.y < bar_size
	end

	function SKIN:FrameDraw(pnl, c)
		self:PanelDraw(pnl, c)
 		gui.Draw(
			"rect", 	
			Rect(Vec2(0,0), Vec2(pnl:GetSize().w, bar_size)):Expand(PAD/4) + Rect(0, -PAD/4, 0, 0), 
			c.bar, 
			PAD/2, 
			PAD/4, 
			c.medium,
			
			Vec2() + PAD / 2,
			c.shadow,
			nil,
			nil,
			false,
			false
		)
	end
	
	function SKIN:FrameCloseButtonDraw(pnl, c)
		pnl.MouseOver = pnl:IsWorldPosInside(MPOS)
		
		if not pnl:GetDrawBackground() then return end

		local col
	
		if pnl:IsDown() then
			col = c.button2:Copy() * 1.75
		else
			if pnl.MouseOver then
				col = c.button1:Copy() * 1.75
			else
				col = c.button0
			end
		end
		
		gui.Draw(
			"rect", 
			Rect(Vec2(0,0), pnl:GetSize()),
			col,
			PAD,
			0,
			col
		)
	end

	function SKIN:FrameInit(pnl)
		pnl:SetMinSize(Vec2(bar_size, bar_size))
	end

	function SKIN:FrameLayout(pnl)
		pnl:SetMargin(Rect(PAD, bar_size+PAD/4, PAD, PAD))

		local siz = bar_size - (PAD * 2)

		pnl.close:SetObeyMargin(false)
		pnl.close:SetSize(Vec2()+siz)
		pnl.close:SetPadding(Rect(PAD/2, PAD/2, PAD, PAD))
		pnl.close:Align(e.ALIGN_TOPRIGHT)

		pnl.title:SetSkinColor("text", "light")
		pnl.title:SetIgnoreMouse(true)
		pnl.title:SizeToText()
		pnl.title:SetPosition(Vec2(PAD,bar_size/2 - pnl.title:GetHeight()/2))
	end
end

do--grid
	local bar_size = PAD * 4

	function SKIN:GridLayout(pnl)
		pnl:SetPadding(Rect()+PAD)
		--pnl:SetSkinColor("light", "dark")
	end
	
	function SKIN:GridDraw(pnl, c)
		self:PanelDraw(pnl, c)
	end
end

do--button
	function SKIN:ButtonDraw(pnl, c)
		
		pnl.MouseOver = pnl:IsWorldPosInside(MPOS)
		
		if not pnl:GetDrawBackground() then return end

		local col
		
		if pnl:IsDown() then
			col = c.button2
		else
			if pnl.MouseOver then
				col = c.button1
			else
				col = c.button0
			end
		end
		
		gui.Draw(
			"rect", 
			Rect(Vec2(0,0), pnl:GetSize()),
			col,
			0,
			PAD/4,
			c.border
		)
	end
	
	function SKIN:ButtonLayout(pnl)
		if not pnl.label then return end
		pnl.label:SetSize(Vec2(pnl:GetWidth(), pnl:GetHeight()))
	end
end

do--label
	function SKIN:LabelDraw(pnl, c)
		gui.Draw(
			"text", 
			pnl.Text,
			Vec2(0, 0),
			pnl.Font,
			c.text,
			pnl.AlignNormal,
			pnl.ShadowDir,
			c.shadow,
			pnl.ShadowSize,
			pnl.ShadowBlur
		)
		
		--gui.Draw("rect", Rect(0,0, pnl:GetSize()), ColorBytes(255, 0, 0, 50))
	end

	function SKIN:LabelLayout(pnl)
		local size = gui.GetTextSize(pnl.Font, pnl.Text)	
		pnl:SetSize(size)
	end
end

do -- button text
	function SKIN:ButtonTextDraw(pnl, c)
		pnl.MouseOver = pnl:IsWorldPosInside(MPOS)
		
		if not pnl:GetDrawBackground() then return end

		local col
		
		if pnl:IsDown() then
			col = c.button2
		else
			if pnl.MouseOver then
				col = c.button1
			else
				col = c.medium
			end
		end
		
		gui.Draw("rect", 
			Rect(Vec2(0,0), pnl:GetSize()),
			col,
			PAD,
			0,
			c.shadow,
					
			nil,nil,
			
			false,
			false,
			true,
			true
		)
	end
	function SKIN:ButtonTextLayout(pnl)
		pnl.lbl:SetSkinColor("text", "light2")
		pnl.lbl:CenterY()
		pnl.lbl:SetX(PAD)
	end
end

do--menuitem
	local border = PAD/4
	
	function SKIN:MenuItemDraw(pnl, c)		
		if pnl:IsWorldPosInside(MPOS) then
			local rct = Rect(Vec2(0,0), pnl:GetSize())
			if pnl:IsDown() then
				rct:Shrink(1)
			end
			
			gui.Draw("rect", rct, c.highlight2)
		end
	end
	
	function SKIN:ContextDraw(pnl)
		gui.Draw("rect", Rect(Vec2(0,0), pnl:GetSize()), c.light, nil, nil, c.medium)
	end
	
	function SKIN:ContextSpaceDraw(pnl)
		local w = pnl:GetParent().IconSize.w
		gui.Draw("rect", Rect(Vec2(w + PAD, pnl:GetHeight() / 2), Vec2(pnl:GetParent():GetWidth() - w - PAD * 4, 2 )), c.shadow)
	end

	function SKIN:MenuItemLayout(pnl)
		pnl.img:SetSize(Vec2() + pnl:GetHeight())
		pnl.img:Align(e.ALIGN_CENTERY)
	
		--pnl.lbl:SetFont(self.Font.aahh_default)
		pnl.lbl:SizeToText()
		pnl.lbl:SetSkinColor("text", "dark")
		pnl.lbl:SetTrapInsideParent( false )
		pnl.lbl:SetPosition(pnl.img:GetPosition() + pnl.img:GetSize() + Vec2(PAD, 0))
		pnl.lbl:CenterY()
		
		local ctx = pnl:GetParent()
		
		pnl:SetSize(Vec2(pnl.lbl:GetSize().w + pnl.img:GetSize().w + PAD, ctx.IconSize.h))
	end
	
	function SKIN:ContextLayout( pnl )
		pnl:SetItemSize(Vec2()+16)
		pnl:SetSize( pnl:GetSize() + Vec2( 0, PAD * 2 ) )
		pnl:Stack()
	end
end

do--image
	function SKIN:ImageDraw(pnl, c)
		gui.Draw("texture", pnl.Texture, Rect(Vec2(0,0), pnl:GetSize()), pnl.Color, pnl.UV, pnl.Filter)
	end

	function SKIN:ImageLayout(pnl)

	end
end

do--textinput
	function SKIN:TextInputDraw(pnl, c)
		
		local siz = pnl:GetTextSize(true)
		local center = pnl:GetSize() / 2
		
		pnl.cur_text_size = siz
		
		-- background
		gui.Draw("rect", Rect(0, 0, pnl:GetWide(), pnl:GetTall()), c.light2, 0, 1, c.medium)
		
		-- text
		gui.Draw("text", pnl.Text, Vec2(PAD, PAD), pnl.Font, c.text, Vec2(0, 0))	
			
		-- caret
		if pnl:IsActivePanel() and os.clock()%0.5 > 0.25 then
			gui.Draw("rect", Rect(Vec2(siz.w+2, center.y-siz.h/2), Vec2(1, siz.h)), c.text)
		end
	end
end

do -- checkbox
	function SKIN:CheckboxDraw(pnl, c)
		local col
	
		if pnl:IsChecked() then
			col = c.light2
		else
			col = c.dark
		end
		
		gui.Draw("rect", 
			Rect(Vec2(0,0), pnl:GetSize()),
			col,
			pnl:GetHeight() / 2,
			1,
			c.dark
		)
	end

	function SKIN:CheckboxLayout(pnl)		
		
	end
end

do -- tab_bar button
	function SKIN:TabButtonDraw(pnl, c) 		
		gui.Draw("rect", 
			Rect(Vec2(0,0), pnl:GetSize()),
			c.medium,
			8,
			PAD/4,
			c.border,
			
			nil,
			nil,
			
			nil,
			false,
			nil,
			false
		)
	end
	
	function SKIN:TabButtonPostDraw(pnl, c) 		
		if not pnl.selected then
			gui.Draw(
				"rect",
				Rect(Vec2(0,0), pnl:GetSize()),
				c.inactive2
			)
		end
	end
	
	function SKIN:TabBarButtonLayout(pnl)		
		pnl.img:SetPosition(Vec2(0, 0))
		pnl.img:SetSize(Vec2(0, 0) + pnl:GetHeight() + PAD)
		pnl.img:SetRect(pnl.img:GetRect():Shrink(PAD/2))
		pnl.img:CenterY()
		
		pnl.lbl:SetSkinColor("text", "light2")
		pnl.lbl:SetPosition(pnl.img:GetPosition() + Vec2(pnl.img:GetWidth() + PAD, 0))
		pnl.lbl:CenterY()
	end	
	
	local height = PAD*4
	
	function SKIN:TabBarLayout(pnl)

		pnl.bar:SetPosition(Vec2(0, 0))
		pnl.bar:SetSize(Vec2(pnl:GetWidth(), height))
		
		local tab = pnl.current_tab
		
		if tab:IsValid() then
			tab:SetPosition(Vec2(0, height - 1))
			tab:SetSize(Vec2(pnl:GetWidth(), pnl:GetHeight() - height))
		end		
	end
end

do -- tree
	function SKIN:TreeNodeLayout(pnl)
		pnl.expand:SetSize(Vec2(PAD*2, PAD*2))
		pnl.expand:SetPosition(Vec2(pnl.offset or 0,0))
		
		pnl.image:SetSize(Vec2() + pnl:GetHeight())
		pnl.image:SetPosition(pnl.expand:GetPosition() + Vec2(pnl.expand:GetWidth() + PAD/2, 0))
		
		pnl.label:SizeToText()		 
		pnl.label:SetPosition(pnl.image:GetPosition() + Vec2(pnl.image:GetWidth() + PAD/2, 0))
		
		pnl.expand:CenterY()
		pnl.image:CenterY()
		pnl.label:CenterY()
	end
	
	function SKIN:TreeNodeDraw(pnl)
		local size = pnl:GetSize()
		
		gui.Draw("rect", Rect(0,0,size), pnl:IsMouseOver() and pnl:GetSkinColor("highlight2") or pnl:GetSkinColor("light2"))
		
		if pnl:IsDown() then
			gui.Draw("rect", Rect(0,0,size), pnl:GetSkinColor("highlight1"))
		end
	end
end

gui.RegisterSkin(SKIN, "default")