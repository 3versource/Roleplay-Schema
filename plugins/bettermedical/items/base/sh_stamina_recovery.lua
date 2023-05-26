ITEM.name = "stamRecovBase"
ITEM.description = "Stamina Recovery Base"
ITEM.category = "Medical"
ITEM.staminaRestored = 1
ITEM.sound = "items/medshot4.wav"

ITEM.functions.apply = {
	name = "Inject",
	icon = "icon16/pill.png",
	OnRun = function(item)
		local ply = item.player
		local char = ply:GetCharacter()

		SparkTarget(ply, item.staminaRestored, ply)

		ply:EmitSound(item.sound)
		return true
	end
}

ITEM.functions.applyToTarget = {
	name = "Inject Into",
	icon = "icon16/pill_go.png",
	OnRun = function(item)
		local ply = item.player
		local char = ply:GetCharacter()

		local target = AimTargetValid(ply)

		if target then
			SparkTarget(target, item.staminaRestored. ply)
			target:EmitSound(item.sound)
			return true
		end

		ply:NotifyLocalized("Invalid target.")
		return false
	end,
	OnCanRun = function(item)
		-- only runs when inside the player's inventory
		return !IsValid(item.entity) and IsValid(item.player) and item.player:GetCharacter():GetInventory():GetItemByID(item.id) and AimTargetValid(item.player)
	end
}

function ITEM:PopulateTooltip(tooltip)
	local panel = tooltip:AddRowAfter("name", "portions")
	panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
	panel:SetText("Recovers " .. self.staminaRestored .. " Stamina")
	panel:SizeToContents()
end	

-- returns true if the player is looking at a character
function AimTargetValid(ply)
	local data = {}
	data.start = ply:GetShootPos()
	data.endpos = data.start + ply:GetAimVector() * 96
	data.filter = ply

	local target = util.TraceLine(data).Entity

	if IsValid(target) and target:IsPlayer() and target:GetCharacter() then
		return target
	end

	return false
end

/*
	target: The player who's being sparked
	amount: The amount the target is being sparked
    sparker: The person sparking
*/
function SparkTarget(target, amount, sparker)
	target:RestoreStamina(amount)
    target:SetRagdolled(false)

    char = target:GetCharacter()

    char:AddBoost(110, "stm", 40)
	char:AddBoost(111, "end", 20)
    char:SetData("adrenalineBoostTime", 10 + sparker:GetCharacter():GetAttribute("medefficiency") + CurTime())
end