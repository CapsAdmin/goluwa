function Gif(path)
	local self = utilities.CreateBaseObject("gif")	

	local data = vfs.Read(path, "rb")
	local frames = freeimage.LoadMultiPageImage(data)
	
	local w, h = 0, 0
	for i, frame in pairs(frames) do
		if frame.w > w then w = frame.w end
		if frame.h > h then h = frame.h end
		
		frames[i] = Texture(frame.w, frame.h, frame.data)
		frames[i].x = frame.x
		frames[i].y = frame.y
		frames[i].ms = frame.ms
	end
	
	local frame_count = #frames
	local frame_speed = 15
	
	function self:GetFrameCount()
		return frame_count
	end
	
	function self:SetFPS(fps)
		frame_speed = fps
	end
	
	function self:GetTexture(num)
		return frames[math.ceil(num%frame_count)]
	end
	
	function self:GetTextures()
		return frames
	end
	
	function self:Draw(x, y)
		local tex = self:GetTexture(timer.clock() * frame_speed)
		surface.SetTexture(tex)

		surface.DrawRect(x, y, tex.w, tex.h)
	end
	
	function self:OnRemove()
		for _, tex in pairs(frames) do
			tex:Remove()
		end
	end
	
	return self
end