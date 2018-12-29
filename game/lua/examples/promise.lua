
http.Download("http://ipv4.download.thinkbroadband.com/512MB.zip"):Then(function(data)
    table.print(data)
end):Catch(function(reason)
    print("Catch: ", reason)
end):Subscribe("chunks", function(chunk)
    print("got chunk: ", #chunk)
end):Subscribe("header", function(header)
    print("got header: ", header)
end)

do return end
local Delay = callback.WrapTask(function(self, delay, num)
    local half = self.callbacks.half
    local resolve = self.callbacks.resolve
    event.Delay(delay*0.5, function() half(delay*0.5, num) end)
    event.Delay(delay, function() resolve(delay, num) end)
end)
if false then

local root = Delay(1, 0)
root:Then(function(delay, num)
    print(delay, num)
    return Delay(delay, num + 1):Then(function(delay, num) print(delay, num) return Delay(delay, num + 1):Then(function()   end) end)
end):Then(function(delay, num) print(delay, num) return Delay(delay, num + 1) end)
:Then(function(delay, num) print(delay, num) end):Catch(function(err) print("error: " .. err) end)

end

local array = {}

for i = 1, 5 do
    array[i] = Delay(math.random())
    if i == 3 then
        array[i]:Then(function() error("ha") end)
    end
end

function callback.WaitForCallbacks(callbacks)
    local counter = #callbacks

    return callback.WrapTask(function(self)
        for _, cb in ipairs(callbacks) do
            cb:Then(function(...)
                counter = counter - 1
                if counter == 0 then
                    self:Resolve()
                end
            end)

            cb:Catch(function(...)
                self:Reject(cb, ...)
            end)
        end
    end)()
end

callback.WaitForCallbacks(array):Then(function() print("everything finished") end):Catch(function(cb, err) print(cb, err) end)

local Download = callback.WrapKeyedTask(function(self, url)
    sockets.Download(url, self.callbacks.resolve, self.callbacks.reject, self.callbacks.chunks, self.callbacks.header)
end, 2)

Download("https://docs.angularjs.org/api/ng/service/$q"):Then(function(data)
    table.print(data)
end):Catch(function(reason)
    print("Catch: ", reason)
end):Subscribe("chunks", function(chunk)
    print("got chunk: ", chunk)
end):Subscribe("header", function(header)
    print("got header: ", header)
end)


Download("LOL"):Catch(function(reason) print("second callback Catch", reason) end)
Download("LOL"):Catch(function(reason) print("second callback Catch", reason) end)
Download("LOL"):Catch(function(reason) print("second callback Catch", reason) end)


local Download = callback.WrapKeyedTask(function(self, url)
    sockets.Download(url, self.callbacks.resolve, self.callbacks.reject, self.callbacks.chunks, self.callbacks.header)
end, 2)


Download("https://docs.angularjs.org/api"):Then(function() print(1) end)
Download("https://docs.angularjs.org/api/ng/service/$q"):Then(function() print(2) end)
Download("https://docs.angularjs.org/api/ng/function/angular.extend"):Then(function() print(3) end)