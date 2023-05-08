CLASS.name = "Metropolice Unit"
CLASS.faction = FACTION_MPF

function CLASS:CanSwitchTo(client)
	local name = client:Name()

	for k, v in ipairs({ "04", "03", "02", "01", "OfC" }) do
		if (Schema:IsCombineRank(name, v)) then
			return true
		end
	end

	return false
end

CLASS_MPU = CLASS.index