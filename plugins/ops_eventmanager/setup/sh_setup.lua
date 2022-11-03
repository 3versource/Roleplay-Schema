local PLUGIN = PLUGIN

PLUGIN.Ops = PLUGIN.Ops or {}
PLUGIN.Ops.EventManager = PLUGIN.Ops.EventManager or {}
PLUGIN.Ops.EventManager.Sequences = PLUGIN.Ops.EventManager.Sequences or {}
PLUGIN.Ops.EventManager.Scenes = PLUGIN.Ops.EventManager.Scenes or {}
PLUGIN.Ops.EventManager.Data = PLUGIN.Ops.EventManager.Data or {}
PLUGIN.Ops.EventManager.Config = PLUGIN.Ops.EventManager.Config or {}

file.CreateDir("impulse/ops/eventmanager")

hook.Run("OpsSetup")