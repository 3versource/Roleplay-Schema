

--[[
    Schema:KeyPress(client, key)
        Schema : adding a function within the schema
            Schema:KeyPress : a function that runs whenever any key is pressed by a player

]]
function Schema:KeyPress(client, key)
    -- if the player pressed their reload key (8192)
    if key == 8192 then
        character = client:GetCharacter()
        weapon = character:GetData("currentWeapon", nil)
        
        -- if the character and weapon exist,
        if character and weapon then
            maximum = weapon:GetMaxClip1()
            currentAmmo = weapon:Clip1()
            hasAnyAmmo = weapon:HasAmmo()
            charInv = character:GetInventory()

            -- finish up
            -- TODO: must set the data point "currentlyLoadedName" of this weapon item to whatever the ammo item they loaded (use the item's LoadWeapon() function!!)
        end
    end
end

function Schema:PlayerSwitchWeapon(ply, oldWep, newWep)
    print(tostring(ply).." swapped to "..tostring(newWep).." from "..tostring(oldWep))

    character = ply:GetCharacter()
    if character then
        character:SetData("currentWeapon", newWep)
    end
end
