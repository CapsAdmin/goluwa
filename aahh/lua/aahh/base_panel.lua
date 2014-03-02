
local PANEL = {}

PANEL.ClassName = "base"
PANEL.Internal = true

function PANEL:__tostring()
	return string.format("%s[%s][%i]", self.Type, self.ClassName, self.aahh_id or 0)
end

aahh.GetSet(PANEL, "Pos", Vec2())
aahh.GetSet(PANEL, "Size", Vec2())
aahh.GetSet(PANEL, "Padding", Rect())
aahh.GetSet(PANEL, "Margin", Rect())
aahh.GetSet(PANEL, "MinSize", Vec2(8,8))
aahh.GetSet(PANEL, "TrapInsideParent", false)
aahh.GetSet(PANEL, "TrapChildren", true)
aahh.GetSet(PANEL, "Cursor", e.IDC_ARROW)
aahh.GetSet(PANEL, "Spacing", 0)
aahh.GetSet(PANEL, "DockPadding", 1) -- Default padding around all child panels in docking
aahh.IsSet(PANEL, "Visible", true)
aahh.IsSet(PANEL, "ObeyMargin", true)
aahh.IsSet(PANEL, "IgnoreMouse", false)
aahh.IsSet(PANEL, "AlwaysReceiveMouse", false)
aahh.GetSet(PANEL, "Clip", true)
aahh.GetSet(PANEL, "Offset", Vec2())

aahh.GetSet(PANEL, "Skin")
aahh.GetSet(PANEL, "DrawBackground", true)

function PANEL:__Initialize()
	self.Colors = {}
	
	self.Skin = aahh.ActiveSkin
	self:UpdateSkinColors()
end
		
do -- colors
	function PANEL:UpdateSkinColors()
		local skin = self.Skin
		if skin:IsValid() and skin.Colors then	
			for key, val in pairs(skin.Colors) do
				self.Colors[key] = self.Colors[key] or val
			end
		end
	end
	
	function PANEL:SetSkin(name)
		self.Skin = aahh.GetSkin(name)
	end
	
	function PANEL:SetSkinColor(key, val)
		self.Colors[key] = aahh.GetSkinColor(val, self.Skin, false)
		self:UpdateSkinColors()
	end
	
	function PANEL:GetSkinColor(key, def)
		self:UpdateSkinColors()
		return self.Colors[key] or aahh.GetSkinColor(key, self.Skin, def)
	end	
end

