--ANALYZE
local type = _G.type
local ipairs = _G.ipairs
local table = _G.table
local xpcall = _G.xpcall
local debug = _G.debug
local pcall = _G.pcall
local tonumber = _G.tonumber
local json = require("nattlua.other.json")
local rpc_util = {}
local VERSION = "2.0"
--[[#type Response = {
	jsonrpc = VERSION,
	id = nil | string,
	result = Table,
	error = nil | {
		code = number,
		message = string,
	},
}]]
local JSONRPC_ERRORS = {
	PARSE_ERROR = -32700, -- Invalid JSON was received by the server. An error occurred on the server while parsing the JSON text.
	INVALID_REQUEST = -32600, -- The JSON sent is not a valid Request object.
	METHOD_NOT_FOUND = -32601, -- The method does not exist / is not available.
	INVALID_PARAMS = -32602, -- Invalid method parameter(s).
	INTERNAL_ERROR = -32603, -- Internal JSON-RPC error.
-- SERVER_ERROR = -32000 to -32099, -- , reserved for implementation-defined server-errors.
}

local function error_response(id--[[#: nil | string]], code--[[#: number]], message--[[#: string]])
	return {
		jsonrpc = VERSION,
		id = id,
		error = {
			code = code,
			message = message,
		},
	}
end

local function check_request(rpc--[[#: Table]])
	if rpc.jsonrpc ~= VERSION then
		return error_response(
			nil,
			JSONRPC_ERRORS.INVALID_REQUEST,
			"this server only accepts jsonrpc version " .. VERSION
		)
	end

	if type(rpc.method) ~= "string" then
		return error_response(nil, JSONRPC_ERRORS.INVALID_REQUEST, "method must be a string")
	end

	do
		local t = type(rpc.id)

		if t ~= "string" and t ~= "number" and t ~= "nil" then
			return error_response(
				nil,
				JSONRPC_ERRORS.INVALID_REQUEST,
				"id must be a string, number or undefined. got " .. t
			)
		end
	end
end

local function handle_rpc(
	rpc--[[#: Table]],
	is_array--[[#: nil | boolean]],
	methods--[[#: {[string] = Function}]],
	...--[[#: ...any]]
)
	if is_array then
		if not rpc[1] then
			return error_response(nil, JSONRPC_ERRORS.INVALID_REQUEST, "empty batch array request")
		end

		local array--[[#: List<|Response|>]] = {}

		for i, v in ipairs(rpc) do
			local response = handle_rpc(v, nil, methods, ...)

			if response then table.insert(array, response) end
		end

		if not array[1] then return end

		return array
	end

	local err = check_request(rpc)

	if err then return err end

	if not methods[rpc.method] then
		return error_response(rpc.id, JSONRPC_ERRORS.METHOD_NOT_FOUND, "Method " .. rpc.method .. " not found.")
	end

	local ok, res, err = xpcall(
		function(...)
			return methods[rpc.method](rpc.params, ...)
		end,
		function(err--[[#: string]])
			return debug.traceback(err)
		end,
		...
	)

	if not ok then
		return error_response(rpc.id, JSONRPC_ERRORS.INTERNAL_ERROR, res)
	end

	-- notification has no response
	if not rpc.id then return end

	if not res then return error_response(rpc.id, err.code, err.message) end

	return {
		jsonrpc = rpc.jsonrpc,
		id = rpc.id,
		result = res,
	}
end

function rpc_util.ReceiveJSON(data--[[#: string]], methods--[[#: {[string] = Function}]], ...--[[#: ...any]])
	local ok, rpc = pcall(json.decode, data)

	if not ok then
		local err = rpc:match("^.+%.lua:%d+: (.+)")
		return error_response(nil, JSONRPC_ERRORS.PARSE_ERROR, err)
	end

	return handle_rpc(rpc--[[# as Table]], data:sub(1, 1) == "[", methods, ...)
end

function rpc_util.ReceiveHTTP(state--[[#: {buffer = string}]], data--[[#: string]])
	state.buffer = state.buffer or ""

	if data then state.buffer = state.buffer .. data end

	local buffer = state.buffer
	local header, rest = buffer:match("^(.-)\r\n\r\n(.*)$")

	if header then
		local length = header:match("Content%-Length: (%d+)")

		if length then
			length = tonumber(length)

			if rest and #rest >= length then
				local body = rest:sub(1, length)
				state.buffer = buffer:sub(#header + 4 + length + 1)
				return body
			end
		end
	end
end

return rpc_util