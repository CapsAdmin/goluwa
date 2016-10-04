local gmod = ... or gmod

do
	local META = prototype.CreateTemplate("gmod_weapon")

	META:Register()

	function gmod.CreateWeapon()
		return META:CreateObject()
	end
end

local META = gmod.env.FindMetaTable("Weapon")

function META:IsWeapon()
	return true
end