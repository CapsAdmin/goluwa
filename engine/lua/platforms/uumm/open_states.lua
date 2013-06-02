if CLIENT then
	mmyy.SetWindowTitle("CLIENT")
	system.Connect("10.0.2.15", 27000)
	mmyy.CreateConsole("CLIENT CONSOLE")
end

if SERVER then
	mmyy.SetWindowTitle("SERVER")
	system.StartServer("*", 27000)
	mmyy.CreateConsole("SERVER CONSOLE")
end