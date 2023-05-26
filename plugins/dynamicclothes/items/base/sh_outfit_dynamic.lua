ITEM.name = "Better Outfits"
ITEM.description = "An unbelievably messy and complicated outfit base."
ITEM.category = "Outfit"
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.playermodelBodygroupAndVariants = nil /* table of pairs (bodygroup, variant), (bodygroup, variant)
	so if index 1 = 1 and index 2 = 1, bodygroup type 1 will be set to variant 1
	whatever the 1st bodygroup is of the model will have its variant changed to 1 
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
			skin - 0
			manhack - 1
			mask - 2
			radio - 3
			cloak/summka - 4
			spine radio - 5
			tactical shit - 6
			neck - 7
*/
ITEM.forModel = nil /*
	forModel must be one of the following supported models:
		models/ug/new/citizens
		models/police

	"this item is for this model"
	good for disabling people from equipping non-supported clothes
*/
ITEM.mpf = nil -- the prefix of a metropolice name, if this is a metropolice item (will change the player's name)
ITEM.playermodelBodygroupChanges = 0 -- the amount of bodygroup changes an item will have (default = 0)
ITEM.playermodel = nil -- string of the playermodel you are trying to change to
ITEM.isClothingItem = true
ITEM.maxArmorHP = 0 -- the amount of hits an armor item has before its bonus goes away
-- these values need to be from 0 to 1. these represent the percentage of damage negated on a certain limb (if ["head"] = .1, then the player takes 10% less damage on the head)
ITEM.limbs = {["head"] = 0, ["torso"] = 0, ["arms"] = 0, ["legs"] = 0}

-- draws the small square on an item when the item is equipped
if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

function ITEM:PopulateTooltip(tooltip)
	if self:GetData("health", self.maxArmorHP) ~= 0 then
		local panel = tooltip:AddRowAfter("name", "portions")
		local text = "Reduces damage to "
		local oneBefore = false

		for i, v in pairs(self.limbs) do
			if v ~= 0 then
				if oneBefore then
					text = text .. ", "
				end
				text = text .. i .. " by " .. v*100 .. "%"
				oneBefore = true
			end
		end
		text = "HP: " .. self:GetData("health", self.maxArmorHP) .. ".  " .. text .. "."

		panel:SetBackgroundColor(derma.GetColor("Success", tooltip))
		panel:SetText(text)
		panel:SizeToContents()
	end
end	

-- the button to trigger the unequip process of the item
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	OnRun = function(item)
		item:OnUnequipped(item.player)
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
		item:OnEquipped(false, item.player)
		if item:GetData("health", item.maxArmorHP) ~= 0 then -- if the player's armor is not broken (or does exist)
			item:AddBonus(item.player:GetCharacter(), item.limbs)
		end
		return false
	end,
	OnCanRun = function(item)
		-- return false if the item isn't valid and if the item is equipped and if the player is valid (do not show the equip button when the item is equipped or (and) when the player isn't valid)
		return (!IsValid(item.entity) and item:GetData("equip") ~= true and IsValid(item.player) and hook.Run("CanPlayerEquipItem", item.player, item) ~= false)
	end
}

