local PLUGIN = PLUGIN
local playerMeta = FindMetaTable("Player")

function PLUGIN.Ops.EventManager.GetEventMode()
    return GetGlobalBool("opsEventMode", false)
end

function PLUGIN.Ops.EventManager.GetSequence()
	local val = GetGlobalString("opsEventSequence", "")

	if val == "" then
		return
	end

    return val
end

function PLUGIN.Ops.EventManager.SetEventMode(val)
	return SetGlobalBool("opsEventMode", val)
end

function PLUGIN.Ops.EventManager.SetSequence(val)
	return SetGlobalString("opsEventSequence", val)
end

function PLUGIN.Ops.EventManager.GetCurEvents()
	return PLUGIN_OpsEM_CurEvents
end

function playerMeta:IsEventAdmin()
	return self:IsSuperAdmin() or (self:IsAdmin() and PLUGIN.Ops.EventManager.GetEventMode())
end

if SERVER then
	concommand.Add("impulse_ops_eventmode", function(ply, cmd, args)
		if not IsValid(ply) or ply:IsSuperAdmin() then
			if args[1] == "1" then
				PLUGIN.Ops.EventManager.SetEventMode(true)
				print("[ops-em] Event mode ON")
			else
				PLUGIN.Ops.EventManager.SetEventMode(false)
				print("[ops-em] Event mode OFF")
			end
		end
	end)
end