do -- orientation
	function PANEL:SetPos(a, b)
		if b then
			self.Pos.x = a
			self.Pos.y = b
		elseif typex(a) == "vec2" then
			self.Pos = a
		else
			self.Pos:Zero()
		end
		
		if self.last_pos ~= self.Pos then
			self:CalcTrap()
			self.last_pos = self.Pos
		end
	end
	
	function PANEL:SetX(x)
		local pos = self:GetPos()
		pos.x = x
		self:SetPos(pos)
	end
	
	function PANEL:SetY(y)
		local pos = self:GetPos()
		pos.y = y
		self:SetPos(pos)
	end

	function PANEL:SetSize(vec)
		vec = type(vec) == "number" and Vec2() + vec or typex(vec) == "vec2" and vec or Vec2(0, 0)
		self.Size = vec
		
		if self.last_size ~= vec then
			self:CalcTrap()
			self:RequestLayout()
			self.last_size = vec
		end
	end

	function PANEL:SetRect(rect)
		if typex(rect) ~= "rect" then return end
		self.Pos = Vec2(rect.x, rect.y)
		self.Size = Vec2(rect.w, rect.h)
		self:RequestLayout()
	end

	function PANEL:GetRect()
		return Rect(self.Pos.x, self.Pos.y, self.Size.w, self.Size.h)
	end

	function PANEL:GetParentMargin()
		return self.Parent and self.Parent.GetMargin and self.Parent:GetMargin() or Rect()
	end

	function PANEL:SetWidth(w)
		self.Size = Vec2(w, self.Size.h)
		self:RequestLayout()
	end

	function PANEL:GetWidth()
		return self.Size.w
	end

	function PANEL:SetHeight(h)
		self.Size = Vec2(self.Size.w, h)
		self:RequestLayout()
	end

	function PANEL:GetHeight()
		return self.Size.h
	end

	PANEL.GetWide = PANEL.GetWidth
	PANEL.GetTall = PANEL.GetHeight

	function PANEL:GetParentHeight()
		return self:HasParent() and self:GetParent():GetHeight() or self:GetHeight()
	end
	
	function PANEL:GetParentWidth()
		return self:HasParent() and self:GetParent():GetHeight() or self:GetHeight()
	end
	
	function PANEL:SetWorldPos(pos)		
		if not self.parent_list then self:BuildParentList() end
		
		for _, parent in ipairs(self.parent_list) do			
			pos = pos - parent:GetPos()
		end			

		self:SetPos(pos)
	end

	function PANEL:GetWorldPos()
		local pos = self:GetPos()	
	
		if not self.parent_list then self:BuildParentList() end
		
		for _, parent in ipairs(self.parent_list) do	
			pos = pos + parent:GetPos()
		end	

		return pos
	end

	do -- z orientation
		aahh.FrontPanel = NULL
		
		function PANEL:IsInFront()
			if self == aahh.World then return false end
			if self == aahh.FrontPanel then return true end
			
			if not self.parent_list then self:BuildParentList() end
			
			for _, parent in ipairs(self.parent_list) do			
				if parent == aahh.FrontPanel then
					return true
				end
			end
			
			return false
		end

		function PANEL:BringToFront()
			if self == aahh.World then return end
			
			if not self:IsInFront() then

				aahh.FrontPanel = self

				local parent = self:GetParent()
				
				if parent:IsValid() then
					local tbl = parent:GetChildren()
					for key, pnl in pairs(tbl) do
						if pnl == self then
							table.remove(tbl, key)
							table.insert(tbl, pnl)
							break
						end
					end
				end
			end
		end

		function PANEL:MakeActivePanel()
			if aahh.ActivePanel:IsValid() then
				aahh.ActivePanel:OnFocusLost()
			end
			aahh.ActivePanel = self
		end
		
		function PANEL:IsActivePanel()
			return aahh.ActivePanel == self
		end
	end
end

do -- parenting
	class.SetupParentingSystem(PANEL)

	function PANEL:AddChild(var, pos)
		var = var or NULL
		if not var:IsValid() then 
			return
		end
		
		if self == var or var:HasChild(self) then 
			return false 
		end

		var:UnParent()

		var.Parent = self

		pos = pos or #self:GetChildren() + 1
		table.insert(self:GetChildren(), pos, var)
		
		var:OnParent(self)
		self:OnChildAdd(var)
		var:BuildParentList()
		
		var:RequestLayout()
		self:RequestLayout()

		return pos
	end
	
	function PANEL:CreatePanel(name, ...)
		return aahh.Create(name, self, ...)
	end
	
	function PANEL:IsVisible()
		if self.Visible == false then return false end
		
		if not self.parent_list then self:BuildParentList() end
		
		for _, parent in ipairs(self.parent_list) do			
			if not parent.Visible then
				return false
			end
		end
		
		return true
	end
end		

do -- center
	function PANEL:CenterX()
		self:SetPos(Vec2((self.Parent:GetSize().x * 0.5) - (self:GetSize().x * 0.5), self:GetPos().y))
	end

	function PANEL:CenterY()
		self:SetPos(Vec2(self:GetPos().x, (self.Parent:GetSize().y * 0.5) - (self:GetSize().y * 0.5)))
	end

	function PANEL:Center()
		self:CenterY()
		self:CenterX()
	end
end

