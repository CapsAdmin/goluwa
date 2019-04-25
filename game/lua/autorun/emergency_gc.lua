-- emergency garbage collection for 32 bit lua
if #tostring({}) == 10 then
    event.Thinker(function()
        if collectgarbage("count") > 900000 then
            collectgarbage()
            llog("emergency gc!")
        end
    end, false, 1/10)
end 
