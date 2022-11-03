ITEM.base = "base_outfitfull"
ITEM.name = "Armored Clothes"
ITEM.description = "A suitcase full of clothes."
ITEM.model = Model("models/props_c17/suitcase_passenger_physics.mdl")
ITEM.category = "Armored Clothing"
ITEM.width = 2
ITEM.height = 2
ITEM.maxArmor = 0
ITEM.unitName = "unitName"
ITEM.className = CLASS_CITIZEN

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local panel = tooltip:AddRowAfter("name", "armor")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText("Armor: " .. (self:GetData("equip") and LocalPlayer():Armor() or self:GetData("armor", self.maxArmor)))
		panel:SizeToContents()
	end
end

function ITEM:OnEquipped()
	local ply = self.player
	local char = ply:GetCharacter()
	-- self refers to the item

	char:SetData("originalname", char:GetName())
	char:SetData("originalfaction", char:GetFaction())
	char:SetData("originalteam", ply:Team())
	char:SetData("originalclass", char:GetClass())

	if self:GetData("newname", nil) == nil then
		self:SetData("newname", tostring("MPF-"..self.unitName.."."..math.random(10000, 99999)))
	end
	
	-- 3 is MPF
	char:SetName(self:GetData("newname"))
	char:SetFaction(3)
	ply:SetTeam(3)
	char:JoinClass(self.className)

	ply:SetArmor(self:GetData("armor", self.maxArmor))
end

function ITEM:OnUnequipped()
	local ply = self.player
	local char = ply:GetCharacter()

	self:SetData("armor", math.Clamp(ply:Armor(), 0, self.maxArmor))
	ply:SetArmor(0)

	if char:GetName() != self:GetData("newname") then
		self:SetData("newname", char:GetName())
	end

	char:SetName(char:GetData("originalname"))
	char:SetFaction(char:GetData("originalfaction"))
	ply:SetTeam(char:GetData("originalteam"))
	char:JoinClass(char:GetData("originalclass"))
end

function ITEM:Repair(amount)
	self:SetData("armor", math.Clamp(self:GetData("armor") + amount, 0, self.maxArmor))
end

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		self.player:SetArmor(self:GetData("armor", self.maxArmor))
	end
end

function ITEM:OnSave()
	if (self:GetData("equip")) then
		self:SetData("armor", math.Clamp(self.player:Armor(), 0, self.maxArmor))
	end
end