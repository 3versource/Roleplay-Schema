PLUGIN.name = "Writables"
PLUGIN.author = "OctraSource"
PLUGIN.description = "A plugin that adds items that players can write onto."

hook.Add("PlayerLoadedCharacter", "cleanReadingStatuses", function(client, character)
	-- all characters can initially read
	character:SetData("canRead", true)
end)