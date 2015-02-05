local physics = physics or {}

physics.bullet = requirew("lj-bullet3")
physics.bodies = {}

local function vec3_to_bullet(x, y, z)
	return -y, -x, -z
end

local function vec3_from_bullet(x, y, z)
	return -y, -x, -z
end

physics.Vec3ToBullet = vec3_to_bullet
physics.Vec3FromBullet = vec3_from_bullet

include("physics_body.lua", physics)

function physics.Initialize()
	for k,v in pairs(physics.bodies) do 
		if v:IsValid() then
			v:Remove() 
		end
	end

	physics.bullet.Initialize()
	
	physics.bodies = {}
	physics.body_lookup = utility.CreateWeakTable()
			
	do
		local out = ffi.new("bullet_collision_value[1]")

		event.AddListener("Update", "bullet", function(dt)		
			physics.bullet.StepSimulation(dt or 0, physics.sub_steps, physics.fixed_time_step)
			
			while physics.bullet.ReadCollision(out) do
				if physics.body_lookup[out[0].a] and physics.body_lookup[out[0].b] then
					event.Call("PhysicsCollide", physics.body_lookup[out[0].a].ent, physics.body_lookup[out[0].b].ent)
				end
			end
		end)
	end
	
	physics.SetGravity(Vec3(0, 0, -9.8))
	physics.sub_steps = 1
	physics.fixed_time_step = 1/60	
end

function physics.EnableDebug(draw_line, contact_point, _3d_text, report_error_warning)
	physics.bullet.EnableDebug(draw_line, contact_point, _3d_text, report_error_warning)
end

function physics.DisableDebug()
	physics.bullet.DisableDebug()
end

function physics.DrawDebugWorld()
	physics.bullet.DrawDebugWorld()
end

function physics.GetBodies()
	return physics.bodies
end

do
	local out = ffi.new("bullet_raycast_result[1]")
	
	function physics.RayCast(from, to)
		if physics.bullet.RayCast(from.x, from.y, from.z, to.x, to.y, to.z, out) then
			return {
				hit_pos = Vec3(out[0].hit_pos[0], out[0].hit_pos[1], out[0].hit_pos[2]),
				hit_normal = Vec3(out[0].hit_normal[0], out[0].hit_normal[1], out[0].hit_normal[2]),
				body = body_lookup[out[0].body].ent,
			}
		end
	end
end

do
	local out = ffi.new("float[3]")
	
	function physics.GetGravity()
		physics.bullet.GetWorldGravity(out)
		return Vec3(vec3_from_bullet(out[0], out[1], out[2]))
	end
	
	function physics.SetGravity(vec)
		physics.bullet.SetWorldGravity(vec3_to_bullet(vec:Unpack()))
	end
end

physics.Initialize()

return physics