surface.CreateFont("lol", {
	path = "fonts/unifont.ttf",
	size = 14,
})
surface.SetFont("lol")
local function split_text(str, max_width)	 
	local lines = {}
	local last_pos = 0
	local line_width = 0
	local found = false
	
	local space_pos
		
	for pos, char in pairs(str:utotable()) do		
		local w, h = surface.GetTextSize(char)

		if char:find("%s") then
			space_pos = pos
		end

		if line_width + w >= max_width then
			
			if space_pos then
				table.insert(lines, str:sub(last_pos+1, space_pos))
				last_pos = space_pos
			else
				table.insert(lines, str:sub(last_pos+1, pos))
				last_pos = pos
			end		
			
			line_width = 0
			found = true
			space_pos = nil
		else
			line_width = line_width + w
		end
	end
	
	if found then
		table.insert(lines, str:sub(last_pos+1, pos))
	else
		table.insert(lines, str)
	end
	 
	return lines
end

local function check_char_table_cache(line)
	if not line.tbl then 
		local tbl = {}
		local x = 0
		
		for pos, char in pairs(line.str:utotable()) do
			local w, h = surface.GetTextSize(char)
			x = x + w
			tbl[pos] = {char = char, pos = pos, x = x, w = w, h = h}
		end
		
		line.tbl = tbl
	end
end

local function draw_text(str, max_width, fixed_height)
	
	local lines = str:explode("\n")
	local markup = {w = 0, h = 0, data = {}}	
	local height = 0
		
	local temp = {}
	
	for i, line in pairs(lines) do
		if max_width then
			for _, str in pairs(split_text(line, max_width)) do
				local w, h = surface.GetTextSize(str)
				table.insert(temp, {str = str, w = w, h = h, x = 0, y = 0})
				if fixed_height and h > height then height = h end
			end		
		else
			local w, h = surface.GetTextSize(line)
			table.insert(temp, {str = line, w = w, h = h, x = 0, y = 0})
			if fixed_height and h > height then height = h end
		end
	end
	
	local y = 0

	for i, data in pairs(temp) do	 
		data.y = y
		data.i = i
		
		if fixed_height then
			y = y + height
			data.h = height
		else
			y = y + data.h + 5
		end
		
		markup.h = markup.h + data.h
		
		table.insert(markup.data, data)
	end
	
	local mouse_down
	local selected_pos
	
	local caret_pos = Vec2(0, 0)
	local mouse_pos = Vec2(0, 0)
			
	local selected_line
	local selected_char
	local last_selected_line
	
	event.AddListener("OnMouseInput", "hhh", function(key, press)
		if key == "button_1" then
			if press then
				mouse_pos = window.GetMousePos()
			else
				last_selected_line = nil
			end

			mouse_down = press
		end
	end)

	event.AddListener("OnDraw2D", "hhh", function()	
		surface.Color(0.1, 0.1, 0.1, 1)
		surface.SetWhiteTexture()
		surface.DrawRect(0, 0, 10000, 10000)
	
		if max_width then
			surface.Color(1,1,1,0.25)
			surface.DrawLine(max_width, 0, max_width, 1000)
		end
		
		for i, data in pairs(markup.data) do
					
			surface.Color(1, 1, 1, 1)
			surface.SetTextPos(data.x, data.y)
			surface.DrawText(data.str)	
		
			if mouse_pos.y > data.y then
				selected_line = data
			end
			
			if mouse_down then 
				selected_pos = window.GetMousePos()
				local first_char
	
				if 
					(mouse_pos.y < data.y and selected_pos.y > data.y + data.h ) or
					(mouse_pos.y < data.y and selected_pos.y > data.y) or
					(mouse_pos.y > data.y and selected_pos.y < data.y)
				then			
					check_char_table_cache(data)
					
					local w = 0
					local x = 0
										
					for pos, char in pairs(data.tbl) do
						if not first_char and char.x > mouse_pos.x then
							first_char = data.tbl[pos-1]
						end
						
						if char.x < selected_pos.x and char.x > mouse_pos.x then
							w = w + char.w
						elseif char.x > selected_pos.x and char.x < mouse_pos.x then
							x = x - char.w
							w = w + char.w
						end
					end
						
					if first_char then
						surface.SetWhiteTexture()
						surface.Color(1, 1, 1, 0.25)
						surface.DrawRect(first_char.x + x, data.y, w, data.h)
					end
				end
			end
		end		

		if selected_line then
			surface.SetWhiteTexture()
			surface.Color(1, 1, 1, 0.125)
			surface.DrawRect(selected_line.x, selected_line.y, selected_line.w + 10000, selected_line.h)
			
			caret_pos.y = selected_line.i
			
			check_char_table_cache(selected_line)
			
			for pos, char in pairs(selected_line.tbl) do
				if char.x < mouse_pos.x then
					selected_char = selected_line.tbl[pos+1] 
				end
			end
			
			if not selected_char then
				selected_char = selected_line.tbl[1]
			end
			
			if selected_char then
				surface.SetWhiteTexture()
				surface.Color(1, 1, 1, (math.sin(os.clock()*16)+1)^4)
				surface.DrawRect(selected_char.x - 2, selected_line.y, 1, selected_line.h) 
				
				caret_pos.x = selected_char.pos
			end
		end
	end)
end

STR = STR or ""

for i = 1, math.random(20, 50) do
	local line = ""
	for i = 1, math.random(30, 100) do
		line = line .. string.char(math.random(34, 120))
	end
	STR = STR .. line .. "\n"
end 

STR = vfs.Read("lua/textbox.lua")

timer.Create("lol", 0,1,function()
	draw_text(STR, 500, true)--window.GetMousePos().x)--500 + math.sin(glfw.GetTime()))
end)
window.Open()  