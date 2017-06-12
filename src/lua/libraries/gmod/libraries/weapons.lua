do
	local META = prototype.CreateTemplate("gmod_weapon")

	META:Register()

	function gine.CreateWeapon()
		return META:CreateObject()
	end
end

local META = gine.GetMetaTable("Weapon")

function META:IsWeapon()
	return true
end

function META:Clip2()
	return 0
end

function META:GetMaxClip2()
	return 1
end

function META:Clip1()
	return 0
end

function META:GetMaxClip1()
	return 1
end