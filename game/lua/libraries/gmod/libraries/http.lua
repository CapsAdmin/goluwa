function gine.env.HTTP(tbl)
	local tbl = table.copy(tbl)

	if tbl.type then
		wlog("NYI type")
		print(tbl.type)
	end

	tbl.type = tbl.type or "text/plain; charset=utf-8"

	sockets.Request({
		url = tbl.url,
		callback = function(data) tbl.success(data.code, data.content, data.header) end,
		on_fail = tbl.failed,
		method = (tbl.method or "get"):upper(),
		header = tbl.headers,
		post_data = tbl.body or tbl.parameters,
	})
end
