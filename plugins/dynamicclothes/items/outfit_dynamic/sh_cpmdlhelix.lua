ITEM.name = "Civil Protection Helix Uniform"
ITEM.description = "A pair of heavy-duty kevlar pants."
ITEM.category = "Metropolice - Uniform"
ITEM.model = "models/props_junk/garbage_bag001a.mdl"
ITEM.playermodelBodygroupAndVariants = {0, 1, 1, 0, 2, 0, 3, 1, 4, 0, 5, 0, 6, 0, 7, 0}
ITEM.playermodelBodygroupChanges = 7
ITEM.playermodel = "models/police.mdl"
ITEM.isClothingItem = true
ITEM.forModel = "models/ug/new/citizens"
ITEM.mpf = "MPF-HELIX."
ITEM.armor = 25

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
	skin - 0
	manhack - 1
	mask - 2
	radio - 3
	cloak/summka - 4
	spine radio - 5
	tactical shit - 6
	neck - 7
*/



function ITEM:PopulateTooltip(tooltip)
	local panel = tooltip:AddRowAfter("name", "armor")
	panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
	panel:SetText("Armor: " .. (self:GetData("equip") and LocalPlayer():Armor() or self:GetData("armor", self.armor)))
	panel:SizeToContents()
end