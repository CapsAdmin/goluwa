local ffi = require("ffi")
local ljsocket = require("language_server.server.ljsocket")
local lsp = require("language_server.server.lsp")
local json = require("nattlua.other.json")
local rpc_util = require("nattlua.other.jsonrpc")
return function(port)
	port = port or 1337
	_G.VSCODE_PLUGIN = true
	local server = {}
	server.methods = {}

	function server:OnError(msg)
		error(msg)
	end

	function server:OnReceiveBody(client, str)
		table.insert(
			self.responses,
			{
				client = client,
				thread = coroutine.create(function()
					local res = rpc_util.ReceiveJSON(str, self.methods, self, client)

					if res.error then table.print(res) end

					return res
				end),
			}
		)
	end

	function server:Respond(client, res)
		local encoded = json.encode(res)
		local msg = string.format("Content-Length: %d\r\n\r\n%s", #encoded, encoded)
		client:send(msg)
	end

	function server:GetClient()
		if self.client then return self.client end

		local client, err = self.socket:accept()

		if client then
			assert(client:set_blocking(false))
			client:set_option("nodelay", true, "tcp")
			client:set_option("cork", false, "tcp")
			self.client = client
		end

		return self.client
	end

	function server:Loop()
		self.responses = {}
		local socket = assert(ljsocket.create("inet", "stream", "tcp"))
		assert(socket:set_blocking(false))
		socket:set_option("nodelay", true, "tcp")
		socket:set_option("reuseaddr", true)
		assert(socket:bind("*", 0))
		assert(socket:listen())
		local address, port = socket:get_name()
		io.write("HOST: ", address, ":", port .. "\n")
		io.flush()
		self.socket = socket

		while true do
			ffi.C.usleep((1 / 30) * 1000000)
			local client = self:GetClient()

			if client then
				local chunk, err = client:receive()

				if err and err ~= "timeout" then print(client, chunk, err) end

				local body = rpc_util.ReceiveHTTP(client, chunk)

				if body then self:OnReceiveBody(client, body) end

				if not chunk then
					if err == "closed" then
						table.remove(clients, i)
					elseif err ~= "timeout" then
						table.remove(clients, i)
						client:close()
						print("error: ", err)
					end
				end

				for i = #self.responses, 1, -1 do
					local data = self.responses[i]
					local ok, msg = coroutine.resume(data.thread)

					if not ok then
						if msg ~= "suspended" then table.remove(self.responses, i) end
					else
						if type(msg) == "table" or msg == nil then
							self:Respond(data.client, msg or {})
							table.remove(self.responses, i)
						end
					end
				end
			end
		end
	end

	for k, v in pairs(lsp.methods) do
		server.methods[k] = v
	end

	function lsp.Call(params)
		server:Respond(assert(server:GetClient(), "no client connected yet?"), params)
	end

	ffi.cdef("int chdir(const char *filename); int usleep(unsigned int usec);")
	io.stdout:setvbuf("no")
	io.stderr:setvbuf("no")
	io.flush()
	server:Loop()
end