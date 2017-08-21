render3d.camera:SetAngles(Ang3())

local min
local max

function goluwa.MouseInput(button, press)
	if button == "button_1" then
		if press then
			min = render3d.camera:GetPosition()
		else
			max = render3d.camera:GetPosition()
		end

		if min and max then
			min = min:Round()
			max = max:Round()
			local aabb = AABB(min.x, min.y, min.z, max.x, max.y, max.z)
			aabb = tostring(aabb):gsub("%.0+", "")
			print(aabb)
			window.SetClipboard(aabb)
		end
	end
end)