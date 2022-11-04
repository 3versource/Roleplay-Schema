ITEM.name = "Better Outfits"
ITEM.description = "A not-so-trash outfit base without PAC support."
ITEM.category = "Outfit"
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.playermodelBodygroupAndVariants = nil -- table of pairs (bodygroup, variant), (bodygroup, variant)
-- so if index 1 = 1 and index 2 = 1, bodygroup type 1 will be set to variant 1
-- whatever the 1st bodygroup is of the model will have its variant changed to 1
/*
	citizen playermodel layout:
	skin - 0
	torso - 1
	legs - 2
	hands - 3
	headgear - 4
	bag - 5
	glasses - 6
	satchel - 7
	pouch - 8
	badge - 9
	headstrap - 10
	kevlar - 11
	facialhair - 12

	MPF playermodel layout:
*/
ITEM.playermodelBodygroupChanges = 0
-- the amount of bodygroup changes an item will have (default = 0)

ITEM.playermodel = nil
-- string of the playermodel you are trying to change to

ITEM.isClothingItem = true
ITEM.invHeight = nil
ITEM.invWidth = nil
ITEM.armor = nil
ITEM.isMPF = nil

ITEM.forModel = nil
/*
	forModel must be one of the following:

	models/ug/new/citizens
	models/police

	"this item is for this model"
	good for disabling people from equipping non-supported clothes
*/

-- draws the small square on an item when the item is equipped
if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

-- the button to trigger the unequip process of the item
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	OnRun = function(item)
		item:OnUnequipped()
		return false
	end,
	OnCanRun = function(item)
		-- if the item isn't valid and currently not equipped, return false (only appears when item is equipped)
		return (!IsValid(item.entity) and item:GetData("equip") == true)
	end
}

-- the button to trigger the equip process of the item
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	OnRun = function(item)
		item:OnEquipped(false)
		return false
	end,
	OnCanRun = function(item)
		-- return false if the item isn't valid and if the item is equipped and if the player is valid (do not show the equip button when the item is equipped or (and) when the player isn't valid)
		return (!IsValid(item.entity) and item:GetData("equip") ~= true and IsValid(item.player))
	end
}

