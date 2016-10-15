function gine.env.HTTP(tbl)
	if tbl.parameters then
		wlog("NYI parameters")
		table.print(tbl.parameters)
	end

	if tbl.headers then
		wlog("NYI headers")
		table.print(tbl.headers)
	end

	if tbl.body then
		wlog("NYI body")
		print(tbl.headers)
	end

	if tbl.type then
		wlog("NYI type")
		print(tbl.type)
	end

	sockets.Request({
		url = tbl.url,
		callback = tbl.success,
		on_fail = tbl.failed,
		method = tbl.method:upper(),
	})
end
