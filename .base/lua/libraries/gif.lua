local META = utilities.CreateBaseMeta("gif")
META.__index = META

function META:GetFrameCount()
	return self.frame_count
end

function META:SetFPS(fps)
	self.frame_speed = fps
end

function META:GetTexture(num)
	if self.error then return render.GetErrorTexture() end
	if self.loading then return render.GetLoadingTexture() end
	return self.frames[math.ceil(math.clamp(num%self.frame_count, 1, self.frame_count))]
end

function META:GetTextures()
	return self.frames
end

function META:Draw(x, y)
	local tex = self:GetTexture(os.clock() * self.frame_speed)
	surface.SetTexture(tex)

	surface.DrawRect(x, y, tex.w, tex.h)
end
	
function Gif(path)
	local self = setmetatable({}, META)
		
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
		
	return self
end