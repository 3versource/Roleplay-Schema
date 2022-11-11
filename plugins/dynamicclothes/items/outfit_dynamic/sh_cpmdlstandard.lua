ITEM.name = "Civil Protection Uniform"
ITEM.description = "A pair of heavy-duty kevlar pants."
ITEM.category = "Metropolice - Uniform"
ITEM.model = "models/props_junk/garbage_bag001a.mdl"
ITEM.playermodelBodygroupAndVariants = nil
ITEM.playermodelBodygroupChanges = 0
ITEM.playermodel = "models/police.mdl"
ITEM.isClothingItem = true
ITEM.forModel = nil
ITEM.mpf = "MPF-PTRL."
ITEM.armor = 50

/*
	forModel must be one of the following:

"models/ug/new/citizens"
"models/police"

	"this item is for this model"
	good for disabling people from equipping non-supported clothes
*/

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


function ITEM:PopulateTooltip(tooltip)
	local panel = tooltip:AddRowAfter("name", "armor")
	panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
	panel:SetText("Armor: " .. (self:GetData("equip") and LocalPlayer():Armor() or self:GetData("armor", self.armor)))
	panel:SizeToContents()
end