-- equips the clothing item specified
function ITEM:OnEquipped(justChange, player)
	-- "self" refers to "item"
	local ply = player or self.player -- upon the hook being ran, self.player does not exist (because the item hasn't loaded yet)

	-- changing without saving data about the player's model
	if justChange then
		if self.playermodel then
			ply:GetCharacter():SetModel(self.playermodel)
		end

		-- if there are bodygroup changes, then
		if self.playermodelBodygroupAndVariants then
			-- change the player's bodygroups
			for i = 1, (self.playermodelBodygroupChanges*2), 2 do
				if self.playermodelBodygroupAndVariants[i] == 0 then
					ply:SetSkin(self.playermodelBodygroupAndVariants[i+1])
				else
					-- sets the player's model to the bodygroup specified
					ply:SetBodygroup(self.playermodelBodygroupAndVariants[i], self.playermodelBodygroupAndVariants[i+1])
				end
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

		-- if this item is an mpf item, then
		if self.mpf then
			-- store the player's character's name
			self:SetData("prevName", char:GetName())
			-- if there is no stored replacement name (prefix), then create a name
			if self:GetData("prefix", nil) == nil then
				-- search the player's inventory
				self:SetData("prefix", self.mpf.."00404")
				for k, v in pairs(items) do
					-- if an ID is found, then
					if v.name == "Universal Union Identification Card" then
						-- set part of the player's name to that id number
						self:SetData("prefix", self.mpf..v:GetData("id"))
						break
					end
				end
			end

			-- set the player's name
			char:SetName(self:GetData("prefix"))
		end

		-- if the item is a playermodel, then
		if self.playermodel then
			-- save the old playermodel
			self:SetData("previousPlayermodel", ply:GetModel())
			-- set the new playermodel
			char:SetModel(self.playermodel)
		end

		-- if the item is a bodygroup, then
		if self.playermodelBodygroupAndVariants then
			-- a table that will store the player's previous bodygroups and their variants
			local previousBodygroupsAndVariants = {}

			-- starts at 1, skips every other index
			for i = 1, (self.playermodelBodygroupChanges*2), 2 do
				-- sets the 1st part of the pair equal to the bodygroup type's index
				previousBodygroupsAndVariants[i] = self.playermodelBodygroupAndVariants[i]
				if self.playermodelBodygroupAndVariants[i] == 0 then
					-- sets the 2nd part of the pair equal to the bodygroup variant's index within the bodygroup type (1, 1 means set the torso to variant 1)
					previousBodygroupsAndVariants[i+1] = ply:GetSkin()
					ply:SetSkin(self.playermodelBodygroupAndVariants[i+1])
				else
					-- sets the 2nd part of the pair equal to the bodygroup variant's index within the bodygroup type (1, 1 means set the torso to variant 1)
					previousBodygroupsAndVariants[i+1] = ply:GetBodygroup(previousBodygroupsAndVariants[i])
					-- sets the player's model to the bodygroup specified
					ply:SetBodygroup(self.playermodelBodygroupAndVariants[i], self.playermodelBodygroupAndVariants[i+1])
				end
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
	local char = ply:GetCharacter()

	-- ARMOR REMOVAL
	if self:GetData("health", self.maxArmorHP) ~= 0 then
		self:RemoveBonus(char, self.limbs)
	end
	-- ARMOR REMOVAL

	if self.mpf then
		char:SetName(self:GetData("prevName")) -- set the player's name to their old name
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
			if self:GetData("previousBodygroupsAndVariants")[i] == 0 then
				ply:SetSkin(self:GetData("previousBodygroupsAndVariants")[i+1])
			else
				ply:SetBodygroup(self:GetData("previousBodygroupsAndVariants")[i], self:GetData("previousBodygroupsAndVariants")[i+1])
			end
		end
		-- remove the data on their previous bodygroups
		self:SetData("previousBodygroupsAndVariants", nil)
	end

	-- if the item is a playermodel, then
	if self.playermodel then
		local items = char:GetInv():GetItems() -- returns a table of the player's items to go through
		-- go through the player's entire inventory,
		for k, v in pairs(items) do
			-- if the selected item is a clothing item and is equipped, then
			if v.isClothingItem and v.id ~= self.id and v:GetData("equip", false) then
				-- unequip that item
				v:OnUnequipped()
			end
		end

		-- set the player's model to their old model
		char:SetModel(self:GetData("previousPlayermodel"))
		-- remove the data on their previous playermodel
		self:SetData("previousPlayermodel", nil)
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

function ITEM:Damage(amount)
	if self:GetData("health", self.maxArmorHP) ~= 0 then
		newHealth = self:GetData("health", self.maxArmorHP) - amount
		self:SetData("health", math.Clamp(newHealth, 0, self.maxArmorHP))
		if newHealth == 0 then
			self:RemoveBonus(self:GetOwner():GetCharacter(), self.limbs)
			self:GetOwner():ChatNotify("Your " .. string.lower(self.name) .. " has broken!")
		end
	end
end

-- when the item is dropped, unequip it
ITEM:Hook("drop", function(item)
	if item:GetData("equip", false) then
		item:OnUnequipped()
	end
end)

function ITEM:AddBonus(character)
	-- print("adding bonus!")
	for index, value in pairs(self.limbs) do
		-- print(value)
		if value ~= 0 then -- if the current limb doesn't have a protection of zero,
			-- "index" will be: "head", "torso", "arms", "legs"

			curIDs = character:GetData(index.."ProtIDs", nil)

			if curIDs == nil then
				-- print("no value found")
				curIDs = {}
			end

			-- print(curIDs)
			table.insert(curIDs, self)

			findGreatestProtector(character, self, curIDs, index)

			character:SetData(index.."ProtIDs", curIDs)
			character:SetData(index.."Redux", character:GetData(index.."Redux", 0) + value)
			-- print("added "..value.." to "..index)
		end
	end
end

function findGreatestProtector(character, item, curIDs, index)
	local greatestProtection = nil

	for i, v in pairs(curIDs) do
		v:SetData(index.."CurrentIndex", i) -- store the current index this item is saved at (for all currently equipped items)
		-- print(v.name .. " at " .. i)
		itemProt = v.limbs["head"] + v.limbs["torso"] + v.limbs["arms"] + v.limbs["legs"]
		if itemProt > (greatestProtection or 0) then
			character:SetData(index.."GreatestProtector", v) -- store the greatest protector the player currently has
			-- print("greatest protector is " .. v.name)
			greatestProtection = itemProt
		end
	end
end

function ITEM:RemoveBonus(character)
	-- print("removing bonuses!")
	for index, value in pairs(self.limbs) do
		-- print(value)
		if value ~= 0 then -- if the current limb protection this item provides isn't zero,
			-- "index" will be: "head", "torso", "arms", "legs"
			curIDs = character:GetData(index.."ProtIDs")

			-- print(curIDs)
			
			-- lessen the load during a fight
			table.remove(curIDs, self:GetData(index.."CurrentIndex"))
			self:SetData(index.."CurrentIndex", nil)

			if character:GetData(index.."GreatestProtector", nil) == self then
				character:SetData(index.."GreatestProtector", nil)
				findGreatestProtector(character, self, curIDs, index)
			end

			character:SetData(index.."ProtIDs", curIDs)
			character:SetData(index.."Redux", character:GetData(index.."Redux") - value)
			-- print("removed "..value.." from "..index)
			-- print("current protection on "..index.." is "..character:GetData(index.."Redux"))
		end
	end

	-- print("removed bonuses from " .. self.name)
end