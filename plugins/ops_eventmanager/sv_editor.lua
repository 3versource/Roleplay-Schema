local PLUGIN = PLUGIN

concommand.Add("impulse_ops_eventmanager", function(ply)
	if not ply:IsAdmin() then
		return
	end

	local c = table.Count(PLUGIN.Ops.EventManager.Sequences)

	net.Start("impulseOpsEMMenu")
	net.WriteUInt(c, 8)

	for v,k in pairs(PLUGIN.Ops.EventManager.Sequences) do
		net.WriteString(v)	
	end

	net.Send(ply)
end)