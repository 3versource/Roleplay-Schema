ITEM.name = "Heavy Coat"
ITEM.description = "A dark heavy coat."
ITEM.category = "Clothes - Torso"
ITEM.model = "models/props_junk/cardboard_box004a.mdl"
ITEM.playermodelBodygroupAndVariants = {1, 12}
ITEM.playermodelBodygroupChanges = 1
ITEM.isClothingItem = true
ITEM.forModel = "models/ug/new/citizens"
ITEM.maxArmorHP = 15
ITEM.limbs = {["head"] = 0, ["torso"] = .15, ["arms"] = .1, ["legs"] = 0}

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