PLUGIN.name = "Friendly Combine NPCs for Combine Character"
PLUGIN.author = "JohnyReaper"
PLUGIN.description = ""

if (SERVER) then

    local combineNPCs = {  
        ["npc_metropolice"] = true,
        ["npc_combine_s"] = true,
        ["CombinePrison"] = true,
        ["npc_cscanner"] = true,
        ["npc_manhack"] = true,
        ["PrisonShotgunner"] = true,
        ["ShotgunSoldier"] = true,
        ["npc_turret_floor"] = true,
        ["npc_clawscanner"] = true,
        ["npc_rollermine"] = true,
        ["npc_vj_hlr2_com_civilp"] = true
    }

    function PLUGIN:OnEntityCreated(entity)
        if (entity:IsNPC()) then
            for _, client in pairs(player.GetAll()) do
                local charplayer = client:GetCharacter()

                if (charplayer:IsCombine()) then
                    if combineNPCs[entity:GetClass()] then
                        entity:AddEntityRelationship(client, D_LI, 99)
                        combine_npcs = combine_npcs or {}
                        combine_npcs[entity] = true
                    end
                end
            end

        end
    end

    function PLUGIN:EntityRemoved(entity)
        if (entity:IsNPC()) then
            combine_npcs = combine_npcs or {}
            combine_npcs[entity] = nil
        end
    end

    function PLUGIN:PlayerSpawn(client)
        local charplayer = client:GetCharacter()

        if (charplayer and combine_npcs) then
    
            if (charplayer:IsCombine()) then
                for ent, v in pairs(combine_npcs) do
                    if combineNPCs[ent:GetClass()] then
                        ent:AddEntityRelationship(client, D_LI, 99)
                    end
                end
            else
                for ent, v in pairs(combine_npcs) do
                    if combineNPCs[ent:GetClass()] then
                        ent:AddEntityRelationship(client, D_HT, 99)
                    end
                end
            end
        end
    end
end