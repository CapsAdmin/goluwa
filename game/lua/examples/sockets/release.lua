local token = vfs.Read("/home/caps/github_token")

os.execute("tar --exclude=binaries_downloaded --exclude=al_config.ini --exclude=x64.tar.gz -zcvf x64.tar.gz ./*")

sockets.Get("https://api.github.com/repos/CapsAdmin/goluwa/releases", function(data)
	for i,v in ipairs(serializer.Decode("json", data.content)) do
		if v.tag_name == "linux-binaries" then
			if v.assets and v.assets[1] then
				sockets.Request({
					method = "DELETE",
					url = v.assets[1].url,
					username = "CapsAdmin",
					token = token,
				})
			end
			local data = vfs.Read(e.ROOT_FOLDER .. "data/bin/linux_x64/x64.tar.gz")
			sockets.Request({
				method = "POST",
				url = v.upload_url:match("(.+assets){").."?name=x64.tar.gz",
				post_data = data,
				username = "CapsAdmin",
				token = token,
				header = {
					["Content-Type"] = "application/zip",
					["Content-Length"] = #data,
				},
				callback = table.print,
			})
		end
	end

end)
