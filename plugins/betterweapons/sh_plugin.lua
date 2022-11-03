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
            if ammoType and weapon:Clip1() ~= -1 and client:GetAmmoCount(ammoType) <= 1 and weapon:Clip1() <= 1 then
                local items = client:GetCharacter():GetInv():GetItems() -- returns a table of the player's items to go through
	            -- go through the player's entire inventory,
	            for k, v in pairs(items) do
                    if v.ammo == ammoType then
                        client:SetAmmo(v:GetData("rounds", v.ammoAmount) + client:GetAmmoCount(ammoType), ammoType)
                        v:Remove()
                        break
                    end
	            end
            end
        end
    end
end
