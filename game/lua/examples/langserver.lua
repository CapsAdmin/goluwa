local JSON_RPC_VERSION = "2.0"

-- Constants as defined by the JSON-RPC 2.0 specification
local JSON_RPC_ERROR = {
	PARSE = {
		code = -32700,
		message = "Parse error",
	},
	REQUEST = {
		code = -32600,
		message = "Invalid request",
	},
	UNKNOWN_METHOD = {
		code = -32601,
		message = "Unknown method",
	},
	INVALID_PARAMS = {
		code = -32602,
		message = "Invalid parameters",
	},
	INTERNAL_ERROR = {
		code = -32603,
		message = "Internal error",
	},
	SERVER_NOT_INITALIZED = {
		code = -32002,
		message = "Server not initialized",
	},
	UNKNOWN_ERROR = {
		code = -32001,
		message = "Unknown error"
	},
	REQUEST_CANCELLED = {
		code = -32800,
		message = "Request Cancelled"
	},
	-- -32000 to -32099 is reserved for implementation-defined server-errors
}

local LSP_ERROR = -32000

-- LSP Protocol constants
local DiagnosticSeverity = {
	Error = 1,
	Warning = 2,
	Information = 3,
	Hint = 4,
}

local TextDocumentSyncKind = {
	None = 0,
	Full = 1,
	Incremental = 2,
}

local MessageType = {
	Error = 1,
	Warning = 2,
	Info = 3,
	Log = 4,
}

local FileChangeType = {
	Created = 1,
	Changed = 2,
	Deleted = 3,
}

local CompletionItemKind = {
	Text = 1,
	Method = 2,
	Function = 3,
	Constructor = 4,
	Field = 5,
	Variable = 6,
	Class = 7,
	Interface = 8,
	Module = 9,
	Property = 10,
	Unit = 11,
	Value = 12,
	Enum = 13,
	Keyword = 14,
	Snippet = 15,
	Color = 16,
	File = 17,
	Reference = 18,
}

-- LSP line and character indecies are zero-based
local function position(line, column)
	return { line = line-1, character = column-1 }
end

local function range(s, e)
	return { start = s, ['end'] = e }
end

local server = LOLSERVER

if not server then
    server = sockets.TCPServer()
    server:Host("*", 1337)
end

function server:OnClientConnected(client)
    function client:OnReceiveChunk(str)
        local header = str:match("^(Content%-Length: %d+%s+)")
        local size = header:match("Length: (%d+)")
        
        local chunk = str:sub(#header+1, #header + size)
        local next = str:sub(#header + size + 1, #str)
        if next ~= "" then
            self:OnReceiveChunk(next)
        end
        
        local ok, err = pcall(function() 
            server:OnReceive(chunk, client)
        end) if not ok then print(err) end
    end
end 

function server:OnReceive(str, client)
    local resp = serializer.Decode("json", str)
    self:HandleMessage(resp, client)
end

function server:Respond(client, res, id)
    local encoded = serializer.Encode("json", {
        jsonrpc = "2.0",
        result = res,
        id = id
    })
    local msg = string.format("Content-Length: %d\r\nContent-Type: application/vscode-jsonrpc; charset=utf-8\r\n\r\n%s", #encoded, encoded)
    client:Send(msg)
end

function server:HandleMessage(resp, client)
    table.print(resp)
    if resp.id then
        if resp.method == "textDocument/hover" then
            local content = vfs.Read(resp.params.textDocument.uri:replace("file://", ""))
            local ast, tokens = oh.lua.CodeToAST(content, resp.params.textDocument.uri)
            
            local line, char = resp.params.position.line, resp.params.position.character

            do
                local code = content:replace("\r", "")
                
                local pos = 0
                for i, str in ipairs(code:split("\n")) do
                    if i < line+1 then
                        pos = pos + str:ulen()+1
                    end
                    if i == line+1 then
                        pos = pos + char
                        break
                    end
                end
                
                for _, token in ipairs(tokens) do
                    --print(pos, token.start, token.stop, pos >= token.start, pos <= token.stop, token.value)
                    if pos >= token.start and pos <= token.stop then
                        self:Respond(client, {
                            contents = serializer.GetLibrary("luadata").ToString(token.ast_node, {tab_limit = max_level, done = {}}),
                        }, resp.id)
                        return
                    end
                end
            end    
            
            self:Respond(client, {
                contents = "",
            }, resp.id)
           
        elseif resp.method == "initialize" then
            self:Respond(client, {
                capabilities = {
                    textDocumentSync = TextDocumentSyncKind.Full,
                    hoverProvider = true,
                    completionProvider = {
                        resolveProvider = false,
                        triggerCharacters = { ".", ":" },
                    },
                    signatureHelpProvider = {
                        triggerCharacters = { "(" },
                    },
                    definitionProvider = true,
                    referencesProvider = true,
                    documentHighlightProvider = false,
                    documentSymbolProvider = false,
                    workspaceSymbolProvider = false,
                    codeActionProvider = false,
                --	codeLensProvider = {
                --		resolveProvider = false,
                --	},
                    documentFormattingProvider = false,
                    documentRangeFormattingProvider = false,
                    documentOnTypeFormattingProvider = {
                        firstTriggerCharacter = "}",
                        moreTriggerCharacter = { "end" },
                    },
                    renameProvider = true,
                }
            }, resp.id)
        end
    end
end

LOLSERVER = server