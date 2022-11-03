local PLUGIN = PLUGIN
PLUGIN.name = "Needs"
PLUGIN.author = "OctraSource"
PLUGIN.desc = "Adds the logic needed for needs."
PLUGIN.defaultMax = 100

ix.util.Include("sv_plugin.lua")

local playerMeta = FindMetaTable("Player")

function playerMeta:getHunger()
	return self:GetCharacter():GetData("hunger", PLUGIN.defaultMax)
end

function playerMeta:getThirst()
	return self:GetCharacter():GetData("thirst", PLUGIN.defaultMax)
end