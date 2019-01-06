local bsocket = require("bsocket")

table.print(bsocket.get_address_info({
    host = "www.google.com",
}))