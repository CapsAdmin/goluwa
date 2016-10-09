do
	local META = prototype.CreateTemplate("gmod_weapon")

	META:Register()

	function gmod.CreateWeapon()
		return META:CreateObject()
	end
end

local META = gmod.GetMetaTable("Weapon")

function META:IsWeapon()
	return true
end