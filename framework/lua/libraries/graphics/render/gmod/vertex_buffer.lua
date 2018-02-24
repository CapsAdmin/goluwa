local MATERIAL_TRIANGLES = gmod.MATERIAL_TRIANGLES
local mesh_Begin = gmod.mesh.Begin
local mesh_End = gmod.mesh.End
local mesh_TexCoord = gmod.mesh.TexCoord
local mesh_Color = gmod.mesh.Color
local mesh_AdvanceVertex = gmod.mesh.AdvanceVertex
local mesh_Position = gmod.mesh.Position
local temp_vector = gmod.Vector(0,0,0)
local cam_PushModelMatrix = gmod.cam.PushModelMatrix
local cam_PopModelMatrix = gmod.cam.PopModelMatrix

local render_PushFilterMin = gmod.render.PushFilterMin
local render_PushFilterMag = gmod.render.PushFilterMag
local render_PopFilterMag = gmod.render.PopFilterMag
local render_PopFilterMin = gmod.render.PopFilterMin
local TEXFILTER_ANISOTROPIC = gmod.TEXFILTER.ANISOTROPIC

local render = ... or _G.render
local META = prototype.GetRegistered("texture")

function render._CreateVertexBuffer(self)
	self.Vertices = {Pointer = {}}
	return self
end

local META = prototype.GetRegistered("vertex_buffer")

function META:LoadVertices(vertices, indices, is_valid_table)
	if type(vertices) == "number" then
		for i = 1, vertices do
			self.Vertices.Pointer[i-1] = {
				pos = {
					[0] = 0,
					[1] = 0,
				},
				uv = {
					[0] = 0,
					[1] = 0,
				},
				color = {
					[0] = 0,
					[1] = 0,
					[2] = 0,
					[3] = 0,
				}
			}
		end
		self.vertices_length = vertices
	else
		for i, vertex in ipairs(vertices) do
			self.Vertices.Pointer[i-1] = {
				pos = {
					[0] = vertex.pos[1],
					[1] = vertex.pos[2],
				},
				uv = {
					[0] = vertex.uv[1],
					[1] = vertex.uv[2],
				},
				color = {
					[0] = vertex.color[1],
					[1] = vertex.color[2],
					[2] = vertex.color[3],
					[3] = vertex.color[4],
				}
			}
		end
		self.vertices_length = #vertices
	end
end

local max_vertices = 32768

function META:UpdateBuffer()
	if self.vertices_length == 0 then return end
	local chunks = {}

	for chunk_i = 1, math.ceil(self.vertices_length/max_vertices) do
		local vertices = {}
		for i = 0, max_vertices - 1 do
			local vertex = self.Vertices.Pointer[i + ((chunk_i - 1) * max_vertices)]
			if not vertex then break end
			i = i + 1
			vertices[i] = vertices[i] or {}

			vertices[i].x = vertex.pos[0]
			vertices[i].y = vertex.pos[1]

			vertices[i].u = vertex.uv[0]
			vertices[i].v = -vertex.uv[1]+1

			vertices[i].r = vertex.color[0] or 1
			vertices[i].g = vertex.color[1] or 1
			vertices[i].b = vertex.color[2] or 1
			vertices[i].a = vertex.color[3] or 1
		end
		chunks[chunk_i] = vertices
	end
	self.chunks = chunks
end

function META:Draw()
	if self.vertices_length == 0 then return end

	render_PushFilterMag( TEXFILTER_ANISOTROPIC )
	render_PushFilterMin( TEXFILTER_ANISOTROPIC )
	cam_PushModelMatrix(GetGmodWorldMatrix())
		for i, vertices in ipairs(self.chunks) do
			mesh_Begin(MATERIAL_TRIANGLES, #vertices / 3)
			for i, vertex in ipairs(vertices) do

				temp_vector.x = vertex.x
				temp_vector.y = vertex.y
				mesh_Position(temp_vector)
				mesh_TexCoord(0, vertex.u, vertex.v)

				local r,g,b,a = vertex.r, vertex.g, vertex.b, vertex.a

				r = r * render2d.shader.global_color.r
				g = g * render2d.shader.global_color.g
				b = b * render2d.shader.global_color.b
				a = a * render2d.shader.global_color.a * render2d.shader.alpha_multiplier

				r = r * 255
				g = g * 255
				b = b * 255
				a = a * 255

				mesh_Color(r,g,b,a)

				mesh_AdvanceVertex()
			end
			mesh_End()
		end
	cam_PopModelMatrix()
	render_PopFilterMag()
	render_PopFilterMin()
end