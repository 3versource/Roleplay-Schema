ITEM.name = nil
ITEM.model = nil
ITEM.category = "Ammunition"

ITEM.ammo = nil -- the ammo type
ITEM.ammoAmount = nil
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

ITEM.functions.Load = { -- sorry, for name order.
	name = "Load",
	tip = "equipTip",
	icon = "icon16/tab.png",
	OnRun = function(item) -- if the player can run this, it is implied that the ammo type is correct for their weapon selected
		-- set this magazine's ammo to the gun's ammo
		-- set the gun's ammo to this magazine's ammo
		local client = item.player
		local weapon = client:GetActiveWeapon()
		local previouslyLoadedAmmo = weapon:Clip1()

		weapon:SetClip1(0) -- empty the gun's ammo pool
		client:SetAmmo(item:GetData("rounds", item.ammoAmount), item.ammo) -- set the gun's ammo pool to this item's ammo count and ammo type
		if SERVER and previouslyLoadedAmmo == 0 then -- if the previously loaded ammo was zero,
			return true -- delete the magazine
		elseif SERVER then -- otherwise,
			item:SetData("rounds", previouslyLoadedAmmo) -- set this item's ammo count to what the gun previously had
		end
		return false
	end,
	OnCanRun = function(item) -- can only be run if the item's entity is gone, if the item is on the player, and if the player is holding the gun that uses the ammo
		return !IsValid(item.entity) and IsValid(item.player) and HasRightWeapon(item)
	end
}

ITEM.functions.Refill = {
	name = "Refill",
	tip = "equipTip",
	icon = "icon16/tab.png",
	OnRun = function(item)
		local client = item.player
		local items = client:GetCharacter():GetInv():GetItems() -- returns a table of the player's items to go through 
		local subtracteeMag = nil -- the magazine that this item will take from
		local subtracteeMagCount = nil -- the number of ammo in that magazine
		local addeeMagCount = item:GetData("rounds") -- the amount of ammo in this item's magazine. implied that this magazine is NOT full

		-- go through the player's entire inventory,
		for k, v in pairs(items) do
			-- if the selected magazine's ammo type is the same as the refiller magazine and is smaller in ammo count than the magazine selected
			if v.id ~= item.id and v.ammo == item.ammo and ((subtracteeMagCount == nil) or subtracteeMagCount >= v:GetData("rounds", v.ammoAmount)) then
				subtracteeMagCount = v:GetData("rounds", v.ammoAmount)
				subtracteeMag = v
			end
		end

		-- if a magazine was found, then
		if subtracteeMag then
			local addedAmmo = math.Clamp(subtracteeMagCount, 0, (item.ammoAmount - addeeMagCount))
			local subtracteeNewMagCount = subtracteeMagCount - addedAmmo

			if subtracteeNewMagCount > 1 then
				subtracteeMag:SetData("rounds", subtracteeNewMagCount)
			elseif SERVER then
				subtracteeMag:Remove()
			end
			item:SetData("rounds", item:GetData("rounds") + addedAmmo)
		end

		return false
	end,
	OnCanRun = function(item) -- can only be run if the item's entity is gone, if the item is on the player, and if the player has another magazine of the same ammo time
		return !IsValid(item.entity) and IsValid(item.player) and HasMagOfSameType(item) and MagIsNotFull(item)
	end
}

-- returns true if the player's currently held weapon takes the ammo type of the magazine passed into the function
function HasRightWeapon(item)
	if item.ammo == game.GetAmmoName(item.player:GetActiveWeapon():GetPrimaryAmmoType()) then
		return true
	end
	return false
end

-- returns true if the player has a magazine of the same ammo type as the magazine passed into the function
function HasMagOfSameType(item)
	local items = item.player:GetCharacter():GetInv():GetItems() -- returns a table of the player's items to go through 
	
	for k, v in pairs(items) do
		-- if the selected magazine's ammo type is the same as the refiller magazine
		if v.id ~= item.id and v.ammo == item.ammo then
			return true
		end
	end
	return false
end

-- returns true if the magazine passed doesn't have max ammo
function MagIsNotFull(item)
	if item.ammoAmount == item:GetData("rounds", item.ammoAmount) then
		return false
	end
	return true
end