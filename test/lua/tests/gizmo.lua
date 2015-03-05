local pos = Vec3(0,0,10)
local scale = Vec3()+5
local ang = Ang3()
local mat = Matrix44()
 
local directions = { 
    {color = Color(1,0,0,1), dir =  Ang3():GetRight(), ang = Deg3( 90,   0, 180)},
    {color = Color(0,1,0,1), dir =  Ang3():GetForward()  , ang = Deg3(  0,   0, -90)},
    {color = Color(0,0,1,1), dir =  Ang3():GetUp()     , ang = Deg3(  0,  90,   0)},
}
 
local tex = Texture("http://hexnet.org/files/images/hexnet/dozenal-tau-unit-circle.png")
 
local selected
local current_axis
 
local mouse_start_ang
local obj_start_mat
 
event.AddListener("PreDrawMenu", "gizmo", function()
    render.SetCullMode("none")
    render.EnableDepth(true)
    
    render.PushWorldMatrixEx(pos, nil, scale)
        for i, info in ipairs(directions) do
            render.Start3D2DEx(nil, info.ang)            
				local mouse_pos = Vec2(render.ScreenToWorld(surface.GetMousePosition()))
				local mouse_ang = math.atan2(mouse_pos.y, mouse_pos.x)
				local dist = mouse_pos:GetLength()
				
				surface.SetColor(info.color)
				
				if dist > 128 - 8 and dist < 128 + 8 and not current_axis then
					surface.SetColor(1,1,0,1)
					if input.IsMouseDown("button_1")  then
						if not current_axis then
							current_axis = info
							mouse_start_ang = mouse_ang
							obj_start_mat = mat:Copy()
						end
					end
				end 
				
				if current_axis == info then
					surface.SetColor(1,1,0,1)
				end
				
				if not input.IsMouseDown("button_1") then
					current_axis = nil
					selected = nil
				end
				
				surface.SetWhiteTexture()				
				surface.DrawRect(mouse_pos.x, mouse_pos.y, 2, 2, 0, -1, -1)				
				surface.DrawCircle(0, 0, 128, 4)            
            render.End3D2D()
        end
        
        render.EnableDepth(false)
		
        if current_axis then
            local info = current_axis
            render.Start3D2DEx(nil, info.ang)				
				local mouse_pos = Vec2(render.ScreenToWorld(surface.GetMousePosition()))
				local mouse_ang = math.atan2(mouse_pos.y, mouse_pos.x)
				
				local rad = math.normalizeangle(mouse_start_ang-mouse_ang)
				
				local temp = obj_start_mat:Copy()
				temp:Rotate(rad, info.dir:Unpack())
				
				mat = temp						
            render.End3D2D()
        end
        
        render.Start3D2D(mat) 
			surface.SetTexture(tex)
			
			surface.SetColor(1,1,1,1)
			
			surface.DrawRect(-1, -1, 2, 2)
        render.End3D2D()    
    render.PopWorldMatrix()
end)