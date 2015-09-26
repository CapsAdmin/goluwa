local gmod = ... or _G.gmod

local util = gmod.env.util

function util.AddNetworkString() end
function util.PrecacheModel() end
function util.PrecacheSound() end

function util.TraceLine(info)
	local data = {}

	data.Entity = NULL -- [Entity] The entity hit by the trace
	data.Fraction = 0 -- [number] This indicates the how much of your trace length was used from 0-1 (resultLength/originalLength)
	data.FractionLeftSolid = 0 -- [number] Given the trace started in a solid enviroment, this will return at what distance the trace left the solid from 0-1
	data.Hit = false -- [boolean] Indicates whether the trace hit something
	data.HitBox = 0 -- [number] The id of the hitbox hit by the trace.
	data.HitGroup = 0 -- [number] HITGROUP_ Enums describing what hitgroup the trace hit (not the same as HitBox)
	data.HitNoDraw = false -- [boolean] Indicates whenever the trace hit a no-draw brush
	data.HitNonWorld = false -- [boolean] Indicates whenever the trace did not hit the world
	data.HitNormal = gmod.env.Vector(0,0,0) -- [Vector] The normal of the surface that was hit
	data.HitPos = gmod.env.Vector(0,0,0)-- [Vector] Position of the traces hit point
	data.HitSky = false -- [boolean] Indicates whenever the trace hit the sky
	data.HitTexture = "error" -- [string] The surface texture of whatever the trace hit
	data.HitWorld = false -- [boolean] Indicates whenever the trace hit the world
	data.MatType = 0 -- [number] MAT_ Enums of the material hit by the trace
	data.Normal = gmod.env.Vector(0,0,0) -- [Vector] The normal direction of the trace
	data.PhysicsBone = 0 -- [number] The physics bone enum hit
	data.StartPos = gmod.env.Vector(0,0,0) -- [Vector] The origin of the trace
	data.SurfaceProps = 0 -- [number] ID of hit surface property, from scripts/surfaceproperties.txt You can get the name using util.GetSurfacePropName Used for CEffectData:SetSurfaceProp in "Impact" effect.
	data.StartSolid = false -- [boolean] Indicates whenever the trace started in a solid enviroment

	return data
end