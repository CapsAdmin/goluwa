local gmod = ... or _G.gmod

gmod.AddEvent("Update", function()
	local tbl = gmod.env.gamemode.Call("CalcView", gmod.env.LocalPlayer(), gmod.env.EyePos(), gmod.env.EyeAngles(), math.deg(render.camera_3d:GetFOV()), render.camera_3d:GetNearZ(), render.camera_3d:GetFarZ())
	if tbl then
		if tbl.origin then render.camera_3d:SetPosition(tbl.origin.v) end
		if tbl.angles then render.camera_3d:SetAngles(tbl.angles.v) end
		if tbl.fov then render.camera_3d:SetFOV(tbl.fov) end
		if tbl.znear then render.camera_3d:SetNearZ(tbl.znear) end
		if tbl.zfar then render.camera_3d:SetFarZ(tbl.zfar) end
		--if tbl.drawviewer then  end
	end

	--gmod.env.gamemode.Call("CalcViewModelView", )
	local frac = gmod.env.gamemode.Call("AdjustMouseSensitivity", 0, 90, 90)
	--gmod.env.gamemode.Call("CalcMainActivity", )
	--gmod.env.gamemode.Call("TranslateActivity", )
	--gmod.env.gamemode.Call("UpdateAnimation", )

	gmod.env.gamemode.Call("Tick")
	gmod.env.gamemode.Call("Think")
end)
gmod.AddEvent("PreGBufferModelPass", function()
	gmod.env.gamemode.Call("PreRender")
end)
gmod.AddEvent("DrawScene", function()
	gmod.env.gamemode.Call("RenderScene", gmod.env.EyePos(), gmod.env.EyeAngles(), math.deg(render.camera_3d:GetFOV()))
	gmod.env.gamemode.Call("DrawMonitors")
	gmod.env.gamemode.Call("PreDrawSkyBox")
	gmod.env.gamemode.Call("SetupSkyboxFog")
	gmod.env.gamemode.Call("PostDraw2DSkyBox")
	gmod.env.gamemode.Call("PreDrawOpaqueRenderables", false, true)
	gmod.env.gamemode.Call("PostDrawOpaqueRenderables", false, true)
	gmod.env.gamemode.Call("PreDrawTranslucentRenderables", false, true)
	gmod.env.gamemode.Call("PostDrawTranslucentRenderables", false, true)
	gmod.env.gamemode.Call("PostDrawSkyBox")
	gmod.env.gamemode.Call("NeedsDepthPass")
	gmod.env.gamemode.Call("SetupWorldFog")
	gmod.env.gamemode.Call("PreDrawOpaqueRenderables", false, false)
	--gmod.env.gamemode.Call("ShouldDrawLocalPlayer", player)
	gmod.env.gamemode.Call("PostDrawOpaqueRenderables", false, false)
	gmod.env.gamemode.Call("PreDrawTranslucentRenderables", false, false)
	--gmod.env.gamemode.Call("DrawPhysgunBeam", player)
	gmod.env.gamemode.Call("PostDrawTranslucentRenderables", false, false)
end)
gmod.AddEvent("PostGBufferModelPass", function()
	gmod.env.gamemode.Call("GetMotionBlurValues", 0, 0, 0, 0)
	--gmod.env.gamemode.Call("PreDrawViewModel")
	--gmod.env.gamemode.Call("PreDrawViewModel")
	--gmod.env.gamemode.Call("PostDrawViewModel")
	gmod.env.gamemode.Call("PreDrawEffects")
end)

gmod.AddEvent("GBufferPostPostProcess", function()
	gmod.env.gamemode.Call("PostDrawEffects")
end)
gmod.AddEvent("GBufferPrePostProcess", function()
	gmod.env.gamemode.Call("RenderScreenspaceEffects")
	gmod.env.gamemode.Call("PostRender")
end)

gmod.AddEvent("PreDrawGUI", function()
	gmod.env.gamemode.Call("PreDrawHUD")
	gmod.env.gamemode.Call("HUDPaintBackground")

	for k,v in ipairs(gmod.hud_element_list) do
		gmod.env.gamemode.Call("HUDShouldDraw", v)
	end
end)

gmod.AddEvent("DrawGUI", function()
	gmod.env.gamemode.Call("HUDPaint")
	gmod.env.gamemode.Call("HUDDrawScoreBoard")
end)

gmod.AddEvent("PostDrawGUI", function()
	gmod.env.gamemode.Call("PostDrawHUD")
	gmod.env.gamemode.Call("DrawOverlay")
	gmod.env.gamemode.Call("PostRenderVGUI")
end)

gmod.AddEvent("KeyInput", function(key, press)
	local ply = gmod.env.LocalPlayer()
	if press then
		gmod.env.gamemode.Call("KeyPress", ply, gmod.GetKeyCode(key))
	else
		gmod.env.gamemode.Call("KeyRelease", ply, gmod.GetKeyCode(key))
	end
end)

gmod.AddEvent("ClientEntered", function(client)
	local ply = gmod.WrapObject(client, "Player")
	gmod.env.hook.Run("player_connect", {
		name = ply:Nick(),
		networkid = ply:SteamID(),
		address = ply:IPAddress(),
		userid = ply:UserID(),
		bot = 0, -- ply:IsBot(),
		index = ply:EntIndex(),
	})

	gmod.env.gamemode.Call("PlayerConnect", ply:Nick(), ply:IPAddress())

	event.Delay(0.5, function()
		gmod.env.hook.Run("player_spawn", {
			userid = ply:UserID(),
		})

		event.Delay(0, function()
			gmod.env.hook.Run("player_activate", {
				userid = ply:UserID(),
			})

			event.Delay(0, function()
				gmod.env.gamemode.Call("OnEntityCreated", ply)
				gmod.env.gamemode.Call("NetworkEntityCreated", ply)
				gmod.env.gamemode.Call("PlayerSpawn", ply)
			end, nil, client)
		end, nil, client)
	end, nil, client)
end)

gmod.AddEvent("ClientLeft", function(client, reason)
	local ply = gmod.WrapObject(client, "Player")

	gmod.env.gamemode.Call("EntityRemoved", ply)
	gmod.env.gamemode.Call("PlayerDisconnected", ply)

	gmod.env.hook.Run("player_disconnect", {
		name = ply:Nick(),
		networkid = ply:SteamID(),
		userid = ply:UserID(),
		bot = ply:IsBot(),
		reason = reason,
	})
end)

gmod.AddEvent("ClientChat", function(client, msg)
	local ply = gmod.WrapObject(client, "Player")
	gmod.env.gamemode.Call("OnPlayerChat", ply, msg, false, not ply:Alive())
end)

if RELOAD then
	for k,v in pairs(gmod.env.player.GetAll()) do
		event.Call("ClientLeft", v.__obj, "reloading")
	end

	for k,v in pairs(gmod.env.player.GetAll()) do
		event.Call("ClientEnterd", v.__obj)
	end
end