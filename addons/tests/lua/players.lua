if (SERVER) then
	event.AddListener("PlayerKeyEvent", "movement", function(client, key, press)
		print(client, key, press);
	end);

	return;
end;

local window = glw.OpenWindow();
local font = Font("file", R"fonts/arial.ttf");

local points = {};

event.AddListener("OnDraw", "scroller", function()
	surface.SetWindow(window);

	surface.SetFont(font);
	surface.SetTextSize(16);
	surface.SetTextColor(255, 255, 255, 255);

	for k, v in pairs(players.GetAll()) do
		surface.DrawText(v:GetNick().." ("..math.floor(v:GetPing()).." Ping)", 16, 16 + (k - 1)*24);
	end;
end);