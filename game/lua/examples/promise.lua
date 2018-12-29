
resource.Download("https://avatars1.githubusercontent.com/u/204157?s=52&v=4"):Then(print)

do return end

local Delay = callback.WrapTask(function(self, delay)
    event.Delay(delay, self.callbacks.resolve)
end)

local array = {}

for i = 1, 5 do
    array[i] = Delay(math.random())
    if i == 3 then
        array[i]:Resolved(function() error("ha") end)
    end
end

function callback.WaitForCallbacks(callbacks)
    local counter = #callbacks

    return callback.WrapTask(function(self)
        for _, cb in ipairs(callbacks) do
            cb:Resolved(function(...)
                counter = counter - 1
                if counter == 0 then
                    self:Resolve()
                end
            end)

            cb:Rejected(function(...)
                self:Reject(cb, ...)
            end)
        end
    end)()
end

callback.WaitForCallbacks(array):Resolved(function() print("everything finished") end):Rejected(function(cb, err) print(cb, err) end)

local Download = callback.WrapKeyedTask(function(self, url)
    sockets.Download(url, self.callbacks.resolve, self.callbacks.reject, self.callbacks.chunks, self.callbacks.header)
end, 2)

Download("https://docs.angularjs.org/api/ng/service/$q"):Resolved(function(data)
    table.print(data)
end):Rejected(function(reason)
    print("rejected: ", reason)
end):Subscribe("chunks", function(chunk)
    print("got chunk: ", chunk)
end):Subscribe("header", function(header)
    print("got header: ", header)
end)


Download("LOL"):Rejected(function(reason) print("second callback rejected", reason) end)
Download("LOL"):Rejected(function(reason) print("second callback rejected", reason) end)
Download("LOL"):Rejected(function(reason) print("second callback rejected", reason) end)


local Download = callback.WrapKeyedTask(function(self, url)
    sockets.Download(url, self.callbacks.resolve, self.callbacks.reject, self.callbacks.chunks, self.callbacks.header)
end, 2)


Download("https://docs.angularjs.org/api"):Then(function() print(1) end)
Download("https://docs.angularjs.org/api/ng/service/$q"):Then(function() print(2) end)
Download("https://docs.angularjs.org/api/ng/function/angular.extend"):Then(function() print(3) end)