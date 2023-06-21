ITEM.name = "weapon"
ITEM.description = "weaponDesc"
ITEM.category = "Weapons"
ITEM.model = "error.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.maxAmmo = 5
ITEM.isRefiller = false
ITEM.fileName = nil

-- "ammo" is the data point attached to the item that gives the amount of ammo within it.

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



ITEM.functions.Refill = {
	name = "Refill",
	icon = "icon16/cross.png",
	OnRun = function(item)
		--[[
			if self is a refiller item,
				find the smallest magazine to refill from
			otherwise,
				find a refiller item
				OR
				if the item they're looking at is a refiller item ()
				OR
				find the smallest magazine to refill from

			if nothing is found, notify the user.
		]] 
		return false
	end,
	OnCanRun = function(item)
		--[[
			will always run. won't always do something, however.
		]]
		return true
	end
}

ITEM.functions.Load = {
	name = "Refill",
	icon = "icon16/cross.png",
	OnRun = function(item)
		--[[
			if the currently active weapon takes this as an ammo item,
				load into the player's ammo reserve.

				set the data point "currentlyLoadedName" equal to this item's filename

			if not, notify the user.
		]]
		local ply = item.player
		local character = ply:GetCharacter()
		local weapon = character:GetData("currentWeapon")

		ITEM:LoadWeapon(ply, character, weapon)

		return false
	end,
	OnCanRun = function(item)
		--[[
			will always run. won't always do something, however.
		]]
		return true
	end
}

function ITEM:LoadWeapon(ply, char, wep)
end