do -- align

	e.ALIGN_LEFT = Vec2(0, -1)
	e.ALIGN_RIGHT = Vec2(1, -1)
	e.ALIGN_CENTERX = Vec2(0.5, 0)

	e.ALIGN_TOP = Vec2(0, 0)
	e.ALIGN_BOTTOM = Vec2(0, 1)
	e.ALIGN_CENTERY = Vec2(0, 0)

	e.ALIGN_TOPLEFT = Vec2(0, 0)
	e.ALIGN_CENTERLEFT = Vec2(0, 0)
	e.ALIGN_TOPRIGHT = Vec2(1, 0)
	e.ALIGN_CENTERRIGHT = Vec2(1, 0)


	e.ALIGN_BOTTOMLEFT = Vec2(0, 1)
	e.ALIGN_BOTTOMRIGHT = Vec2(1, 1)
	e.ALIGN_CENTER = Vec2(0.5, 0)
	
	function PANEL:Align(vec, off)
		if not vec then debug.trace() end
		off = off or Vec2()
		
		local padding = self:GetPadding() or Rect()
		local size = self:GetSize() + padding:GetPosSize()
		local centerparent = self:GetParent():GetSize() * vec
		local centerself = size * vec
		local pos = centerparent - centerself
		
		if vec.x == -1 and vec.y == -1 then
			return
		elseif vec.x == -1 then
			self.Pos.y = pos.y + off.y + padding.y
		elseif vec.y == -1 then
			self.Pos.x = pos.x + off.x + padding.x
		else
			self:SetPos(pos + off + padding:GetPos())
		end
		
	end
end

do -- fill
	do -- normal
		function PANEL:Fill(left, top, right, bottom)
			self:SetSize(self.Parent:GetSize() - Vec2(right+left, bottom+top))
			self:SetPos(Vec2(left, top))
		end

		-- todo rest ??
	end

	-- do we need this?
	do -- percent
		function PANEL:FillPercent(div)
			div = div or 1

			self:SetPos(self.Parent:GetSize() / div)
			self:SetSize((self.Parent:GetSize() / 2) - (self:GetSize() / 2))
		end

		function PANEL:FillBottomPercent(div, index)
			div = div or 2
			index = math.clamp(math.abs(index or 1), 1, div)

			self:SetPos(self.Parent:GetSize() / Vec2(1, div))
			self:SetSize(self:GetSize() * Vec2(0, -index + div))
		end

		function PANEL:FillTopPercent(div, index)
			div = div or 2
			index = index or 1
			self:FillBottom(div, -index + div + 1)
		end

		function PANEL:FillRightPercent(div, index)
			div = div or 2
			index = math.clamp(math.abs(index or 1), 1, div)

			self:SetPos(self.Parent:GetSize() / Vec2(div, 1))
			self:SetSize(self.Parent:GetSize() - (self:GetSize() * Vec2(index, 1)))
		end

		function PANEL:FillLeftPercent(div, index)
			div = div or 2
			index = index or 1

			self:FillRight(div, -index + div + 1)
		end
	end

	do -- axis specific (TODO)
		function PANEL:AddRightWidth(w, prev_w)
			self:SetSize(Vec2(prev_w + w, self:GetSize().h))
		end

		function PANEL:AddBottomHeight(h, prev_h)
			self:SetSize(Vec2(self:GetSize().w, prev_h + h))
		end

		--function PANEL:AddLeftWidth(w, prev_w, prev_x)
			--self:SetPos(Vec2(prev_x - prev_w, self:GetPos().y))
			--self:SetSize(Vec2(prev_x - w + prev_w, self:GetSize().h))
		--end

		--function PANEL:AddTopHeight(h, prev_h, prev_y)
			--self:SetPos(Vec2(self:GetPos().x, prev_h + h))
			--self:SetSize(Vec2(self:GetSize().w, prev_y - h + prev_h))
		--end
		
		function PANEL:StretchToBottom()
			self:SetHeight(self:GetParentHeight() - self.Parent.Margin.h - (self.Parent:GetHeight() - self:GetPos().y))
		end
		
		function PANEL:StretchToRight()
			self:SetWidth(self:GetParentWidth() - self.Parent.Margin.w - (self.Parent:GetWidth() - self:GetPos().x))
		end
	end
end

