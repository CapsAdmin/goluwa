local gui = ... or _G.gui

local META = {}

META.ClassName = "wire_board"
META.Base = "base"

function META:Initialize()
	self.cable_texture = render.CreateTextureFromPath("materials/cable/cable.vtf")
	self.current_wires = {}

	self:SetStyle("frame")
	self:SetResizable(true)
	self:SetDraggable(true)
end

function META:OnPostDraw()
	surface.SetColor(1,1,1,1)
	surface.SetTexture(self.cable_texture)

	if self.connection_point then
		local a_pos = self.connection_point:GetPosition() + self.connection_point:GetParent():GetPosition() + self.connection_point:GetSize() / 2
		local b_pos = self:GetMousePosition()

		if b_pos.x > 0 and b_pos.y > 0 and b_pos.x < self:GetWidth() and b_pos.y < self:GetHeight()  then
			local offset = (a_pos.x - b_pos.x) / 2
			local offset2 = (a_pos.y - b_pos.y) / 2


			surface.DrawLine(a_pos.x - offset, b_pos.y, b_pos.x, b_pos.y, 4, true)
			surface.DrawLine(a_pos.x - offset, b_pos.y, a_pos.x - offset, a_pos.y, 4, true)
			surface.DrawLine(b_pos.x + offset, a_pos.y, a_pos.x, a_pos.y, 4, true)
		else
			surface.DrawLine(a_pos.x, a_pos.y, b_pos.x, b_pos.y, 4, true)
		end

		if input.IsMouseDown("button_2") then
			self.connection_point = nil
		end
	end

	for a, b in pairs(self.current_wires) do
		if not a:IsValid() then self.current_wires[a] = nil goto continue end
		if not b:IsValid() then self.current_wires[a] = nil goto continue end

		local b_pos = a:GetPosition() + a:GetParent():GetPosition() + a:GetSize() / 2
		local a_pos = b:GetPosition() + b:GetParent():GetPosition() + b:GetSize() / 2

		if true then

			--local a_dir = (a:GetParent():GetWorldPosition() - a_pos):Normalize()
			--local b_dir = (b:GetParent():GetWorldPosition() - b_pos):Normalize()

			--local dot = a_pos:GetDot(b_pos)

			local offset = (a_pos.x - b_pos.x) / 2
			local offset2 = (a_pos.y - b_pos.y) / 2


			surface.DrawLine(a_pos.x - offset, b_pos.y, b_pos.x, b_pos.y, 4, true)
			surface.DrawLine(a_pos.x - offset, b_pos.y, a_pos.x - offset, a_pos.y, 4, true)
			surface.DrawLine(b_pos.x + offset, a_pos.y, a_pos.x, a_pos.y, 4, true)
		else
			surface.DrawLine(a_pos.x, a_pos.y, b_pos.x, b_pos.y, 2, true)
		end

		::continue::
	end
end

gui.RegisterPanel(META)