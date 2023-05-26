ITEM.name = "medBase"
ITEM.description = "Medical base"
ITEM.category = "Medical"

ITEM.recovery = 1
ITEM.sound = "items/medshot4.wav"

local healMultiplier = 1 -- multipies the value below to modify how much more health is added 
						 -- default: +20 more hp is healed with max medical efficiency
local skillIncreaseThreshold = 20 -- max amount of health that can be present in order to gain an attribute point

ITEM.functions.apply = {
	name = "Apply",
	icon = "icon16/pill.png",
	OnRun = function(item)
		local ply = item.player
		local char = ply:GetCharacter()

		UpdateAttribute(ply, char)
		HealTarget(ply, item.recovery, char)

		ply:EmitSound(item.sound)
		return true
	end
}

ITEM.functions.applyToTarget = {
	name = "Apply To",
	icon = "icon16/pill_go.png",
	OnRun = function(item)
		local ply = item.player
		local char = ply:GetCharacter()

		local target = AimTargetValid(ply)

		if target then
			UpdateAttribute(target, char)
			HealTarget(target, item.recovery, char)
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
	panel:SetBackgroundColor(derma.GetColor("Success", tooltip))
	panel:SetText("Recovers " .. self.recovery .. " Health")
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
	target: The player who's being healed
	amount: The amount the target is being healed
	healerCharacter: The healer's character
*/
function HealTarget(target, amount, healerCharacter)
	local maxHP = target:GetMaxHealth()
	local health = target:Health()
	local healAmount = amount + ((healerCharacter:GetAttribute("medefficiency") or 0) * healMultiplier)
	target:SetHealth(math.Clamp(health + healAmount, 0, maxHP))
end

/*
	target: The player you're healing
	healerCharacter: The character who's healing
*/
function UpdateAttribute(target, healerCharacter)
	if target:Health() <= skillIncreaseThreshold then
		healerCharacter:UpdateAttrib("medefficiency", 1)
	end
end