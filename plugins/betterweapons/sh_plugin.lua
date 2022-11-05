local PLUGIN = PLUGIN
PLUGIN.name = 'Auto Ammo Loader'
PLUGIN.author = 'OctraSource'
PLUGIN.description = "Adds multiple weapons with unloading support and ammunition that is auto-loaded upon pressing the reload key."

if (SERVER) then
    function Schema:KeyPress(client, key)
        -- 8192 is the bind for +reload
        if key == 8192 then
            local weapon = client:GetActiveWeapon()
            local ammoType = game.GetAmmoName(weapon:GetPrimaryAmmoType())
            -- if the ammo isn't null or has no ammo value (hands, melees)
            if ammoType and weapon:Clip1() ~= -1 and client:GetAmmoCount(ammoType) == 0 and ammoType != "Buckshot" then
                -- if the gun has less than or equal to 1 bullet and the total ammo is less than or equal to one, then
                if weapon:Clip1() <= 1 then
                    local items = client:GetCharacter():GetInv():GetItems() -- returns a table of the player's items to go through
	                -- go through the player's entire inventory,
	                for k, v in pairs(items) do
                        if v.ammo == ammoType then
                            client:SetAmmo(v:GetData("rounds", v.ammoAmount) + client:GetAmmoCount(ammoType), ammoType)
                            v:Remove()
                            break
                        end
	                end
                    -- if the gun has more than 1 bullet in its clip, then
                elseif weapon:Clip1() > 1 then
                    local items = client:GetCharacter():GetInv():GetItems() -- returns a table of the player's items to go through
	                -- go through the player's entire inventory, check if there is another magazine in their inventory
	                for k, v in pairs(items) do
                        if v.ammo == ammoType then
                            -- if there a magazine in their inventory and it's the same ammo type as the gun,
                            local mag = weapon:Clip1()
                            -- set the player's current ammo to the value of the magazine in their inventory,
                            weapon:SetClip1(0)
                            client:SetAmmo(v:GetData("rounds", v.ammoAmount) + client:GetAmmoCount(ammoType), ammoType)
                            -- set that magazine to the player's old ammo count
                            v:SetData("rounds", mag)
                            break
                        end
                        -- if no magazine is found, do nothing
	                end
                    -- continue playing <3
                end 
            end
        end
    end
end
