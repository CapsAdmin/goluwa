function gmod.env.gameevent.Listen()
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

gmod.hud_elements = {}

function gmod.ToggleHUDElement(what, b)
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
	gmod.hud_elements[v] = true
end

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

	for k,v in ipairs(hud_element_list) do
		if gmod.env.gamemode.Call("HUDShouldDraw", v) == false then
			if gmod.hud_elements[v] then
				gmod.ToggleHUDElement(v, false)
				gmod.hud_elements[v] = false
			end
		else
			if not gmod.hud_elements[v] then
				gmod.ToggleHUDElement(v, true)
				gmod.hud_elements[v] = true
			end
		end
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
