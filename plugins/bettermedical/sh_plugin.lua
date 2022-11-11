PLUGIN.name = "Better Medical"
PLUGIN.author = "OctraSource"
PLUGIN.description = "Medical items that are affected by a medical attribute and other tidbits with player health."

local defaultPlayerHealth = 100

function Schema:PlayerHurt(client, attacker, health)
    if health <= 10 then
        local char = client:GetCharacter()
        client:SetRagdolled(true, 30 - (char:GetAttribute("vitality") or 0))
        char:UpdateAttrib("vitality", 1)
        client:ChatNotify("Your vision darkens and causes you to fall out of consciousness.")
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