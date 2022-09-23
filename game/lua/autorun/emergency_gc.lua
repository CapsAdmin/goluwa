local limit = os.getenv("GOLUWA_MEMORY_LIMIT")

if not limit and #tostring({}) == 10 then limit = 900 end

if limit then
	local kb_limit = limit * 1024
	local VERBOSE = VERBOSE

	timer.Thinker(
		function()
			if collectgarbage("count") > kb_limit then
				collectgarbage()

				if VERBOSE then llog("emergency gc!") end
			end
		end,
		false,
		1 / 10
	)
end