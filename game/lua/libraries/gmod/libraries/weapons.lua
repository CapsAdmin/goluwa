do
	local META = prototype.CreateTemplate("gmod_weapon")

	META:Register()

	function gine.CreateWeapon()
		local self = META:CreateObject()
		self.clip1 = 0
		self.max_clip1 = 1

		self.clip2 = 0
		self.max_clip2 = 1
		return self
	end
end

do
	local META = gine.GetMetaTable("Weapon")

	function META:SetClip2(num) self.__obj.clip2 = num end
	function META:Clip2() return self.__obj.clip2 end
	function META:GetMaxClip2() return self.__obj.max_clip2 end

	function META:SetClip1(num) self.__obj.clip1 = num end
	function META:Clip1() return self.__obj.clip1 end
	function META:GetMaxClip1() return self.__obj.max_clip1 end


	function META:GetPrimaryAmmoType()
		return 0
	end

	function META:GetSecondaryAmmoType()
		return 0
	end

	function META:GetPrintName()
		return self.PrintName or "???"
	end
end

do
	local META = gine.GetMetaTable("Player")

	function META:SelectWeapon()

	end

	function META:GetActiveWeapon()
		if not self.__obj.gine_weapon then
			self.__obj.gine_weapon = gine.CreateWeapon()
		end
		return gine.WrapObject(self.__obj.gine_weapon, "Weapon")
	end

	function META:GetWeapons()
		return {self:GetActiveWeapon()}
	end

	function META:HasWeapon()
		return false
	end

	function META:SetAmmo(count, type)

	end

	function META:GetAmmoCount(type)
		return 0
	end

	function META:GiveAmmo(type, b)

	end

	function META:RemoveAllAmmo()

	end

	function META:SetWeaponColor()

	end

	function META:ShouldDropWeapon()

	end
end

function gine.env.game.GetAmmoName(id)
	return "none"
end

function gine.env.game.GetAmmoID(name)
	return 1
end

function gine.env.game.GetAmmoMax(type)
	return 1
end