if (window) then 
	print("Closing old console window.");

	window:Close();
end;

local window = asdfml.OpenWindow();

window:SetTitle("Console");
 
local textBuffer = {};
local FONT_ARIAL = Font("file", R"fonts/arial.ttf");
local BORDER = 5;
local lastY = BORDER;
  
function AddConsoleText(...)
	local lastX = BORDER;
	local data = {};
	local lastColor = sfml.Color(255, 255, 255, 255);

	for k, v in ipairs({...}) do
		if (type(v) == "cdata" and v.r and v.g and v.b) then
			lastColor = v;
		else
			local object = Text();
			object:SetString(tostring(v));
			object:SetFont(FONT_ARIAL);
			object:SetCharacterSize(13);
			object:SetPosition(Vector2f(lastX, lastY));
			object:SetColor(lastColor);

			lastX = lastX + object:GetLocalBounds().width;
			
			table.insert(data, object);
		end;
	end;

	lastY = lastY + 16;

	table.insert(textBuffer, data);
end;

event.AddListener("OnClose", "console", function()
	textBuffer = {}
end)

event.AddListener("OnDraw", "drawWindow", function()
	window:Clear(e.BLACK);

	for k, v in ipairs(textBuffer) do
		for k2, v2 in ipairs(v) do
			window:DrawText(v2);
		end;
	end;
end);

event.AddListener("OnResized", "console", function()
	local size = window:GetSize();
	local newY = math.floor(size.y / 16) * 16;

	window:SetSize( Vector2f(size.x, newY) );
end);

for i = 1, 30 do
	AddConsoleText(i)
end;