do -- dock
	e.DOCK_NONE = 0
	e.DOCK_LEFT = 2
	e.DOCK_RIGHT = 4
	e.DOCK_TOP = 8
	e.DOCK_BOTTOM = 16
	e.DOCK_CENTERV = 32
	e.DOCK_CENTERH = 64
	e.DOCK_FILL = 128
	e.DOCK_CENTER = 96
	
	-- wrapped
	
	function PANEL:Undock()
		self:Dock()
	end
	
	function PANEL:Dock(loc)
		if not loc then
			self.DockInfo = nil
		end
		if type(loc) ~= "string" then return end
					
		self.DockInfo = string.lower(loc)
--		self:SetTrapInsideParent(false)
	--	self:SetTrapChildren(false)
		
		self:RequestLayout()
	end
	
	function PANEL:DockLayout()		
		self.SKIP_LAYOUT = true
				
		local dpad = self.DockPadding or Rect(1, 1, 1, 1)-- Default padding between all panels
		local margin = self.Margin or Rect()
		
		local x = margin.x
		local y = margin.y
		local w = self:GetWidth() - x - margin.w
		local h = self:GetHeight() - y - margin.h
		
		local area = Rect(x, y, w, h)
		
		-- Fill [CenterX CenterY] Left Right Top Bottom
		
		local fill, left, right, top, bottom, center
		local pad
		
		-- Grab one of each dock type
		for _, pnl in pairs(self:GetChildren()) do
			if pnl.DockInfo then
				if not fill and pnl.DockInfo == "fill" then
					fill = pnl
				end
				if not center and pnl.DockInfo == "center" then
					center = pnl
				end
				if not left and pnl.DockInfo == "left" then
					left = pnl
				end
				if not right and pnl.DockInfo == "right" then
					right = pnl
				end
				if not top and pnl.DockInfo == "top" then
					top = pnl
				end
				if not bottom and pnl.DockInfo == "bottom" then
					bottom = pnl
				end
			end
		end
		
		if top then
			pad = top:GetPadding() + dpad
			
			top:SetPos(area:GetPos() + pad:GetPos())
			top:SetWidth(area.w - pad:GetXW())

			area.y = area.y + top:GetHeight() + pad:GetYH()
			area.h = area.h - top:GetHeight() - pad:GetYH()
		end
		
		if bottom then
			pad = bottom:GetPadding() + dpad
			
			bottom:SetPos(area:GetPos() + Vec2(pad.x, area.h - bottom:GetHeight() - pad.h))
			bottom:SetWidth(w - pad:GetXW())
			area.h = area.h - bottom:GetHeight() - pad:GetYH()
		end
		
		if left then
			pad = left:GetPadding() + dpad
			
			left:SetPos(area:GetPos() + pad:GetPos())
			left:SetHeight(area.h - pad:GetYH())
			area.x = area.x + left:GetWidth() + pad:GetXW()
			area.w = area.w - left:GetWidth() - pad:GetXW()
		end
		
		if right then
			pad = right:GetPadding() + dpad
			
			right:SetPos(area:GetPos() + Vec2(area.w - right:GetWidth() - pad.w, pad.y))
			right:SetHeight(area.h - pad:GetYH())
			area.w = area.w - right:GetWidth() - pad:GetXW()
		end
		
		if fill then
			pad = fill:GetPadding() + dpad
			
			fill:SetPos(area:GetPos() + pad:GetPos())
			fill:SetSize(area:GetSize() - pad:GetPosSize())
			
			if fill.SizeToContens then
				fill:SizeToContents()
			end
		end
		
		if center then			
			center:Center()
		end
						
		self.SKIP_LAYOUT = false
	end

	function PANEL:DockHelper(pos, offset) -- rename this function
		offset = offset or 0

		local siz = self:GetSize()

		if
			(pos.y > 0 and pos.y < offset) and -- top
			(pos.x > 0 and pos.x < offset) -- left
		then
			return "TopLeft"
		end

		if
			(pos.y > 0 and pos.y < offset) and -- top
			(pos.x > siz.w - offset and pos.x < siz.w) -- right
		then
			return "TopRight"
		end


		if
			(pos.y > siz.h - offset and pos.y < siz.h) and -- bottom
			(pos.x > 0 and pos.x < offset) -- left
		then
			return "BottomLeft"
		end

		if
			(pos.y > siz.h - offset and pos.y < siz.h) and -- bottom
			(pos.x > siz.w - offset and pos.x < siz.w) --right
		then
			return "BottomRight"
		end

		--

		if pos.x > 0 and pos.x < offset then
			return "Left"
		end

		if pos.x > siz.w - offset and pos.x < siz.w then
			return "Right"
		end

		if pos.y > siz.h - offset and pos.y < siz.h then
			return "Bottom"
		end
		
		if pos.y > 0 and pos.y < offset then
			return "Top"
		end

		return "Center"
	end
