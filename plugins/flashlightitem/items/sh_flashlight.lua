
ITEM.name = "Flashlight"
ITEM.model = "models/ug_imports/clockwork/flashlight.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A tool for lighting up your surroundings."
ITEM.category = "Tools"

ITEM:Hook("drop", function(item)
	item.player:Flashlight(false)
end)
