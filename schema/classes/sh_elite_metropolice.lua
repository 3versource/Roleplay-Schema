CLASS.name = "Elite Metropolice"
CLASS.faction = FACTION_MPF
CLASS.isDefault = false
CLASS.canSeeWaypoints = true
CLASS.canAddWaypoints = true
CLASS.canRemoveWaypoints = true
CLASS.canUpdateWaypoints = true

function CLASS:CanSwitchTo(client)
	return (Schema:IsCombineRank(client:Name(), "WATCHER") or Schema:IsCombineRank(client:Name(), "OfC") or Schema:IsCombineRank(client:Name(), "SqL"))
end

CLASS_EMP = CLASS.index