function gmod.env.Mesh()
	return gmod.WrapObject(render.CreateMeshBuilder(), "IMesh")
end

local META = gmod.GetMetaTable("IMesh")

function META:BuildFromTriangles(tbl)

end

function META:Destroy()
	self.__obj:Remove()
end

function META:Draw()
	self.__obj:Draw()
end