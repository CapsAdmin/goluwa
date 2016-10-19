function gine.env.gameevent.Listen()
	-- this is always on
end

local hud_element_list = {
	"CHudAmmo",
	"CHudBattery",
	"CHudChat",
	"CHudCrosshair",
	"CHudDamageIndicator",
	"CHudDeathNotice",
	"CHudGeiger",
	"CHudGMod",
	"CHudHealth",
	"CHudHintDisplay",
	"CHudMenu",
	"CHudMessage",
	"CHudPoisonDamageIndicator",
	"CHudSecondaryAmmo",
	"CHudSquadStatus",
	"CHudTrain",
	"CHudWeapon",
	"CHudWeaponSelection",
	"Hiding",
	"CHudZoom",
	"Only",
	"NetGraph",
	"CTargetID",
	"CHudHistoryResource",
	"CHudSuitPower",
	"CHudCloseCaption",
	"CHudLocator",
	"CHudFlashlight",
	"CAchievementNotificationPanel",
	"CHudAnimationInfo",
	"CHUDAutoAim",
	"CHudBonusProgress",
	"CHudCapturePanel",
	"CHudCommentary",
	"CHudControlPointIcons",
	"CHudCredits",
	"CHudVehicle",
	"CHudVguiScreenCursor",
	"CHudVoiceSelfStatus",
	"CHudVoiceStatus",
	"CHudVote",
	"CMapOverview",
	"CPDumpPanel",
	"CReplayReminderPanel",
	"CTeamPlayHud",
	"CHudFilmDemo",
	"CHudGameMessage",
	"CHudHDRDemo",
	"CHudHintKeyDisplay",
	"CHudPosture",
	"CHUDQuickInfo",
}

gine.hud_elements = {}

function gine.ToggleHUDElement(what, b)
	llog("hud element: %s = %s", what, b)
	if what == "CHudChat" and chathud then
		if b then
			chathud.Show()
		else
			chathud.Hide()
		end
	end
end

for k,v in ipairs(hud_element_list) do
	gine.hud_elements[v] = true
end

gine.AddEvent("Update", function()
	local tbl = gine.env.gamemode.Call("CalcView", gine.env.LocalPlayer(), gine.env.EyePos(), gine.env.EyeAngles(), math.deg(camera.camera_3d:GetFOV()), camera.camera_3d:GetNearZ(), camera.camera_3d:GetFarZ())
	if tbl then
		if tbl.origin then camera.camera_3d:SetPosition(tbl.origin.v) end
		if tbl.angles then camera.camera_3d:SetAngles(tbl.angles.v) end
		if tbl.fov then camera.camera_3d:SetFOV(tbl.fov) end
		if tbl.znear then camera.camera_3d:SetNearZ(tbl.znear) end
		if tbl.zfar then camera.camera_3d:SetFarZ(tbl.zfar) end
		--if tbl.drawviewer then  end
	end

	--gine.env.gamemode.Call("CalcViewModelView", )
	local frac = gine.env.gamemode.Call("AdjustMouseSensitivity", 0, 90, 90)
	--gine.env.gamemode.Call("CalcMainActivity", )
	--gine.env.gamemode.Call("TranslateActivity", )
	--gine.env.gamemode.Call("UpdateAnimation", )

	gine.env.gamemode.Call("Tick")
	gine.env.gamemode.Call("Think")
end)
gine.AddEvent("PreGBufferModelPass", function()
	gine.env.gamemode.Call("PreRender")
end)
gine.AddEvent("DrawScene", function()
	gine.env.gamemode.Call("RenderScene", gine.env.EyePos(), gine.env.EyeAngles(), math.deg(camera.camera_3d:GetFOV()))
	gine.env.gamemode.Call("DrawMonitors")
	gine.env.gamemode.Call("PreDrawSkyBox")
	gine.env.gamemode.Call("SetupSkyboxFog")
	gine.env.gamemode.Call("PostDraw2DSkyBox")
	gine.env.gamemode.Call("PreDrawOpaqueRenderables", false, true)
	gine.env.gamemode.Call("PostDrawOpaqueRenderables", false, true)
	gine.env.gamemode.Call("PreDrawTranslucentRenderables", false, true)
	gine.env.gamemode.Call("PostDrawTranslucentRenderables", false, true)
	gine.env.gamemode.Call("PostDrawSkyBox")
	gine.env.gamemode.Call("NeedsDepthPass")
	gine.env.gamemode.Call("SetupWorldFog")
	gine.env.gamemode.Call("PreDrawOpaqueRenderables", false, false)
	--gine.env.gamemode.Call("ShouldDrawLocalPlayer", player)
	gine.env.gamemode.Call("PostDrawOpaqueRenderables", false, false)
	gine.env.gamemode.Call("PreDrawTranslucentRenderables", false, false)
	--gine.env.gamemode.Call("DrawPhysgunBeam", player)
	gine.env.gamemode.Call("PostDrawTranslucentRenderables", false, false)
end)
gine.AddEvent("PostGBufferModelPass", function()
	gine.env.gamemode.Call("GetMotionBlurValues", 0, 0, 0, 0)
	--gine.env.gamemode.Call("PreDrawViewModel")
	--gine.env.gamemode.Call("PreDrawViewModel")
	--gine.env.gamemode.Call("PostDrawViewModel")
	gine.env.gamemode.Call("PreDrawEffects")
end)

gine.AddEvent("GBufferPostPostProcess", function()
	gine.env.gamemode.Call("PostDrawEffects")
end)
gine.AddEvent("GBufferPrePostProcess", function()
	gine.env.gamemode.Call("RenderScreenspaceEffects")
	gine.env.gamemode.Call("PostRender")
end)

gine.AddEvent("PreDrawGUI", function()
	gine.env.gamemode.Call("PreDrawHUD")
	gine.env.gamemode.Call("HUDPaintBackground")

	for k,v in ipairs(hud_element_list) do
		if gine.env.gamemode.Call("HUDShouldDraw", v) == false then
			if gine.hud_elements[v] then
				gine.ToggleHUDElement(v, false)
				gine.hud_elements[v] = false
			end
		else
			if not gine.hud_elements[v] then
				gine.ToggleHUDElement(v, true)
				gine.hud_elements[v] = true
			end
		end
	end
end)

gine.AddEvent("DrawGUI", function()
	gine.env.gamemode.Call("HUDPaint")
	gine.env.gamemode.Call("HUDDrawScoreBoard")
end)

gine.AddEvent("PostDrawGUI", function()
	gine.env.gamemode.Call("PostDrawHUD")
	gine.env.gamemode.Call("DrawOverlay")
	gine.env.gamemode.Call("PostRenderVGUI")
end)
