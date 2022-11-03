local PLUGIN = PLUGIN
PLUGIN.name = 'Auto Ammo Loader'
PLUGIN.author = 'OctraSource'
PLUGIN.description = 'Automatically loads ammo into your gun if you have the correct ammo for it.'

if (SERVER) then
    function PLUGIN:EntityFireBullets(entity)
        if entity:IsPlayer() then
-- if the entity is a player and fired a gun (because you can only fire a gun if you're alive)
            local weapon = entity:GetActiveWeapon() -- store their active weapon
            local ammoName = game.GetAmmoName(weapon:GetPrimaryAmmoType()) -- store the ammo type of that weapon
            if (weapon:Clip1() == 0 and entity:GetAmmoCount(ammoName) == 0) then
                for k, v in pairs(entity:GetCharacter():GetInventory():GetItems()) do
                    if v.isAmmo and v.ammo == ammoName then
                        entity:SetAmmo(v:GetData("rounds", v.ammoAmount) + entity:GetAmmoCount(ammoName), ammoName)
                        v:Remove()
                        break
                    end
                end
            end
        end
    end
end