-- equips the clothing item specified
function ITEM:OnEquipped(justChange, initialPly)
	-- "self" refers to "item"
	local ply = self.player or initialPly -- upon the hook being ran, self.player does not exist (because the item hasn't loaded yet)

	-- changing without saving data about the player's model
	if justChange then
		if self.playermodel then
			ply:SetModel(self.playermodel)
		end
		-- if there are bodygroup changes, then
		if self.playermodelBodygroupAndVariants then
			-- change the player's bodygroups
			for i = 1, (self.playermodelBodygroupChanges*2), 2 do
				-- sets the player's model to the bodygroup specified
				ply:SetBodygroup(self.playermodelBodygroupAndVariants[i], self.playermodelBodygroupAndVariants[i+1])
			end
		end
	else
		-- defines this after the if statement to not waste time
		local char = ply:GetCharacter() -- returns the player's character
		local items = char:GetInv():GetItems() -- returns a table of the player's items to go through


		if self.forModel and !(string.find(ply:GetModel(), self.forModel)) then
			ply:NotifyLocalized("You can't equip this clothing item.")
			return
		end

		-- go through the player's inventory to unequip any conflicting clothes
		for k, v in pairs(items) do
			-- if the selected item is a clothing item and is equipped and is not the self item, then
			if v.isClothingItem and v:GetData("equip") then
				-- if there is a playmodel change and if the selected item is a playermodel or is a bodygroup item, unequip it
				if self.playermodel and (v.playermodel or v.playermodelBodygroupAndVariants) then
					-- unequip the selected item to prevent conflictions
					v:OnUnequipped(ply)
				end

				if self.playermodelBodygroupChanges then
					for i = 1, (self.playermodelBodygroupChanges*2), 2 do
						for a = 1, (v.playermodelBodygroupChanges*2), 2 do
							-- if the selected item is of the same category or has a category that's the same as the self item, then
							if v.playermodelBodygroupAndVariants[a] == self.playermodelBodygroupAndVariants[i] then
								-- unequip the selected item if ANY of the categories are the same to prevent conflictions
								v:OnUnequipped(ply)
							end
						end
					end
				end
			end
		end

		-- if the item is a playermodel, then
		if self.playermodel then
			-- save the old playermodel
			self:SetData("previousPlayermodel", ply:GetModel())
			-- set the new playermodel
			ply:SetModel(self.playermodel)
		end

		-- if the item is a bodygroup, then
		if self.playermodelBodygroupAndVariants then
			-- a table that will store the player's previous bodygroups and their variants
			local previousBodygroupsAndVariants = {}

			-- starts at 1, skips every other index
			for i = 1, (self.playermodelBodygroupChanges*2), 2 do
				-- sets the 1st part of the pair equal to the bodygroup type's index
				previousBodygroupsAndVariants[i] = self.playermodelBodygroupAndVariants[i]
				-- sets the 2nd part of the pair equal to the bodygroup variant's index within the bodygroup type (1, 1 means set the torso to variant 1)
				previousBodygroupsAndVariants[i+1] = ply:GetBodygroup(previousBodygroupsAndVariants[i])

				-- print("saved "..previousBodygroupsAndVariants[i].." with it set to "..previousBodygroupsAndVariants[i+1])
				-- print("setting "..self.playermodelBodygroupAndVariants[i].." to "..self.playermodelBodygroupAndVariants[i+1])

				-- sets the player's model to the bodygroup specified
				ply:SetBodygroup(self.playermodelBodygroupAndVariants[i], self.playermodelBodygroupAndVariants[i+1])
			end
		-- saves the player's previous bodygroups and variants
		self:SetData("previousBodygroupsAndVariants", previousBodygroupsAndVariants)
		end
	end
	
	-- the item is properly equipped, set "equip" data to true
	self:SetData("equip", true)
end

-- unequips the clothing item specified
function ITEM:OnUnequipped(player)
	-- "self" refers to "item"
	local ply = player or self.player

	-- if the item is a playermodel, then
	if self.playermodel then
		local items = ply:GetCharacter():GetInv():GetItems() -- returns a table of the player's items to go through
		-- go through the player's entire inventory,
		for k, v in pairs(items) do
			-- if the selected item is a clothing item and is equipped, then
			if v.isClothingItem and v.id ~= self.id and v:GetData("equip", true) then
				-- unequip that item
				v:OnUnequipped()
			end
		end

		-- set the player's model to their old model
		ply:SetModel(self:GetData("previousPlayermodel"))
		-- remove the data on their previous playermodel
		self:SetData("previousPlayermodel", nil)
	end	

	-- if the item is a bodygroup, then
	if self.playermodelBodygroupChanges then
		/*
			loop, starting at 1 and skipping every other number (goes like 1, 3, 5, 7, etc),
			with the maximum limit being the amount of changes times 2
			(allows the skipping to work and be able to save what bodygroup is set to what)
		*/
		for i = 1, (self.playermodelBodygroupChanges*2), 2 do
			-- set the bodygroup to the previous bodygroup and what its index was (1, 2 means set bodygroup 1 to variant 2)
			ply:SetBodygroup(self:GetData("previousBodygroupsAndVariants")[i], self:GetData("previousBodygroupsAndVariants")[i+1])
		end
		-- remove the data on their previous bodygroups
		self:SetData("previousBodygroupsAndVariants", nil)
	end

	-- item is properly unequipped, set "equip" data to false
	self:SetData("equip", false)
end

function ITEM:CanTransfer(oldInv, newInv)
	if newInv and self:GetData("equip") then
		local ply = self:GetOwner()

		ply:NotifyLocalized("You can't move an equipped clothing item.")

		return false
    end
	return true
end


-- when the item is dropped, unequip it
ITEM:Hook("drop", function(item)
	if item:GetData("equip", false) then
		item:OnUnequipped()
	end
end)

-- when the player spawns,
hook.Add("PlayerLoadedCharacter", "equipClothes", function(client, character)
	local items = character:GetInv():GetItems() -- returns a table of the player's items to go through
	-- go through the player's entire inventory,
	for k, v in pairs(items) do
		-- if the selected item is a clothing item and is equipped, then
		if v.isClothingItem and v:GetData("equip", true) then
			-- equip that item
			v:OnEquipped(true, client)
		end
	end
end)
