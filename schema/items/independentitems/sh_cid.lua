
ITEM.name = "Universal Union Identification Card"
ITEM.model = Model("models/ug_imports/cid.mdl")
ITEM.description = "An identification card with ID #%s, assigned to %s."

function ITEM:GetDescription()
	return string.format(self.description, self:GetData("id", "00404"), self:GetData("name", "nobody"))
end
