-- name of the ammo
ITEM.name = nil
-- the model of the ammo
ITEM.model = nil
-- the category of the ammo
ITEM.category = "Ammunition"
-- the ammo type
ITEM.ammo = nil
-- the amount of ammo
ITEM.ammoAmount = nil
-- the description of the ammo
ITEM.description = nil

-- set this to TRUE if the ammo type is not magazine-based
ITEM.isFed = false

/*
	the data point "rounds" will give you the amount of ammo inside an ammo item
	modified when unloading ammo from a gun
	used when loading ammo into a gun
	be sure to default to ammoAmount
*/
function ITEM:GetDescription()
	local rounds = self:GetData("rounds", self.ammoAmount)
	return Format(self.description, rounds)
end

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData("rounds", item.ammoAmount), "DermaDefault", w - 5, h - 5,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.Load = { -- sorry, for name order.
	name = "Load",
	tip = "equipTip",
	icon = "icon16/tab.png",
	OnRun = function(item) -- if the player can run this, it is implied that the ammo type is correct for their weapon selected
		-- set this magazine's ammo to the gun's ammo
		-- set the gun's ammo to this magazine's ammo
		local client = item.player
		local weapon = client:GetActiveWeapon()
		local newMagCount = weapon:Clip1()

		weapon:SetClip1(0)
		client:SetAmmo(item:GetData("rounds", item.ammoAmount), item.ammo)
		if SERVER and newMagCount == 0 then
			return true
		elseif SERVER then
			item:SetData("rounds", newMagCount)
		end
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and IsValid(item.player) and HasRightWeapon(item)
	end
}

function HasRightWeapon(item)
	if item.ammo == game.GetAmmoName(item.player:GetActiveWeapon():GetPrimaryAmmoType()) then
		return true
	end
	return false
end