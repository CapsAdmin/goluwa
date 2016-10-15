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
