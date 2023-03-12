local PLUGIN = PLUGIN
PLUGIN.name = 'Dynamic Ammunition & Weapons'
PLUGIN.author = 'OctraSource'
PLUGIN.description = "Adds multiple weapons with unloading support and ammunition that is auto-loaded upon pressing the reload key."

if (SERVER) then
    function Schema:KeyPress(client, key)
        -- 8192 is the bind for +reload
        if key == 8192 then
            local weapon = client:GetActiveWeapon()
            local ammoType = game.GetAmmoName(weapon:GetPrimaryAmmoType())
            -- if the ammo isn't null or has no ammo value (hands, melees)
            if ammoType and weapon:Clip1() ~= -1 and client:GetAmmoCount(ammoType) == 0 and ammoType ~= "Buckshot" then
                local items = client:GetCharacter():GetInv():GetItems() -- returns a table of the player's items to go through 
                if weapon:Clip1() < 1 then -- this implies that their gun is EMPTY and their current magazine SHOULD NOT BE STORED
	                -- go through the player's entire inventory,
	                for k, v in pairs(items) do
                        if v.ammo == ammoType then
                            client:SetAmmo(v:GetData("rounds", v.ammoAmount), ammoType)
                            v:Remove()
                            break
                        end
	                end
                    -- if the gun has more than 1 bullet in its clip, then
                elseif weapon:Clip1() >= 1 then -- this implies that their gun is NOT EMPTY and their current magazine SHOULD BE STORED
                    local prevMagSize = 0 -- the size of the previous magazine
                    local newMag = nil -- the new magazine the player will load

	                -- go through the player's entire inventory,
                    for k, v in pairs(items) do
                        -- store the item with the highest ammo count as newMag, remembering the highest ammo count as prevMagSize
                        if v.ammo == ammoType and prevMagSize < v:GetData("rounds", v.ammoAmount) then
                            prevMagSize = v:GetData("rounds", v.ammoAmount)
                            newMag = v
                        end
                    end

                    -- if a magazine was found, then
                    if newMag then
                        local prevMag = weapon:Clip1() -- the player's current magazine that will be replaced
                        -- set their ammo to zero
                        weapon:SetClip1(0)
                        -- set the player's current ammo to the value of the magazine in their inventory,
                        client:SetAmmo(newMag:GetData("rounds", newMag.ammoAmount) + client:GetAmmoCount(ammoType), ammoType)
                        -- set that magazine to the player's old ammo count
                        newMag:SetData("rounds", prevMag)
                    end
                end
            end
        end
    end
end
