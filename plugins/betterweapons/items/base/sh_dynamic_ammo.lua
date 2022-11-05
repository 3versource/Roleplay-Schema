-- name of the ammo
ITEM.name = nil
-- the model of the ammo
ITEM.model = nil
-- the category of the ammo
ITEM.category = "Ammunition"
-- the ammo type
ITEM.ammo = nil
-- the amount of ammo
ITEM.ammoAmount = nil
-- the description of the ammo
ITEM.description = nil

-- set this to TRUE if the ammo type is not magazine-based
ITEM.isFed = false

/*
	the data point "rounds" will give you the amount of ammo inside an ammo item
	modified when unloading ammo from a gun
	used when loading ammo into a gun
	be sure to default to ammoAmount
*/
function ITEM:GetDescription()
	local rounds = self:GetData("rounds", self.ammoAmount)
	return Format(self.description, rounds)
end

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		draw.SimpleText(
			item:GetData("rounds", item.ammoAmount), "DermaDefault", w - 5, h - 5,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black
		)
	end
end