end

function PANEL:IsWorldPosInside(a)
	local b, s = self:GetWorldPos(), self:GetSize()
	
	if self:HasParent() and not self.Parent:IsWorldPosInside(a) then
		return false
	end
	
	if
		a.x > b.x and a.x < b.x + s.w and
		a.y > b.y and a.y < b.y + s.h
	then
		return true
	end

	return false
end

function PANEL:GetMousePos()
	local pos = aahh.GetMousePos()

	if self:IsWorldPosInside(pos) then
		return pos - self:GetWorldPos()
	end

	return Vec2()
end

function PANEL:CallEvent(event, ...)
	for key, pnl in npairs(self:GetChildren()) do
		local args = {pnl:CallEvent(event, ...)}
		if args[1] == true then
			return unpack(args)
		end
	end
	
	if self[event] then
		local args = {self[event](self, ...)}
		if args[1] == true then
			return unpack(args)
		end
	end
end

function PANEL:GetNextSpace()
	
	local children = self:GetChildren()
	
	local width = 0
	local height = 0
	
	for _,child in pairs(children)do
		local x = child:GetPos().x + child:GetSize().w + child:GetPadding().w
		local y = child:GetPos().y + child:GetSize().h + child:GetPadding().h
		width = math.max(width, x)
		height = math.max(height, y)
	end
	
	return Vec2(width, height)
end

function PANEL:GetNextSpaceX()
	
	local children = self:GetChildren()
	
	local width = 0
	
	for _,child in pairs(children)do
		local x = child:GetPos().x + child:GetSize().w + child:GetPadding().w
		width = math.max(width, x)
	end
	
	return width
end

function PANEL:GetNextSpaceY()
	
	local children = self:GetChildren()
	
	local height = 8
	
	for _,child in pairs(children)do
		local y = child:GetPos().y + child:GetSize().h + child:GetPadding().h
		height = math.max(height, y)
	end
	
	return height
end

function PANEL:SizeToContents(offx, offy)
	do return end
	local offset = Vec2(offx or 0, offy or 0)
	
	self:SetSize(self:GetNextSpace() + self:GetMargin():GetSize() + offset)
end

function PANEL:SizeToContentsX(off)
	self:SetWidth(self:GetNextSpaceX() + self:GetMargin().w + off)
end

function PANEL:SizeToContentsY(off)
	self:SetHeight(self:GetNextSpaceY() + self:GetMargin().h + off)
end

function PANEL:AppendToRight(offset)
	offset = offset or 0
	self.Pos.x = self.Parent:GetNextSpaceX()+offset
end

function PANEL:AppendToBottom(offset)
	offset = offset or 0
	self.Pos.y = self.Parent:GetNextSpaceY()+offset
end

function PANEL:KeyInput(key, press)
	if self:IsActivePanel() then
		return true, self:OnKeyInput(key, press)
	end
end

function PANEL:CharInput(key, press)
	if self:IsActivePanel() then
		return true, self:OnCharInput(key, press)
	end
end

