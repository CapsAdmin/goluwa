-- redo raycast, gui.RayCast?

local function sort(a, b) return a.distance > b.distance end

local function l2w(panel, pos)
	local x,y = panel.Matrix:TransformVector(pos.x, pos.y, 1)
	return Vec2(x,y)
end

function gui.RayCast(world, start_pos, stop_pos, ray_rect)
	ray_rect = ray_rect or Rect(1,1,1,1)

	start_pos = l2w(world, start_pos)
	stop_pos = l2w(world, stop_pos)

	local a_lft = start_pos.x + ray_rect.x
	local a_top = start_pos.y + ray_rect.y

	local a_rgt = start_pos.x - ray_rect.w
	local a_btm = start_pos.h - ray_rect.h

	local dir = start_pos - stop_pos

	render2d.SetColor(1,1,1,1)

	if dir.x ~= 0 then
		gfx.DrawLine(start_pos.x, a_top, start_pos.x + dir.x, a_top + dir.y)
		gfx.DrawLine(start_pos.x, a_btm, start_pos.x + dir.x, a_btm + dir.y)
	elseif dir.y ~= 0 then
		gfx.DrawLine(a_lft, start_pos.y, a_lft + dir.x, start_pos.y + dir.y)
		gfx.DrawLine(a_rgt, start_pos.y, a_rgt + dir.x, start_pos.y + dir.y)
	end

	local found = {}
	local found_i = 1

	for _, child in ipairs(world:GetChildren()) do
		local b_lft, b_top, b_rgt, b_btm = child:GetWorldRectFast()
		b_lft = b_lft - child.Padding.x
		b_rgt = b_rgt + child.Padding.w

		b_top = b_top - child.Padding.y
		b_btm = b_btm + child.Padding.h

		if
			(
				dir.x ~= 0 and
				-- is the rectangle within upper and lower bounds?
				a_btm < b_btm and a_top > b_top and

				-- is the rectangle within the right side of ray and distance?
				(
					(dir.x < 0 and a_rgt > b_lft and b_rgt - a_rgt > dir.x) or
					(dir.x > 0 and a_lft < b_rgt and b_lft - a_lft < dir.x)
				)
			)
			or
			(
				dir.y ~= 0 and
				-- is the rectangle within upper and lower bounds?
				a_rgt < b_rgt and a_lft > b_lft and

				-- is the rectangle within the right side of ray and distance?
				(
					(dir.y < 0 and a_btm > b_top and b_btm - a_btm > dir.y) or
					(dir.y > 0 and a_top < b_btm and b_top - a_top < dir.y)
				)
			)
		then
			local distance
			local hit_pos_x
			local hit_pos_y
			if dir.x ~= 0 then
				if dir.x < 0 then
					distance = a_rgt - b_lft
					hit_pos_x = b_rgt
				else
					distance = b_rgt - a_lft
					hit_pos_x = b_lft
				end
				hit_pos_y = (a_top - b_top) + b_top
			elseif dir.y ~= 0 then
				if dir.y < 0 then
					distance = a_btm - b_top
					hit_pos_y = b_btm
				else
					distance = b_btm - a_top
					hit_pos_y = b_top
				end
				hit_pos_x = (a_rgt - b_lft) + b_lft
			end
			found[found_i] = {child = child, distance = distance, hit_pos = Vec2(hit_pos_x, hit_pos_y)}
			found_i = found_i + 1

			local x, y = b_lft, b_top

			local offset_x = dir.x ~= 0 and dir.x > 0 and (a_lft - a_rgt) or 0
			local offset_y = dir.y ~= 0 and dir.y < 0 and (a_btm - a_top) or 0

			render2d.SetColor(0,1,0,1)
			gfx.DrawRect(hit_pos_x - offset_x, hit_pos_y - offset_y, a_lft - a_rgt, a_btm - a_top)

			render2d.SetColor(1,1,1,0.5)
			gfx.DrawRect(child.Padding.x + x, child.Padding.y + y, child.Size.x, child.Size.y)

			render2d.SetColor(0,0,0,1)
			gfx.DrawText(distance, hit_pos_x - offset_x, hit_pos_y - offset_y, nil, nil, dir.y > 0 and -1 or -1)
		end
	end
	local b_lft, b_top, b_rgt, b_btm = world:GetWorldRectFast()

	b_lft = b_lft + world.Margin.x
	b_rgt = b_rgt - world.Margin.w

	b_top = b_top + world.Margin.y
	b_btm = b_btm - world.Margin.h


	render2d.SetColor(1,1,0,1)

	gfx.DrawRect(b_lft, b_top, 5,5)

	if
		(
			dir.y ~= 0 and
			(
				((a_btm - b_top < dir.y) and (a_btm - b_top > 0)) or
				((a_top - b_btm > dir.y) and (a_top - b_btm < 0))
			)
		)
		or
		(
			dir.x ~= 0 and
			(
				((a_rgt - b_lft < dir.x) and (a_rgt - b_lft > 0)) or
				((a_lft - b_rgt > dir.x) and (a_lft - b_rgt < 0))
			)

		)
	then
		local hit_pos_x = 0
		local hit_pos_y = 0
		local distance = 0
		if dir.y ~= 0 then
			hit_pos_x = start_pos.x - (a_lft - a_rgt)/2
			if dir.y > 0 then
				distance = start_pos.y
				hit_pos_y = b_top + (ray_rect.w + ray_rect.x)
			else
				--distance = b_btm - a_top
				hit_pos_y = b_btm
			end
		elseif dir.x ~= 0 then
			if dir.x > 0 then
				hit_pos_x = b_lft
			else
				hit_pos_x = b_rgt - (ray_rect.x + ray_rect.w)
			end
			hit_pos_y = start_pos.y - (a_btm - a_top)/2
		end

		render2d.SetColor(0,1,0,1)

		gfx.DrawRect(hit_pos_x, hit_pos_y, a_lft - a_rgt, a_btm - a_top)

		local offset_x = dir.x ~= 0 and dir.x > 0 and (a_lft - a_rgt) or 0
		local offset_y = dir.y ~= 0 and dir.y < 0 and (a_btm - a_top) or 0

		render2d.SetColor(0,0,0,1)
		gfx.DrawText(distance, hit_pos_x - offset_x, hit_pos_y - offset_y, nil, nil, dir.y > 0 and -1 or -1)
	end


	table.sort(found, sort)

	return found
