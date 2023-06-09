local PLUGIN = PLUGIN

PLUGIN.name = "Writables"
PLUGIN.author = "OctraSource"
PLUGIN.description = "A plugin that adds items that players can write onto."

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")

-- full list of helix-defined hooks: https://docs.gethelix.co/hooks/plugin/