function PANEL:CalcTrap()
	self.SKIP_LAYOUT = true
	
	local parent = self:GetParent()
	
	if parent:IsValid() and parent.TrapChildren then
		local pad = self:GetSkinVar("Padding", 1)
		pad = 0
		
		if self.ObeyMargin then
			local psize = parent:GetSize()
			local m = self:GetParentMargin()

			if m.w ~= 0 then
				--print(psize, self, self.Parent and self.Parent.container, parent.TrapChildren)
				self.Size.w = math.min(self.Size.w, psize.w - m.w)
				self.Size.h = math.min(self.Size.h, psize.h - m.h)
			end
		end
		
		if self.TrapInsideParent or parent == aahh.World then
			local psize = parent:GetSize()

			self.Pos.x = math.clamp(self.Pos.x, pad, (psize.w - self.Size.w) - (pad * 2))
			self.Pos.y = math.clamp(self.Pos.y, pad, (psize.h - self.Size.h) - (pad * 2))
			
			self.Size.w = math.clamp(self.Size.w, self.MinSize.w, psize.w - pad)
			self.Size.h = math.clamp(self.Size.h, self.MinSize.h, psize.h - pad)
		end
	end
			
	self.SKIP_LAYOUT= false
end
		
function PANEL:SetVisible(b)
	self.Visible = b
	
	if b ~= self.Visible then
		if b then
			self:OnShow()
		else
			self:OnHide()
		end
	end
	
	if self:IsInFront() then
		aahh.FrontPanel = NULL
	end
end

function PANEL:VisibleInsideParent()	
	if not self:GetOffset():IsZero() then return true end

	local apos = self:GetWorldPos()
	local asiz = self:GetSize()
	
	if not self.parent_list then self:BuildParentList() end
	
	for _, parent in ipairs(self.parent_list) do
		local bpos = parent:GetWorldPos()
		local bsiz = parent:GetSize()	
		
		if apos.x + asiz.w < bpos.x or apos.y + asiz.h < bpos.y then
			return false
		end
		
		bpos = bpos + bsiz
		
		--print(apos, bpos)
		
		if apos.x > bpos.x or apos.y > bpos.y then
			return false
		end
	end	
		
	return true
end

function PANEL:Draw()		
	
	if self:IsVisible() and self:VisibleInsideParent() and not self.DrawManual then
		self:Think()
		self:Animate()
		
		if self.Clip then
			aahh.StartClip(self)
		end
		
		aahh.StartDraw(self)
			self:OnDraw(self:GetSize())
			self:OnPostDraw(self:GetSize())

			if not self.HideChildren then
				for key, pnl in ipairs(self:GetChildren()) do
					pnl:Draw()
				end
			end
		aahh.EndDraw(self)
	end
end
	
function PANEL:CalcCursor()	end

function PANEL:Think()
	if self.LayMeOut then
		self:RequestLayout(true)
	end

	local mousepos = aahh.GetMousePos()
			
--		if self.OnMouseMove then
		-- Check if the mouse has moved
		if not self.lastmousepos or self.lastmousepos ~= mousepos then
			self.lastmousepos = mousepos
			-- Get local position
			local localpos = mousepos - self:GetWorldPos()
			
			-- Check if it is in panel
			if self:IsWorldPosInside(mousepos) then				
				-- Make a call
				self:OnMouseMove(localpos, true)
				
				if not self.mouse_entered then
					self:OnMouseEntered(localpos)
					self.mouse_entered = true
				end
				
				aahh.HoveringPanel = self
			else
				if aahh.HoveringPanel == self then
					aahh.HoveringPanel = NULL
				end
				
				self:OnMouseMove(localpos, false)
				
				if self.mouse_entered then
					self:OnMouseLeft(localpos)
					self.mouse_entered = false
				end
			end
		end
	--end
			
	self:OnThink()
end

