--[[--
  Use this file to specify System preferences.
  Review [examples](+C:\goluwa\.zbstudio\cfg\user-sample.lua) or check [online documentation](http://studio.zerobrane.com/documentation.html) for details.
--]]--
path.wdir = [[C:\goluwa\.base\bin\windows\x86\]]
path.gslshell = [[C:\goluwa\.base\bin\windows\x86\luajit.exe]]
editor.usetabs = true
editor.tabwidth = 4

local G = ...
styles = G.loadfile('cfg/tomorrow.lua')('TomorrowNightEighties')
stylesoutshell = styles -- apply the same scheme to Output/Console windows
styles.auxwindow = styles.text -- apply text colors to auxiliary windows
styles.calltip = styles.text -- apply text colors to tooltips