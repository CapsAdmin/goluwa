local id

function render.BeginList(override)
	if not id then
		id = override or gl.GenList()
		gl.NewList(id, e.GL_COMPILE)
	else
		error("called render.BeginList without calling render.EndList first", 2)
	end
end

function render.EndList()
	if id then
		gl.EndList()
		
		local temp = id
		id = nil
		return temp
	end
	
	error("called render.EndList without calling render.BeginList first", 2)
end

function render.BindList(id)
	gl.CallList(id)
end