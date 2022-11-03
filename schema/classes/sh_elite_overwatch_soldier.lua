CLASS.name = "Elite Overwatch Soldier"
CLASS.faction = FACTION_OTA
CLASS.isDefault = false
CLASS.canSeeWaypoints = true
CLASS.canAddWaypoints = true
CLASS.canRemoveWaypoints = true
CLASS.canUpdateWaypoints = true

function CLASS:OnSet(client)
	local character = client:GetCharacter()

	if (character) then
		character:SetModel("models/combine_super_soldier.mdl")
	end
end

CLASS_EOW = CLASS.index
