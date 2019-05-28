do
    local tools = require'websocket.tools'
    local frame = require'websocket.frame'
    local handshake = require'websocket.handshake'

    local sha1 = require'websocket.tools'.sha1
    local base64 = require'websocket.tools'.base64
    local tinsert = table.insert


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


    local guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

    local sec_websocket_accept = function(sec_websocket_key)
      local a = sec_websocket_key..guid
      local sha1 = sha1(a)
      assert((#sha1 % 2) == 0)
      return base64.encode(sha1)
    end

    local server = utility.RemoveOldObject(sockets.TCPServer())

    server:Host("*", 9998)

    function server:OnClientConnected(client)
        local in_header = true

        print("WEBSOCKET: ", client)
        sockets.ConnectedTCP2HTTP(client)

        function client:OnReceiveHeader(headers)
            local prot = nil

            if headers["sec-websocket-protocol"] then
                print(headers["sec-websocket-protocol"], "!!!")
            end
print(headers["connection"])
            self:Respond({
                code = "101 Switching Protocols",
                header = {
                    ["Upgrade"] = "websocket",
                    ["Connection"] = headers["connection"],
                    ["Sec-WebSocket-Accept"] = sec_websocket_accept(headers['sec-websocket-key']),
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
print(opcode)
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
                                print("?!?!??!")
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
            self:Send(frame.encode("WHAT!!!", frame.TEXT))
        end
    end
end


local server = utility.RemoveOldObject(sockets.TCPServer())

server:Host("*", 1235)

function server:OnClientConnected(client)
    sockets.ConnectedTCP2HTTP(client)

    function client:OnReceiveHeader(header)
        self:Respond({
            code = "200 OK",
            body = [[
                <!DOCTYPE HTML>

                <html>
                   <head>
                      <script type = "text/javascript">
                         function WebSocketTest() {

                            if ("WebSocket" in window) {
                               // Let us open a web socket
                               var ws = window.ws_ref || new WebSocket("ws://localhost:9998/echo");

                               ws.onopen = function() {
                                  ws.send("Message to send");
                               };

                               ws.onmessage = function (evt) {
                                  var received_msg = evt.data;
                                  alert("Message is received...");
                               };

                               ws.onerror = function(event) {
                                console.error("WebSocket error observed:", event);
                            };

                               ws.onclose = function(reason) {
                                console.log("closed         ", reason)
                               };

                               window.ws_ref =ws
                            } else {

                               // The browser doesn't support WebSocket
                               alert("WebSocket NOT supported by your Browser!");
                            }
                         }
                      </script>

                   </head>

                   <body>
                      <div id = "sse">
                         <a href = "javascript:WebSocketTest()">Run WebSocket</a>
                      </div>

                   </body>
                </html>
            ]],
        })
    end

    function client:OnReceiveBody(body)
        print(body, "!!")
    end
end