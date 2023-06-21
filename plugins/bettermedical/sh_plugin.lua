local PLUGIN = PLUGIN

PLUGIN.name = "Better Medical"
PLUGIN.author = "OctraSource"
PLUGIN.description = "Medical items that are affected by a medical attribute and other tidbits with player health."

local defaultPlayerHealth = 100

function Schema:PlayerHurt(client, attacker, health, damage)
    local char = client:GetCharacter()
    if health <= 10 then
        client:SetRagdolled(true, 30 - (char:GetAttribute("vitality") or 0))
        char:UpdateAttrib("vitality", .5)
        client:ChatNotify("Your vision darkens and causes you to fall out of consciousness.")
    else
        char:UpdateAttrib("vitality", .005)
    end

    -- pings combine players that a biosignal-activated player has been hurt
    if (client:IsCombine() and (client.ixTraumaCooldown or 0) < CurTime()) then
		local text = "External"

		if (damage > 50) then
			text = "Severe"
		end

		client:AddCombineDisplayMessage("@cTrauma", Color(255, 0, 0, 255), text)

		if (health < 25) then
			client:AddCombineDisplayMessage("@cDroppingVitals", Color(255, 0, 0, 255))
		end

		client.ixTraumaCooldown = CurTime() + 10

		if !client:GetNetVar("IsBiosignalGone") then
			local location = client:GetArea() != "" and client:GetArea() or "unknown location"
			local digits = string.match(client:Name(), "%d%d%d%d?%d?") or 0

			-- Alert all other units.
			Schema:AddCombineDisplayMessage("Downloading trauma packet...", Color(255, 255, 255, 255))
			Schema:AddCombineDisplayMessage("ALERT! Vital signs dropping for protection team unit " .. digits .. " at " .. location .. "...", Color(255, 255, 0, 255))
		end
	end

    -- if the player is a paintaker,
    if char:GetAttribute("paintaker", 0) ~= 0 then
        client:RestoreStamina(char:GetAttribute("paintaker", 0))
    end
end

-- update the player's maximum health
function UpdateMaxHealth(ply, char)
    ply:SetMaxHealth(defaultPlayerHealth + (char:GetAttribute("vitality") or 0))
end

-- upon the character being loaded, set the player's new max health
function PLUGIN:PlayerLoadedCharacter(client, character)
    UpdateMaxHealth(client, character)
end

-- upon the attribute being updated, set the player's new max health
function PLUGIN:CharacterAttributeUpdated(client, self, key, value)
    if key == "vitality" then
        UpdateMaxHealth(client, client:GetCharacter())
    end
end

function Schema:PlayerSpawn(client)
    if client:GetCharacter() then
        UpdateMaxHealth(client, client:GetCharacter())
    end
end

function PLUGIN:PlayerPostThink(client)
    if !client:Alive() or !client:GetCharacter() or !client:GetCharacter():GetData("adrenalineBoostTime", false) then return end

    local time = CurTime()
    local char  = client:GetCharacter()

    if char:GetData("adrenalineBoostTime", 0) < CurTime() then
        char:SetData("adrenalineBoostTime", false)
        char:RemoveBoost(110, "stm")
        char:RemoveBoost(111, "end")
    end
end