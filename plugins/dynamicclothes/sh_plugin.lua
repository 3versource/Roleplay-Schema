
PLUGIN.name = "Dynamic Clothing"
PLUGIN.author = "OctraSource"
PLUGIN.description = "Clothing that supports multiple bodygroup changes and model swapping, all in one package."

function PLUGIN:OnItemTransferred(item, curInv, oldInv)
    if item.isClothingItem and curInv != oldInv and item:GetData("equip", false) and then
        item:OnUnequipped(oldInv:GetOwner())
    end
end
