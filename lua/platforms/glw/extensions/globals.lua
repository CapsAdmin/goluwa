do -- wait
	local temp = {}
	
	function wait(seconds, frames)
		local time = glfw.GetTime()
		if not temp[seconds] or (temp[seconds] + seconds) < time then
			temp[seconds] = glfw.GetTime()
			return true
		end
		return false
	end
end
