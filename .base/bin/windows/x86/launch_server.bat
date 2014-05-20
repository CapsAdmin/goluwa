:again
luajit.exe -e ARGS={'start_server','host','open\32steam/steam_friends','event.Delay(0,function()vfs.MonitorEverything(false)end)'}dofile('../../../lua/init.lua')
goto again