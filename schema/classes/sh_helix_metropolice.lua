CLASS.name = "HELIX Unit"
CLASS.faction = FACTION_MPF
CLASS.isDefault = false

function CLASS:CanSwitchTo(client)
	return Schema:IsCombineRank(client:Name(), "HELIX")
end

CLASS_HLX = CLASS.index