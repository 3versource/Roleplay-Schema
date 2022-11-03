--[[
MIT License

Copyright (c) 2020 vin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

All included credit in the software is not edited.

The name or brand identity of 'impulse' is not deformed or changed. This
includes all references to 'impulse'.

The software, in whole, or any part of it is not sold.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]


local PLUGIN = PLUGIN

PLUGIN.name = "ops_eventmanager"
PLUGIN.description = "Impulse event manager "
PLUGIN.author = "vingard, Ported by: Stalker"

ix.util.Include("setup/sh_setup.lua")
ix.util.Include("cl_editor.lua")
ix.util.Include("cl_scenes.lua")
ix.util.Include("sv_npcs.lua")
ix.util.Include("sv_net.lua")
ix.util.Include("sv_eventplayer.lua")
ix.util.Include("sv_editor.lua")
ix.util.Include("sh_main.lua")
ix.util.Include("sh_eventmanager.lua")
ix.util.Include("sh_config.lua")
ix.util.Include("cl_net.lua")
ix.util.Include("cl_editor.lua")


local meta = FindMetaTable("Player")

function meta:AllowScenePVSControl(bool)
    self.allowPVS = bool

    if not bool then
        self.extraPVS = nil
        self.extraPVS2 = nil
    end
end
