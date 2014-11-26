sockets.debug = false

server = utility.RemoveOldObject(sockets.CreateServer())

server.port = 1234
server.content_folder = "www"
server.version = "0.1.0"

server.file_types = {
	default = {
		read_mode = "r",
		mime = "text/html",
	},
	png = {
		read_mode = "rb",
		mime = "image/png",
	},
	jpg = {
		read_mode = "rb",
		mime = "image/jpeg",
	},
	gif = {
		read_mode = "rb",
		mime = "image/gif",
	},
}

function server:OnReceive(str, client)
	local top, rest = str:match("(.-)\n(.+)")
	local type, path, protocol = top:match("(%S-) (/%S-) (%S+)")
	local parameters = {}
	
	if path:find("?") then
		local new_path, param_line = path:match("(.+)?(.+)")
		
		param_line = "&" .. param_line
		
		for key, val in param_line:gmatch("&(.+)=(.+)") do
			parameters[key] = val
		end
		
		path = new_path
	end
	
	local extension = path:match(".+%.(.+)")
	
	if path == "/" then path = path .. "index.html" end
	
	path = server.content_folder .. path

	if type == "GET" then
		local data = sockets.HeaderToTable(rest)

		if vfs.Exists(path) then
			local info = server.file_types[extension] or server.file_types.default
			local data = vfs.Read(path, info.read_mode)
			
			local header = sockets.TableToHeader({
			--	["Content-Type"] = info.mime,
				["Accept-Ranges"] = "bytes",
				["Content-Length"] = #data,
				["Connection"] = "Keep-Alive",
			})
			
			client:Send("HTTP/1.1 200 OK\r\n" .. header .. "\r\n" .. data)
			vfs.Write("data/header.txt", "HTTP/1.1 200 OK\r\n" .. header)
		else
			client:Send(self:NotFound(path)) 
		end
	end
	
	client:CloseWhenDoneSending(true)
end

function server:NotFound(dir)
	return [[
	<html>
		<head>
			<meta content="text/html; charset=ISO-8859-1"
			http-equiv="content-type">
			<title></title>
		</head>
		<body>
			<h1
			style="color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-style: normal; font-variant: normal; letter-spacing: normal; line-height: normal; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px;">Not
			Found</h1>
			<span
			style="color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-size: medium; font-style: normal; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px; display: inline ! important; float: none;">The
			requested URL ]]..dir..[[ was not found on this server.</span><br>
			<br>
			<hr>
			<span
			style="color: rgb(0, 0, 0); font-family: 'Times New Roman'; font-size: medium; font-style: italic; font-variant: normal; font-weight: normal; letter-spacing: normal; line-height: normal; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px; display: inline ! important; float: none;">Lua Webserver/]]..self.version..[[
			(]]..jit.os..[[)</span><br>
			<br>
		</body>
	</html>
	]] 
end

function server:OnClientConnected(client)
	return true
end   

server:Host("*", server.port) 

os.execute("explorer http://localhost:" .. server.port)