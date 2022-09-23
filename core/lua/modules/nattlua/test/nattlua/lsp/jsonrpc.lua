local rpc_util = require("nattlua.other.jsonrpc")
local json = require("nattlua.other.json")
local receive_json = rpc_util.ReceiveJSON

do
	local T = require("test.helpers")
	local TableEqual = T.TableEqual

	local function equal_json(a, b)
		if type(a) == "table" then a = json.encode(a) end

		if type(b) == "table" then b = json.encode(b) end

		if not TableEqual(json.decode(a), json.decode(b)) then
			error(a .. "\n~=\n" .. b, 2)
		end
	end

	local LSP = {}
	LSP["subtract"] = function(params)
		return params[1] - params[2]
	end
	LSP["subtract2"] = function(params)
		return params.a - params.b
	end
	LSP["notify"] = function(params) --print("got update", table.unpack(params))
	end

	local function receive(json)
		return receive_json(json, LSP)
	end

	do
		equal_json(
			receive([[{"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}]]),
			[[{"jsonrpc":"2.0","result":19,"id":1}]]
		)
		equal_json(
			receive([[{"jsonrpc": "2.0", "method": "subtract", "params": [23, 42], "id": 2}]]),
			[[{"jsonrpc": "2.0", "result": -19, "id": 2}]]
		)
		equal_json(
			receive([[{"jsonrpc": "2.0", "method": "subtract2", "params": {"a": 23, "b": 42}, "id": 3}]]),
			[[{"jsonrpc":"2.0","result":-19,"id":3}]]
		)
		equal_json(
			receive([[{"jsonrpc": "2.0", "method": "subtract2", "params": {"a": 42, "b": 23}, "id": 4}]]),
			[[{"jsonrpc": "2.0", "result": 19, "id": 4}]]
		)
	end

	equal(receive([[{"jsonrpc": "2.0", "method": "notify", "params": [1,2,3,4,5]}]]), nil)
	equal_json(
		receive([[{"jsonrpc": "2.0", "method": "foobar", "id": "1"}]]),
		[[{"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method foobar not found."}, "id": "1"}]]
	)
	equal_json(
		receive([[{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]   ]]),
		[[{"jsonrpc": "2.0", "error": {"code": -32700, "message": "expected '}' or ',' at line 1 col 41"}, "id": null}]]
	)
	equal_json(
		receive([[{"jsonrpc": "2.0", "method": 1, "params": "bar"}]]),
		[[{"jsonrpc": "2.0", "error": {"code": -32600, "message": "method must be a string"}, "id": null}]]
	)
	equal_json(
		receive([=[[
        {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1},
        {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 2},
        {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 3},
    ]]=]),
		[=[[{"jsonrpc":"2.0","result":19,"id":1}, {"jsonrpc":"2.0","result":19,"id":2},{"jsonrpc":"2.0","result":19,"id":3}]]=]
	)
	equal_json(
		receive([=[[]]=]),
		[[{"jsonrpc": "2.0", "error": {"code": -32600, "message": "empty batch array request"}, "id": null}]]
	)
	equal(
		receive([=[[
            {"jsonrpc": "2.0", "method": "notify", "params": [1,2,4]},
            {"jsonrpc": "2.0", "method": "notify", "params": [7]}
        ]]=]),
		nil
	)
	equal_json(
		receive([=[[
            {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1},
            {"jsonrpc": "2.0", "method": "notify", "params": [1,2,3,4,5]},
            {"jsonrpc": "2.0", "method": 1, "params": "bar"},
            {"jsonrpc": "2.0", "method": "foobar", "id": "1"},
            {"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1},
        ]]=]),
		[=[
            [
                {"result":19,"id":1,"jsonrpc":"2.0"},
                {"error":{"code":-32600,"message":"method must be a string"},"jsonrpc":"2.0"},
                {"id":"1","error":{"code":-32601,"message":"Method foobar not found."},"jsonrpc":"2.0"},
                {"result":19,"id":1,"jsonrpc":"2.0"}
            ]
        ]=]
	)
end

do
	local function write_http(data)
		return ("Content-Length: %s\r\n\r\n%s"):format(#data, data)
	end

	do
		local state = {}
		rpc_util.ReceiveHTTP(state, write_http([[{"jsonrpc": "2.0", "method": "foobar", "id": "1"}]]))
		assert(#state.buffer == 0)
	end

	do
		local state = {}
		local data = [[{"jsonrpc": "2.0", "method": "foobar", "id": "1"}]]
		assert(rpc_util.ReceiveHTTP(state, "Content-Length: " .. #data .. "\r\n\r\n") == nil)
		assert(rpc_util.ReceiveHTTP(state, data:sub(1, 19)) == nil)
		assert(rpc_util.ReceiveHTTP(state, data:sub(20)) == data)
	end

	do
		local state = {}
		local body = [[{"jsonrpc": "2.0", "method": "foobar", "id": "1"}]]
		local data = ""

		for i = 1, 3 do
			data = data .. "Content-Length: " .. #body .. "\r\n\r\n" .. body
		end

		assert(rpc_util.ReceiveHTTP(state, data) == body)
		assert(rpc_util.ReceiveHTTP(state, nil) == body)
		assert(rpc_util.ReceiveHTTP(state, nil) == body)
		assert(rpc_util.ReceiveHTTP(state, nil) == nil)
	end
end
