function gine.env.util.TraceLine(info)
	local data = {}

	data.Entity = NULL -- [Entity] The entity hit by the trace
	data.Fraction = 0 -- [number] This indicates the how much of your trace length was used from 0-1 (resultLength/originalLength)
	data.FractionLeftSolid = 0 -- [number] Given the trace started in a solid enviroment, this will return at what distance the trace left the solid from 0-1
	data.Hit = false -- [boolean] Indicates whether the trace hit something
	data.HitBox = 0 -- [number] The id of the hitbox hit by the trace.
	data.HitGroup = 0 -- [number] HITGROUP_ Enums describing what hitgroup the trace hit (not the same as HitBox)
	data.HitNoDraw = false -- [boolean] Indicates whenever the trace hit a no-draw brush
	data.HitNonWorld = false -- [boolean] Indicates whenever the trace did not hit the world
	data.HitNormal = gine.env.Vector(0,0,0) -- [Vector] The normal of the render2d that was hit
	data.HitPos = gine.env.Vector(0,0,0)-- [Vector] Position of the traces hit point
	data.HitSky = false -- [boolean] Indicates whenever the trace hit the sky
	data.HitTexture = "error" -- [string] The render2d texture of whatever the trace hit
	data.HitWorld = false -- [boolean] Indicates whenever the trace hit the world
	data.MatType = 0 -- [number] MAT_ Enums of the material hit by the trace
	data.Normal = gine.env.Vector(0,0,0) -- [Vector] The normal direction of the trace
	data.PhysicsBone = 0 -- [number] The physics bone enum hit
	data.StartPos = gine.env.Vector(0,0,0) -- [Vector] The origin of the trace
	data.SurfaceProps = 0 -- [number] ID of hit render2d property, from scripts/render2dproperties.txt You can get the name using util.GetSurfacePropName Used for CEffectData:SetSurfaceProp in "Impact" effect.
	data.StartSolid = false -- [boolean] Indicates whenever the trace started in a solid enviroment

	return data
end

gine.env.util.TraceHull = gine.env.util.TraceLine

do
	do
		local density = 2

		function gine.env.physenv.SetAirDensity(num)
			density = num
		end

		function gine.env.physenv.GetAirDensity(num)
			return density
		end
	end

	do
		local gravity

		function gine.env.physenv.SetGravity(vec)
			gravity = vec
		end

		function gine.env.physenv.GetGravity()
			return (gravity and gravity * 1) or gine.env.Vector(0, 0, -600)
		end
	end

	do
		local settings = {
			MaxCollisionChecksPerTimestep = 50000,
			MaxCollisionsPerObjectPerTimestep = 10,
			LookAheadTimeObjectsVsObject = 0.5,
			MaxVelocity = 4000,
			MinFrictionMass = 10,
			MaxFrictionMass = 2500,
			LookAheadTimeObjectsVsWorld = 1,
			MaxAngularVelocity = 7272.7275390625,
		}

		function gine.env.physenv.SetPerformanceSettings(tbl)
			table.merge(settings, tbl)
		end

		function gine.env.physenv.GetPerformanceSettings()
			return table.copy(settings)
		end
	end
end

do
	local META = gine.GetMetaTable("Entity")
	function META:SetSolid(b)

	end

	function META:PhysicsInit()

	end

	function META:GetPhysicsObject()
		return NULL
	end
end