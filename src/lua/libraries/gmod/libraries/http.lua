function gmod.env.HTTP(tbl)
	if tbl.parameters then
		warning("NYI parameters")
		table.print(tbl.parameters)
	end

	if tbl.headers then
		warning("NYI headers")
		table.print(tbl.headers)
	end

	if tbl.body then
		warning("NYI body")
		print(tbl.headers)
	end

	if tbl.type then
		warning("NYI type")
		print(tbl.type)
	end

	sockets.Request({
		url = tbl.url,
		callback = tbl.success,
		on_fail = tbl.failed,
		method = tbl.method:upper(),
	})
end