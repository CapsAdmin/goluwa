do -- wait
	local temp = {}
	
	function wait(seconds, frames)
		local time = timer.clock()
		if not temp[seconds] or (temp[seconds] + seconds) < time then
			temp[seconds] = timer.clock()
			return true
		end
		return false
	end
end
