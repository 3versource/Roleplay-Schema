local PLUGIN = PLUGIN
PLUGIN.name = 'Weapons'
PLUGIN.author = 'OctraSource'
PLUGIN.description = "A better base for weapons in Helix."

ix.util.Include("sv_hooks.lua")

local playerMeta = FindMetaTable("Player")

function playerMeta:FindSmallestAmmoFor(weapon, inventory)
    local source

    for index, item in pairs(inventory) do
        -- add things to search for
        if weapon.item.fileName then
            source = item
        end
    end

    return source
end

function playerMeta:FindWeaponItem(weapon, inventory)
    for index, item in pairs(inventory) do
        if item:GetData("equip", false) and item.weapon == weapon then
            return item
        end
    end

    return false
end

function playerMeta:FindRefiller(weapon, inventory)
end