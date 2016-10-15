function gine.env.Mesh()
	return gine.WrapObject(render.CreateMeshBuilder(), "IMesh")
end

local META = gine.GetMetaTable("IMesh")

function META:BuildFromTriangles(tbl)

end

function META:Destroy()
	self.__obj:Remove()
end

function META:Draw()
	self.__obj:Draw()
end
