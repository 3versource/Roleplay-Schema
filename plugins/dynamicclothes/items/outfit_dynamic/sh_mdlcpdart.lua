ITEM.name = "Civil Protection Dart Uniform"
ITEM.description = "nodesc"
ITEM.category = "Metropolice - Uniform"
ITEM.model = "models/props_junk/garbage_bag001a.mdl"
ITEM.playermodelBodygroupAndVariants = {0, 0, 1, 0, 2, 0, 3, 1, 4, 0, 5, 0, 6, 0, 7, 0}
ITEM.playermodelBodygroupChanges = 7
ITEM.playermodel = "models/police.mdl"
ITEM.isClothingItem = true
ITEM.forModel = "models/ug/new/citizens"
ITEM.mpf = "MPF-DART."
ITEM.maxArmorHP = 100
ITEM.limbs = {["head"] = .3, ["torso"] = .25, ["arms"] = .2, ["legs"] = .1}

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