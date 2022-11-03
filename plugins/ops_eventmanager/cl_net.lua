local PLUGIN = PLUGIN

net.Receive("impulseOpsEMMenu", function()
	local count = net.ReadUInt(8)
	local svSequences = {}

	for i=1, count do
		table.insert(svSequences, net.ReadString())
	end

	if impulse_eventmenu and IsValid(impulse_eventmenu) then
		impulse_eventmenu:Remove()
	end
	
	impulse_eventmenu = vgui.Create("impulseEventManager")
	impulse_eventmenu:SetupPlayer(svSequences)
end)

net.Receive("impulseOpsEMUpdateEvent", function()
	local event = net.ReadUInt(10)

	PLUGIN_OpsEM_LastEvent = event

	PLUGIN_OpsEM_CurEvents = PLUGIN_OpsEM_CurEvents or {}
	PLUGIN_OpsEM_CurEvents[event] = CurTime()
end)

net.Receive("impulseOpsEMClientsideEvent", function()
	local event = net.ReadString()
	local uid = net.ReadString()
	local len = net.ReadUInt(16)
	local prop = pon.decode(net.ReadData(len))

	if not PLUGIN.Ops.EventManager then
		return
	end

	local sequenceData = PLUGIN.Ops.EventManager.Config.Events[event]

	if not sequenceData then
		return
	end

	if not uid or uid == "" then
		uid = nil
	end

	sequenceData.Do(prop or {}, uid)
end)

net.Receive("impulseOpsEMPlayScene", function()
	local scene = net.ReadString()

	if not PLUGIN.Ops.EventManager.Scenes[scene] then
		return print("[impulse] Error! Can't find sceneset: "..scene)
	end

	PLUGIN.Scenes.PlaySet(PLUGIN.Ops.EventManager.Scenes[scene])
end)

local customAnims = customAnims or {}
net.Receive("impulseOpsEMEntAnim", function()
	local entid = net.ReadUInt(16)
	local anim = net.ReadString()

	customAnims[entid] = anim

	timer.Remove("opsAnimEnt"..entid)
	timer.Create("opsAnimEnt"..entid, 0.05, 0, function()
		local ent = Entity(entid)

		if IsValid(ent) and customAnims[entid] and ent:GetSequence() == 0 then
			ent:ResetSequence(customAnims[entid])
		end
	end)
end)

net.Receive("impulseCinematicMessage", function()
	local title = net.ReadString()

	PLUGIN.CinematicIntro = true
	PLUGIN.CinematicTitle = title
end)