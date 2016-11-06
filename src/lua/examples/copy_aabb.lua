camera.camera_3d:SetAngles(Ang3())

local min
local max

event.AddListener("MouseInput", "aabb", function(button, press)
	if button == "button_1" then
		if press then
			min = camera.camera_3d:GetPosition()
		else
			max = camera.camera_3d:GetPosition()
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