end

local function raycast(panel, pos, dir)
	gui.RayCast(panel, pos, pos + dir, Rect() + 10)

	--gfx.DrawText(tostring(hitpos) .. "\n" .. tostring(hitpanel), stop_pos.x,stop_pos.y, nil, math.clamp(-dir.x, -1, 0))
	--gfx.DrawLine(start_pos.x,start_pos.y, stop_pos.x, stop_pos.y)
end

local prev_panel

event.AddListener("PostDrawGUI", "raycaster", function()
	local panel = input.IsMouseDown("button_1") and prev_panel or gui.GetHoveringPanel()
	prev_panel = panel
	local pos = panel:GetMousePosition()
	local x,y = gfx.GetMousePosition()
	render2d.SetColor(1,1,1,1)
	gfx.SetFont()
	gfx.DrawText(tostring(panel) .. "\n" .. tostring(pos) .. "\n", x,y, nil)

	local length = 300

	raycast(panel, pos, Vec2(length, 0))
	raycast(panel, pos, Vec2(-length, 0))

	raycast(panel, pos, Vec2(0, length))
	raycast(panel, pos, Vec2(0, -length))
	--raycast(panel, pos, Vec2(0, -length))
end)

gui.Panic()

local pnl =  gui.CreatePanel("base")
pnl:SetSize(Vec2()+700)
pnl:SetDraggable(true)

local pnl =  pnl:CreatePanel("base")
pnl:SetDraggable(true)
pnl:SetResizable(true)
pnl:SetMargin(Rect() + 25)
pnl.debug_mp = true
pnl:SetSize(Vec2()+600)
pnl:CenterSimple()
pnl:SetColor(Color(0,0,0,1))
pnl:SetPosition(pnl:GetPosition() + Vec2(10,0))

for i = 1, 20 do
	local sub = pnl:CreatePanel("base")
	math.randomseed(i+6)
	sub:SetDraggable(true)
	sub:SetResizable(true)
	sub:SetPosition(Vec2(math.random(0, pnl:GetWidth()), math.random(0, pnl:GetHeight())))
	sub:SetSize(Vec2() + math.random(32, 64))
	sub:SetColor(ColorHSV(math.random(),1,1))
	sub:SetName(ColorToName(sub:GetColor()))

	sub:SetPadding(Rect(math.random(10, 25), math.random(10, 25), math.random(10, 25), math.random(10, 25)))
	sub.debug_mp = true
end