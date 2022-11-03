local PLUGIN = PLUGIN
util.AddNetworkString("impulseOpsEMMenu")
util.AddNetworkString("impulseOpsEMPushSequence")
util.AddNetworkString("impulseOpsEMUpdateEvent")
util.AddNetworkString("impulseOpsEMPlaySequence")
util.AddNetworkString("impulseOpsEMStopSequence")
util.AddNetworkString("impulseOpsEMClientsideEvent")
util.AddNetworkString("impulseOpsEMIntroCookie")
util.AddNetworkString("impulseOpsEMPlayScene")
util.AddNetworkString("impulseOpsEMEntAnim")
util.AddNetworkString("impulseScenePVS")
util.AddNetworkString("impulseCinematicMessage")

net.Receive("impulseOpsEMPushSequence", function(len, ply)
	if (ply.nextOpsEMPush or 0) > CurTime() then return end
	ply.nextOpsEMPush = CurTime() + 1

	if not ply:IsEventAdmin() then
		return
	end

	local seqName = net.ReadString()
	local seqEventCount = net.ReadUInt(16)
	local events = {}

	print("[ops-em] Starting pull of "..seqName.." (by "..ply:SteamName().."). Total events: "..seqEventCount.."")

	for i=1, seqEventCount do
		local dataSize = net.ReadUInt(16)
		local eventData = pon.decode(net.ReadData(dataSize))

		table.insert(events, eventData)
		print("[ops-em] Got event "..i.."/"..seqEventCount.." ("..eventData.Type..")")
	end

	PLUGIN.Ops.EventManager.Sequences[seqName] = events

	print("[ops-em] Finished pull of "..seqName..". Ready to play sequence!")

	if IsValid(ply) then
		ply:Notify("Push completed.")
	end
end)

net.Receive("impulseOpsEMPlaySequence", function(len, ply)
	if (ply.nextOpsEMPlay or 0) > CurTime() then return end
	ply.nextOpsEMPlay = CurTime() + 1

	if not ply:IsEventAdmin() then
		return
	end

	local seqName = net.ReadString()

	if not PLUGIN.Ops.EventManager.Sequences[seqName] then
		return ply:Notify("Sequence does not exist on server (push first).")
	end

	if PLUGIN.Ops.EventManager.GetSequence() == seqName then
		return ply:Notify("Sequence already playing.")
	end

	PLUGIN.Ops.EventManager.PlaySequence(seqName)

	print("[ops-em] Playing sequence "..seqName.." (by "..ply:SteamName()..").")
	ply:Notify("Playing sequence "..seqName..".")
end)
local PLUGIN = PLUGIN

net.Receive("impulseOpsEMStopSequence", function(len, ply)
	if (ply.nextOpsEMStop or 0) > CurTime() then return end
	ply.nextOpsEMStop = CurTime() + 1

	if not ply:IsEventAdmin() then
		return
	end

	local seqName = net.ReadString()

	if not PLUGIN.Ops.EventManager.Sequences[seqName] then
		return ply:Notify("Sequence does not exist on server (push first).")
	end

	if PLUGIN.Ops.EventManager.GetSequence() != seqName then
		return ply:Notify("Sequence not playing.")
	end

	PLUGIN.Ops.EventManager.StopSequence(seqName)

	print("[ops-em] Stopping sequence "..seqName.." (by "..ply:SteamName()..").")
	ply:Notify("Stopped sequence "..seqName..".")
end)

net.Receive("impulseOpsEMIntroCookie", function(len, ply)
	if ply.usedIntroCookie or not PLUGIN.Ops.EventManager.GetEventMode() then
		return
	end
	
	ply.usedIntroCookie = true

	ply:AllowScenePVSControl(true)

	timer.Simple(900, function()
		if IsValid(ply) then
			ply:AllowScenePVSControl(false)
		end
	end)
end)

net.Receive("impulseScenePVS", function(len, ply)
	if (ply.nextPVSTry or 0) > CurTime() then return end
	ply.nextPVSTry = CurTime() + 1

	if ply:Team() == 0 or ply.allowPVS then -- this code needs to be looked at later on, it trusts client too much, pvs locations should be stored in a shared tbl
		local pos = net.ReadVector()
		local last = ply.lastPVS or 1

		if last == 1 then
			ply.extraPVS = pos
			ply.lastPVS = 2
		else
			ply.extraPVS2 = pos
			ply.lastPVS = 1
		end

		timer.Simple(1.33, function()
			if not IsValid(ply) then
				return
			end

			if last == 1 then
				ply.extraPVS2 = nil
			else
				ply.extraPVS = nil
			end
		end)
	end
end)

function PLUGIN.CinematicIntro(message)
	net.Start("impulseCinematicMessage")
	net.WriteString(message)
	net.Broadcast()
end

concommand.Add("impulse_cinemessage", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	
	PLUGIN.CinematicIntro(args[1] or "")
end)