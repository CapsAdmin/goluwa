local physics = physics or {}

physics.bullet = requirew("libraries.ffi.bullet3")
physics.bodies = physics.bodies or {}

local function vec3_to_bullet(x, y, z)
	return -y, -x, -z
end

local function vec3_from_bullet(x, y, z)
	return -y, -x, -z
end

physics.Vec3ToBullet = vec3_to_bullet
physics.Vec3FromBullet = vec3_from_bullet

function physics.BodyToLua(ptr)
	local udata = ffi.cast("uint32_t *", physics.bullet.RigidBodyGetUserData(ptr))
	
	return physics.body_lookup[udata[0]]
end

function physics.StoreBodyPointer(ptr, obj)
	local idx = ffi.new("uint32_t[1]", tonumber(("%p"):format(obj)))
	physics.bullet.RigidBodySetUserData(ptr, idx)
	physics.body_lookup[idx[0]] = obj
end

include("physics_body.lua", physics)

function physics.Initialize()
	if not RELOAD then
		for k,v in pairs(physics.bodies) do 
			if v:IsValid() then
				v:Remove() 
			end
		end
		physics.bullet.Initialize()
		physics.bodies = {}
		physics.body_lookup = utility.CreateWeakTable()
	end
	
	do
		local out = ffi.new("bullet_collision_value[1]")
		event.AddListener("Update", "bullet", function(dt)		
			physics.bullet.StepSimulation(dt, physics.sub_steps, physics.fixed_time_step)
			
			while physics.bullet.ReadCollision(out) do
				local a = physics.BodyToLua(out[0].a)
				local b = physics.BodyToLua(out[0].b)
				
				if a and b then
					event.Call("PhysicsCollide", a.ent, b.ent)
				end
			end
		end)
	end
	
	physics.SetGravity(Vec3(0, 0, -9.8))
	physics.sub_steps = 1
	physics.fixed_time_step = 1/120	
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
			local tbl = {
				hit_pos = Vec3(),
				hit_normal = Vec3(),
				body = NULL,
			}
			
			tbl.hit_pos._ = out[0].hit_pos
			tbl.hit_normal._ = out[0].hit_normal
			

			
			if out[0].body ~= nil then
				local body = physics.BodyToLua(out[0].body)
				if body then
					tbl.body = body.ent
				end
			end
			
			return tbl
			
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