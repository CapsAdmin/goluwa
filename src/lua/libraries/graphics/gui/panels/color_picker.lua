local gui = ... or _G.gui

local META = {}

META.ClassName = "color_picker"

prototype.GetSet(META, "Color", Color(1,1,1,1))
prototype.GetSet(META, "Hue", 0)
prototype.GetSet(META, "Saturation", 1)
prototype.GetSet(META, "Value", 1)
prototype.GetSet(META, "Pallete", "textures/gui/hsv_wheel.png")

function META:SetValue(val)
	self.Value = val
	self:Invalidate()
end

function META:SetSaturation(sat)
	self.Saturation = sat
	self:Invalidate()
end

function META:SetHue(hue)
	self.Hue = hue
	self:Invalidate()
end

function META:SetColor(color)
	self.Color = color
	self:Invalidate(color)
end

function META:Invalidate(override)
	local color = override or ColorHSV(self:GetHue(), self:GetSaturation(), self:GetValue())

	self.Color = color

	self:OnColorChanged(color)
	self.xy_slider:SetFraction(self:ColorToPos(color)/self.xy_slider.line:GetTexture():GetSize())
end

function META:ColorToPos(color)
	if not self.lookup_tree then return Vec2(0,0) end

	local r,g,b,a = (color*255):Round():Unpack()
	a = a * 255

	if
		self.lookup_tree[r] and
		self.lookup_tree[r][g] and
		self.lookup_tree[r][g][b] and
		self.lookup_tree[r][g][b][a]
	then
		return self.lookup_tree[r][g][b][a]
	end

	return Vec2(0, 0)
end

function META:PosToColor(pos)
	return ColorBytes(self.xy_slider.line:GetTexture():GetPixelColor(pos:Unpack()))
end

function META:SetPallete(path)
	local tex = render.CreateTextureFromPath(path)

	self.lookup_tree = nil

	local function on_load(tex, w, h)
		local tree = {}

		for x = 0, w do
			for y = 0, h do
				local r,g,b,a = tex:GetPixelColor(x,y)

				tree[r] = tree[r] or {}
				tree[r][g] = tree[r][g] or {}
				tree[r][g][b] = tree[r][g][b] or {}
				tree[r][g][b][a] = tree[r][g][b][a] or Vec2(x,y)
			end
		end

		self.lookup_tree = tree
	end

	if tex.loading == false then
		on_load(tex, tex:GetSize().x, tex:GetSize().y)
	else
		tex.OnLoad = on_load
	end

	self.text_edit:SetText(path)

	self.xy_slider.line:SetStyle("none")
	self.xy_slider.line:SetTexture(tex)
end

function META:Initialize()
	self:SetNoDraw(true)

	local text = self:CreatePanel("text_edit", true)
	text:SetHeight(17)
	text:SetupLayout("bottom", "fill_x")
	text.OnEnter = function(text)
		self:SetPallete(text:GetText())
	end

	local xy = self:CreatePanel("slider", "xy_slider")
	xy:SetXSlide(true)
	xy:SetYSlide(true)
	xy:SetRightFill(false)

	xy.OnSlide = function(_, pos)
		if xy.suppress then return end
		xy.suppress = true
		pos = (pos * self.xy_slider.line:GetTexture():GetSize()):Round()
		local color = self:PosToColor(pos)
		self:SetColor(color)
		xy.suppress = false
	end

	xy:SetupLayout("center", "fill")

	self:SetPallete(self.Pallete)
end

function META:OnColorChanged(color) end

gui.RegisterPanel(META)

if RELOAD then
	local frame = gui.CreatePanel("frame", nil, "color_picker_test")
	frame:SetSize(Vec2(200, 200))

	local self = frame:CreatePanel("color_picker")
	self:SetupLayout("fill")
	self.OnColorChanged = print
	self:SetColor(print(Color():GetRandom(0,1)))
end
