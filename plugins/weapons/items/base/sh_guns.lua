ITEM.name = "weapon"
ITEM.description = "weaponDesc"
ITEM.category = "Weapons"
ITEM.model = "error.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.weapon = ""
ITEM.equipSlot = ""
--[[
    must be:
        longarm
        sidearm
]]
ITEM.acceptsAmmo = {["ammo file name"] = true}
--[[
	must be:
		some file name of an ammo item
]]


ITEM.useSound = "items/ammo_pickup.wav"



-- when compiled by the client,
if CLIENT then
	-- draw a green rectangle over the item if it's equipped
	function ITEM:PaintOver(item, w, h)
		if item:GetData("equip", false) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end



ITEM.functions.Unequip = {
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	OnRun = function(item)
		item:DoUnequip()
		return false
	end,
	OnCanRun = function(item)
		--[[
			if this was equipped, then it's assumed that this is in the player's inventory
			can only unequip if the item is currently equipped
		]]
		return item:GetData("equip", false)
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	icon = "icon16/tick.png",
	OnRun = function(item)
		item:DoEquip()
		return false
	end,
	OnCanRun = function(item)
		--[[
			can only equip the item if it is currently NOT equipped 
			AND
			if it is in the player's inventory
		]]
		return not(item:GetData("equip", false)) and item:IsInPlayerInventory()
	end
}

ITEM.functions.Unload = {
	name = "Unload",
	icon = "icon16/tab.png",
	OnRun = function(item)
		item:RefundAmmo()

		return false
	end,
	OnCanRun = function(item)
		local weapon = item.player:GetCharacter():GetData("currentWeapon")

		if weapon:Clip1() > 0 then
			return true
		end
		return false
	end
}




function ITEM:DoUnequip()
	-- save current ammo
	self:OnSave()

	self:SetData("equip", false)

	self:Strip()
end

function ITEM:DoEquip()
	-- save current ammo
	self:OnSave()

	self:SetData("equip", true)

	self:Give()

	self:SetupAmmo()
end

function ITEM:RefundAmmo()
	local ply = self.player
	local character = ply:GetCharacter()
	local weapon = character:GetData("currentWeapon")
	local ammoType = game.GetAmmoName(weapon:GetPrimaryAmmoType())
	
	
end

function ITEM:CanTransfer()
	self:DoUnequip()

	return true
end

function ITEM:Strip()
	self.player:StripWeapon(self.weapon)
end

function ITEM:Give()
	self.player:Give(self.weapon)
end

-- upon the player loading their character
function ITEM:OnLoadout()
    -- if the weapon is currently equipped,
	if self:GetData("equip") then
        self:SetProperAmmoFor(self.player)
    end
end

function ITEM:SetupAmmo()
	local ply = self.player
	local character = ply:GetCharacter()
	local weapon = character:GetData("currentWeapon")
	local ammoType = game.GetAmmoName(weapon:GetPrimaryAmmoType())
	local currentAmmo = ply:GetCurrentAmmo(ammoType)

	-- removes reserve ammunition
	ply:RemoveAmmo(currentAmmo, ammoType)

	-- sets the loaded ammo to whatever was previously loaded to the item, defaulting to 0
	weapon:SetClip1(self:GetData("currentlyLoadedCount", 0))

	print("currently loaded: "..currentAmmo)
end

-- when a save is initiated,
function ITEM:OnSave()
	local weapon = self.player:GetCharacter():GetData("currentWeapon")
    local currentAmmo = weapon:Clip1()

    -- if their weapon exists and their current ammo is greater than or equal to zero, then
    if weapon and currentAmmo >= 0 then
        -- save the currently loaded ammo
        self:SetData("currentlyLoadedCount", currentAmmo)
    end
end

function ITEM:IsInPlayerInventory()
    -- if self.entity exists, then the physical model representing this item is somewhere in the world.
    -- if self.player is not equal to self:GetOwner(), then the item is not in the player who is running this item's function's inventory.
    return !IsValid(self.entity) and self.player == self:GetOwner()
end


-- do something when the item is dropped
ITEM:Hook("drop", function(item)
	item:DoUnequip()

	return true
end)
