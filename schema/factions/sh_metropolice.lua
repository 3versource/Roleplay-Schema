FACTION.name = "Metropolice Force"
FACTION.description = "A metropolice unit working as Civil Protection."
FACTION.color = Color(138, 171, 180)
FACTION.pay = 20
FACTION.canGoUnconcious = true
FACTION.models = {"models/police.mdl"}
FACTION.isDefault = false
FACTION.isGloballyRecognized = true
FACTION.canSeeWaypoints = true
FACTION.runSounds = {[0] = "NPC_MetroPolice.RunFootstepLeft", [1] = "NPC_MetroPolice.RunFootstepRight"}

local id

function FACTION:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()

	inventory:Add("pistol", 1)
	inventory:Add("stunstick", 1)
	inventory:Add("pistolammo", 2)
	inventory:Add("handheld_radio", 1)

	character:SetData("cid", id)

	inventory:Add("cid", 1, {
		name = character:GetName(),
		id = id
	})
end

function FACTION:GetDefaultName(client)
	id = Schema:ZeroNumber(math.random(1, 99999), 5)
	return "MPF-RCT." .. id, true
end

function FACTION:OnTransfered(client)
	local character = client:GetCharacter()

	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])
end

function FACTION:OnNameChanged(client, oldValue, value)
	local character = client:GetCharacter()

	if (!Schema:IsCombineRank(oldValue, "RCT") and Schema:IsCombineRank(value, "RCT")) then
		character:JoinClass(CLASS_MPR)
	else
		character:JoinClass(CLASS_MPU)
	end
end

FACTION_MPF = FACTION.index