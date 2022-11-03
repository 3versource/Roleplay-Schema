ITEM.name = "medBase"
ITEM.description = "Medical base"
ITEM.category = "Medical"

ITEM.recovery = 1
ITEM.sound = "items/medshot4.wav"

ITEM.functions.apply = {
	name = "Apply",
	icon = "icon16/pill.png",
	OnRun = function(item)
		local ply = item.player
		local char = ply:GetCharacter()

		if ply:Health() < 25 then
			char:UpdateAttrib("medefficiency", 1)
		end

		ply:SetHealth(math.min(ply:Health() + item.recovery + ((char:GetAttribute("medefficiency") or  0) * .25), 100, ply:GetMaxHealth()))
		ply:EmitSound(item.sound)
	end
}

ITEM.functions.applyToTarget = {
	name = "Apply To",
	icon = "icon16/pill_go.png",
	OnRun = function(item)
		local ply = item.player
		local char = ply:GetCharacter()

		local data = {}
			data.start = ply:GetShootPos()
			data.endpos = data.start + ply:GetAimVector() * 96
			data.filter = ply

		local target = util.TraceLine(data).Entity

		if IsValid(target) and target:IsPlayer() and target:GetCharacter() then

			if target:Health() < 25 then
				char:UpdateAttrib("medefficiency", 1)
			end

			target:SetHealth(math.min(target:Health() + item.recovery + ((char:GetAttribute("medefficiency") or  0) * .25), 100, target:GetMaxHealth()))
			target:EmitSound(item.sound)

			return true
		end
		ply:NotifyLocalized("Invalid target.")
		return false
	end,
	OnCanRun = function(item)
		-- only runs when inside the player's inventory
		return !IsValid(item.entity) and IsValid(ply) and item.player:GetCharacter():GetInventory():GetItemByID(item.id)
	end
}