do -- animation
	function PANEL:Animate()
		if not self.Animations then return end
		
		local delta = math.min(FT, 1)
		local data = self.Animations
		for key, data in pairs(self.Animations) do
			if data and data.begin < os.clock() then
				data.current = data.current + (data.speed * delta) ^ data.exp
				
				if data.calc(self, data.current, data) == true then
					data.calc(self, 1, data)
					self.Animations[key] = nil
					if data.done_func then
						data.done_func(self, data)
					end
				end
			end
		end
	end
	
	local function ADD_ANIM(name, original, callback)
		PANEL[name] = function(self, target, speed, delay, exp, done_func)
			speed = speed or 0.25
			delay = delay or 0
			exp = exp or 1
			
			self.Animations = self.Animations or {}
			self.Animations[name] = 
			{
				begin = os.clock() + delay,
				current = 0,
				original = original(self),
				calc = callback,
				done_func = done_func,
				
				target = target, 
				speed = speed, 
				delay = delay, 
				exp = exp
			}
		end
	end
	 
	ADD_ANIM(
		"MoveTo",
		function(self) 
			return self:GetPos() 
		end, 
		function(self, lerp, data) 
			self:SetPos(data.original:Lerp(lerp, data.target))
			return lerp > 1
		end
	)
	ADD_ANIM(
		"SizeTo",
		function(self) 
			return self:GetSize() 
		end, 
		function(self, lerp, data) 
			self:SetSize(data.original:Lerp(lerp, data.target)) 
			return lerp > 1
		end
	)
	
	function PANEL:RectTo(rect, ...)
		self:MoveTo(Vec2(rect.x, rect.y), ...)
		self:SizeTo(Vec2(rect.w, rect.h), ...)
	end
	
	function PANEL:ExpandLocallyTo(rect, ...)
		local pos = Vec2(rect.x, rect.y)
		local siz = Vec2(rect.w, rect.h)
		
		self:MoveTo(self:GetPos() + pos, ...)
		self:SizeTo(self:GetSize() + siz * 2, ...)
	end
end

function PANEL:IsValid()
	return true
end

do -- events
	function PANEL:Initialize() end
	function PANEL:OnRemove() end
	
	function PANEL:Remove(now)			
		if not self.remove_me then
			table.insert(aahh.remove_these, self)
			self.remove_me = true
		end
		
		if now then		
			self:OnRemove()
			self:RemoveChildren()
			
			if self:HasParent() then
				self:GetParent():UnparentChild(self)
			end
			
			for k,v in pairs(aahh.active_panels) do
				if v == self then
					table.remove(aahh.active_panels, k)
					break
				end
			end
			
			utilities.MakeNULL(self)		
		end
	end
	
	function PANEL:OnThink()	end
	function PANEL:OnParent() end
	function PANEL:OnChildAdd() end
	function PANEL:OnUnParent() end
	
	function PANEL:OnHide() end
	function PANEL:OnShow() end
	
	function PANEL:OnMouseMove() end
end

aahh.Stats = 
{
	layout_count = 0
}

function PANEL:RequestLayout(now)		
	if not self:IsVisible() then
		now = false
	end

	if not now then
		for i, pnl in pairs(self:GetChildren()) do
			pnl:RequestLayout()
		end
		
		self.LayMeOut = true
		
		return
	end
		
	if self.SKIP_LAYOUT then return end
			
	if now then
		for i, pnl in pairs(self:GetChildren()) do
			pnl:RequestLayout(true)
		end
	end
	
	self:CalcTrap()
	
	aahh.Stats.layout_count = aahh.Stats.layout_count + 1
	
	if self:HasParent() or self == aahh.World then 
		self:OnRequestLayout(self.Parent, self:GetSize())
	end

	self:DockLayout()
	
	self.LayMeOut = false
end

function PANEL:RequestParentLayout(...)
	if self:HasParent() then
		self.Parent:RequestLayout(...)
	end
end

function PANEL:SkinCall(func_name, ...)
	return aahh.SkinCall(self, func_name, self.Skin, ...)
end

function PANEL:DrawHook(func_name, ...)
	return aahh.SkinDrawHook(self, func_name, self.Skin, ...)
end

function PANEL:LayoutHook(func_name, ...)
	return aahh.SkinLayoutHook(self, func_name, self.Skin, ...)
end

function PANEL:GetSkinVar(key, def)
	return aahh.GetSkinVar(key, self.Skin) or def
end

function PANEL:OnKeyInput(key, press) end
function PANEL:OnCharInput(key, press) end
function PANEL:OnMouseInput(key, press, pos) end
function PANEL:OnMouseEntered(pos) end
function PANEL:OnMouseLeft(pos) end
function PANEL:OnThink() end
function PANEL:OnDraw() end
function PANEL:OnPostDraw() end
function PANEL:OnRequestLayout() end
function PANEL:OnRemove() end
function PANEL:OnFocusLost() end

aahh.RegisterPanel(PANEL)