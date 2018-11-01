local rate_cvar = pvars.Setup2({
    key = "system_fps_max",
    default = -1,
    modify = function(num) if num < 1 and num ~= 0 then return -1 end return num end,
    callback = function(rate)
        if window and window.IsOpen() then
            if rate == 0 then
                render.GetWindow():SwapInterval(true)
            else
                render.GetWindow():SwapInterval(false)
            end
        end
    end,
    help = "-1\t=\trun as fast as possible\n 0\t=\tvsync\n+1\t=\t/try/ to run at this framerate (using sleep)",
})

local battery_limit = pvars.Setup("system_battery_limit", true)

do
    local rate = rate_cvar:Get()

    event.Timer("rate_limit", 0.1, 0, function()
        rate = rate_cvar:Get()

        -- todo: user is changing properties in game
        if rate > 0 and GRAPHICS and gui and gui.world and gui.world.options then
            rate = math.max(rate, 10)
        end

        if WINDOW and battery_limit:Get() and system.IsUsingBattery() and system.GetBatteryLevel() < 0.95 then
          --  render.GetWindow():SwapInterval(true)
            if system.GetBatteryLevel() < 0.20 then
                rate = 10
            end
            if not window.IsFocused() then
                rate = 5
            end
        end

        if SERVER then
            rate = 66
        end
    end)

    event.AddListener("FrameEnd", "rate_limit", function()
        if rate > 0 then
            system.Sleep(math.floor(1/rate * 1000))
        end
    end)
end
