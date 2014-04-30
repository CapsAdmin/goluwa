:again
luajit.exe -e ARGS={'start_server','host','open\32steam_friends','timer.Delay(0,function()vfs.MonitorEverything(false)end)'}dofile('../../../lua/init.lua')
goto again