if (not CLIENT) then
	return;
end;

local window = asdfml.OpenWindow();
local font = Font("file", R"fonts/arial.ttf");

local points = {};

event.AddListener("OnDraw", "scroller", function()
	surface.SetWindow(window);

	surface.SetFont(font);
	surface.SetTextSize(16);
	surface.SetTextColor(255, 255, 255, 255);

	local i = 0;

	for k, v in pairs(players.GetAll()) do
		surface.DrawText(v:GetNick(), 16, 16 + i*24);
		i = i + 1;
	end;
end);

table.print( players.GetAll() )