luasocket.debug = false

server = utilities.RemoveOldObject(luasocket.Server())

server.port = 1234
server.content_folder = "www"
server.version = "0.1.0"

server.file_types = {
	png = "rb",
	jpg = "rb",
}

function server:OnReceive(str, client)
	local top, rest = str:match("(.-)\n(.+)")
	local type, path, protocol = top:match("(%S-) (/%S-) (%S+)")
	local extension = path:match(".+%.(.+)")
	
	if path == "/" then path = path .. "index.html" end

	path = server.content_folder .. path

	if type == "GET" then
		local data = luasocket.HeaderToTable(rest)

		if vfs.Exists(path) then	
			client:Send(vfs.Read(path, server.file_types[extension]))
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

os.execute("explorer http://localhost:" .. server.port .. "/images/preview.jpg")