function Gif(path)
	local self = utilities.CreateBaseObject("gif")	
		
	self.frames = {}
	self.frame_count = 1
	self.frame_speed = 15
	
	self.loading = true

	vfs.ReadAsync(path, function(data)
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
		
		self.frames = frames
		self.frame_count = #frames
		self.loading = false
		
		if self.frame_count == 0 then
			self.error = true
		end
	end)
	
	function self:GetFrameCount()
		return self.frame_count
	end
	
	function self:SetFPS(fps)
		self.frame_speed = fps
	end
	
	function self:GetTexture(num)
		if self.error then return render.GetErrorTexture() end
		if self.loading then return render.GetLoadingTexture() end
		return self.frames[math.ceil(math.clamp(num%self.frame_count, 1, self.frame_count))]
	end
	
	function self:GetTextures()
		return self.frames
	end
	
	function self:Draw(x, y)
		local tex = self:GetTexture(os.clock() * self.frame_speed)
		surface.SetTexture(tex)

		surface.DrawRect(x, y, tex.w, tex.h)
	end
	
	function self:OnRemove()
		for _, tex in pairs(self.frames) do
			if tex:IsValid() then -- might've been garbage collected
				tex:Remove()
			end
		end
	end
	
	return self
end