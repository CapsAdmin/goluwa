local sockets = ... or _G.sockets
local META = prototype.CreateTemplate("socket", "http11_client")
META.Base = "tcp_client"
META.Stage = "none"

do
	sockets.MixinHTTP(META)

	function META:OnReceiveChunk(data)
		self:WriteHTTP(data, self.FromClient)
	end

	function META:OnReceiveResponse(method, path) end

	function META:OnReceiveStatus(code, status) end

	function META:OnReceiveHeader(header, raw_header) end

	function META:OnReceiveBodyChunk(chunk) end

	function META:OnReceiveBody(body) end

	function META:OnHTTPEvent(what)
		local ret = nil

		if what == "response" then
			ret = self:OnReceiveResponse(self.http.method, self.http.path)
		elseif what == "status" then
			ret = self:OnReceiveStatus(self.http.code, self.http.status)
		elseif what == "header" then
			ret = self:OnReceiveHeader(self.http.header, self.http.raw_header)
		elseif what == "chunk" then
			ret = self:OnReceiveBodyChunk(self.http.current_body_chunk)
		elseif what == "body" then
			ret = self:OnReceiveBody(self.http.body)
		end

		if ret == false then return false end

		if what == "code" then
			local code = self.http.code

			if not self.NoCodeError and not code:starts_with("2") and not code:starts_with("3") then
				return self:Error(code .. " " .. status)
			end
		elseif what == "header" then
			local header = self.http.header
			local code = self.http.code

			if code and code ~= "304" and code:starts_with("3") and header["location"] then
				self:Redirect(header["location"])
				return false
			end

			if header["connection"] == "close" then
				self:Close()
				return false
			end
		elseif what == "body" then
			self:Close()
		end
	end
end

function META:Request(method, url, header, body)
	local uri, err = sockets.DecodeURI(url)

	if not uri then return uri, err end

	header = header or {}
	self:Connect(uri.host, uri.scheme)
	self:Send(sockets.HTTPRequest(method, uri, header, body))
	self:InitializeHTTPParser()
	self.LocationHistory = self.LocationHistory or {url}
	-- this is for redirect
	self.CurrentRequest = {
		url = url,
		uri = uri,
		header = header,
		method = method,
		body = body,
	}
end

function META:Redirect(location)
	local req = self.CurrentRequest

	if not req then
		return self:Error("tried to redirect when no previous request was made")
	end

	self:assert(self.socket:close())
	self:SocketRestart()

	if location:starts_with("/") then
		local host = req.header.Host or req.uri.host

		if req.uri.port then host = host .. ":" .. req.uri.port end

		location = req.uri.scheme .. "://" .. host .. location
	else
		req.header.Host = nil
	end

	req.uri = sockets.DecodeURI(location)
	self:Connect(req.uri.host, req.uri.scheme)
	self:Send(sockets.HTTPRequest(req.method, req.uri, req.header, req.body))
	self:InitializeHTTPParser()
	list.insert(self.LocationHistory, location)
end

function META:GetRedirectHistory()
	return self.LocationHistory or {}
end

META:Register()

function sockets.HTTPClient(socket)
	local self = META:CreateObject()
	self:Initialize(socket)
	return self
end

function sockets.ConnectedTCP2HTTP(obj)
	setmetatable(obj, prototype.GetRegistered("socket", "http11_client"))
	obj:InitializeHTTPParser()
	obj:OnConnect()
	obj.connected = true
	obj.connecting = false
	obj.FromClient = true
end

if RELOAD then
	sockets.Request(
		{
			url = "https://news.ycombinator.com/item?id=19291558",
			callback = function(tbl)
				table.print(tbl)
			end,
		}
	)
end