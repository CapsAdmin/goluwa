local http_port = 1235
local ws_port = 9998

local ws_server = utility.RemoveOldObject(sockets.TCPServer(), "ws_server")
local http_server = utility.RemoveOldObject(sockets.TCPServer(), "http_server")

do
    local frame = require'websocket.frame'

    local function header_to_table(header)
        local tbl = {}

        if not header then return tbl end

        for _, line in ipairs(header:split("\n")) do
            local key, value = line:match("(.+):%s+(.+)\r")

            if key and value then
                tbl[key:lower()] = tonumber(value) or value
            end
        end

        return tbl
    end

    ws_server:Host("*", ws_port)

    function ws_server:OnClientConnected(client)
        print("WEBSOCKET: ", client)
        sockets.ConnectedTCP2HTTP(client)
--        client.socket:set_option("keepalive", true)
        self.client = client

        function client:OnReceiveHeader(headers)
            self:Respond({
                code = "101 Switching Protocols",
                header = {
                    ["Upgrade"] = "websocket",
                    ["Connection"] = headers["connection"],
                    ["Sec-WebSocket-Accept"] = crypto.Base64Encode(crypto.SHA1(headers['sec-websocket-key'] .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")),
                }
            })

            function self:OnReceiveChunk(str)
                local first_opcode
                local frames = {}

                local encoded = str

                if self.last_encoded then
                    encoded = self.last_encoded .. str
                    self.last_encoded = nil
                end

                repeat
                    local decoded, fin, opcode, rest = frame.decode(encoded)

                    if decoded then
                        if not first_opcode then
                            first_opcode = opcode
                        end
                        table.insert(frames, decoded)
                        encoded = rest
                        if fin == true then
                            local message = table.concat(frames)

                            if first_opcode == frame.CLOSE or opcode == frame.CLOSE then
                                local code, reason = frame.decode_close(message)
                                local encoded = frame.encode_close(code)
                                encoded = frame.encode(encoded, frame.CLOSE, true)
                                self:Send(encoded)
                                self:OnClose(reason, code)
                                self:Remove()
                                return
                            else
                                frames = {}
                                self:OnReceive(message, opcode)
                            end
                        end
                    elseif #encoded > 0 then
                        self.last_encoded = encoded
                    end
                until not decoded
            end
        end
        
        

        function client:OnReceive(body, opcode)
            print(body, "BODY", opcode)
            --event.AddListener("Update", "", function()
                self:Send(frame.encode(body, frame.TEXT))
            --end)
        end
    end
end

do
    http_server:Host("*", http_port)

    function http_server:OnClientConnected(client)
        sockets.ConnectedTCP2HTTP(client)

        function client:OnReceiveHeader(header)
            self:Respond({
                code = "200 OK",
                body = [[<!DOCTYPE HTML>
                    <html>
                        <meta charset="utf-8"/>
                        <script type = "text/javascript">
                            let ws = new WebSocket("ws://localhost:9998");

                            function listen(obj, what) {
                                let old = obj[what]
                                console.log(old, "!!")
                                obj[what] = function(...args) {
                                    if (old) {
                                        old.apply(this, ...args)
                                    }
                                    console.log.apply(this, [what, ": ", ...args])
                                }
                            }

                            ws.onopen = function() {
                                ws.send("hello")
                            }

                            listen(ws, "onopen")
                            listen(ws, "onmessage")
                            listen(ws, "onerror")
                            listen(ws, "onclose")

                            window.ws_ref =ws
                        </script>
                    </html>
                ]],
            })
        end
    end
end