local vpk = steam.GetGamePath("Counter-Strike Global Offensive") .. "/csgo/pak01_dir.vpk"

local file, err = vfs.Open("os:" .. vpk)
local meta = vfs.GetFileSystem("valve package")
local self = {tree = utility.CreateTree("/"), AddEntry = meta.AddEntry}
P("parse vpk")
	meta.OnParseArchive(self, file)
P()
file:Close()

table.print(self.tree.tree["sound"]["radio"]["hosdown.wav"])

P("save vpk")
	serializer.WriteFile("msgpack", "test", self.tree.tree)
P()

P("read saved vpk")
	serializer.ReadFile("msgpack", "test")
P()
