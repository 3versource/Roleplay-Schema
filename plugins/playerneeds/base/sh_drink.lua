ITEM.name = "waterBase"
ITEM.description = "Water Base"
ITEM.model = "models/error.mdl"
ITEM.category = "Drink"
ITEM.portions = 4

ITEM.restThirst = 1
ITEM.sound = "npc/barnacle/barnacle_gulp2.wav"

ITEM.functions.Drink = {
	name = "Consume All",
	icon = "icon16/cup.png",
	OnRun = function(item)
		-- lowercase "item" in variable calls
		item.player:addThirst(item.restThirst * (item:GetData("portions", item.portions) / item.portions))
		item.player:EmitSound(item.sound)
	end
}

ITEM.functions.drinkPortion = {
	name = "Consume Portion",
	icon = "icon16/heart.png",
	OnRun = function(item)
        -- lowercase "item" in variable calls
		item.player:addThirst(item.restThirst / item.portions)
		item.player:EmitSound(item.sound)
		 
		item:SetData("portions", item:GetData("portions", item.portions) - 1)

		if item:GetData("portions") < 1 then
			return true
		end
		return false
	end
}
