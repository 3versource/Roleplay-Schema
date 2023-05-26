
PLUGIN.name = "Dynamic Clothing"
PLUGIN.author = "OctraSource"
PLUGIN.description = "A plugin that adds support for bodygroup and model clothing."

local MaxDamageMultiplier = 20
local MinDamageMultiplier = 0.1

local bodygroupProtection = {"head", "torso", "arms", "legs"}

local defaultHeadMultiplier = 4
local defaultTorsoMultiplier = 3
local defaultArmMultiplier = 3
local defaultLegMultiplier = 3

-- when the player spawns, equip their clothing
hook.Add("PlayerLoadedCharacter", "equipClothes", function(client, character)
	local items = character:GetInv():GetItems() -- returns a table of the player's items to go through
	-- go through the player's entire inventory,
	for k, v in pairs(items) do
		-- if the selected item is a clothing item and is equipped, then
		if v.isClothingItem and v:GetData("equip", false) then
			-- equip that item
			v:OnEquipped(true, client)
		end
	end
end)

-- for god's sake, avoid looping! This will freeze the game if this is called too much too rapidly!
function Schema:ScalePlayerDamage(ply, hitgroup, dmginfo)
    local character = ply:GetCharacter()
    if hitgroup == HITGROUP_HEAD then
		-- print("damage taken to head")	
		dmginfo:ScaleDamage(ix.config.Get("headDamage") * (math.Clamp(1 - character:GetData("headRedux", 0), 0, 1)))
		playerArmor = character:GetData("headGreatestProtector", nil)
		if playerArmor then
			playerArmor:Damage(1)
		end
		-- print("Head protection is " .. character:GetData("headRedux", 0))
    elseif hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_STOMACH then	
		-- print("damage taken to chest or stomach")
		dmginfo:ScaleDamage(ix.config.Get("torsoDamage") * (math.Clamp(1 - character:GetData("torsoRedux", 0), 0, 1)))
		playerArmor = character:GetData("torsoGreatestProtector", nil)
		if playerArmor then
			playerArmor:Damage(1)
		end
		-- print("Torso protection is " .. character:GetData("torsoRedux", 0))
    elseif hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then
		-- print("damage taken to left arm or right arm")
		dmginfo:ScaleDamage(ix.config.Get("armDamage") * (math.Clamp(1 - character:GetData("armsRedux", 0), 0, 1)))
		playerArmor = character:GetData("armsGreatestProtector", nil)
		if playerArmor then
			playerArmor:Damage(1)
		end
		-- print("Arm protection is " .. character:GetData("armsRedux", 0))
    elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
		-- print("damage taken to left leg or right leg")
		dmginfo:ScaleDamage(ix.config.Get("legDamage") * (math.Clamp(1 - character:GetData("legsRedux", 0), 0, 1)))
		playerArmor = character:GetData("legsGreatestProtector", nil)
		if playerArmor then
			playerArmor:Damage(1)
		end
		-- print("Leg protection is " .. character:GetData("legsRedux", 0))
    end
end /*
	Areas that can be hit on a playermodel
		HITGROUP_GENERIC
		HITGROUP_HEAD
		HITGROUP_CHEST
		HITGROUP_STOMACH
		HITGROUP_LEFTARM
		HITGROUP_RIGHTARM
		HITGROUP_LEFTLEG
		HITGROUP_RIGHTLEG
*/

ix.config.Add("headDamage", defaultHeadMultiplier, "The head damage multiplier.", nil, {
	data = {min = MinDamageMultiplier, max = MaxDamageMultiplier},
	category = "Damage Overhaul"
})

ix.config.Add("torsoDamage", defaultTorsoMultiplier, "The torso damage multiplier.", nil, {
	data = {min = MinDamageMultiplier, max = MaxDamageMultiplier},
	category = "Damage Overhaul"
})

ix.config.Add("armDamage", defaultArmMultiplier, "The arm damage multiplier.", nil, {
	data = {min = MinDamageMultiplier, max = MaxDamageMultiplier},
	category = "Damage Overhaul"
})

ix.config.Add("legDamage", defaultLegMultiplier, "The leg damage multiplier.", nil, {
	data = {min = MinDamageMultiplier, max = MaxDamageMultiplier},
	category = "Damage Overhaul"
})