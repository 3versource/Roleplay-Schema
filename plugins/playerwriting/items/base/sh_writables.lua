ITEM.name = "writables base"
ITEM.description = "some writable surface"
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.category = "Writables"
ITEM.width = 1
ITEM.height = 1
ITEM.windowHeight = 600
ITEM.windowWidth = 600
ITEM.pages = 1


--[[
    ITEM:PopulateToolTip(tooltip)
        ITEM : specifying that this is a function of an item
            ITEM:PopulateToolTip(tooltip)
                tooltip : helix-defined. the specific tooltip in question

            This makes a popup on an item whenever you hover over it. This is helix-defined.
]]
function ITEM:PopulateTooltip(tooltip)
    if self:GetData("itemSigner") then
        local panel = tooltip:AddRowAfter("name", "portions")
        panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
        panel:SetText("This writable item has been signed; its contents can't be edited.")
        panel:SizeToContents()
    end
end	


--[[
    ITEM:IsInPlayerInventory()
        ITEM : specifying that this is a function of an item
            ITEM:IsInPlayerInventory()
            
            A function I made that checks if the item in question is on the ground and if it's in the player who's running the item's function's inventory.
]]
function ITEM:IsInPlayerInventory()
    -- if self.entity exists, then the physical model representing this item is somewhere in the world.
    -- if self.player is not equal to self:GetOwner(), then the item is not in the player who is running this item's function's inventory.
    return !IsValid(self.entity) and self.player == self:GetOwner()
end


--[[
    ITEM : specifying that this is a property (variable) of an item
        ITEM.functions : helix-defined property that stores functions of the item ITEM
            ITEM.functions.Read : a function that is meant to pop up a derma menu consisting of text boxes representing the "pages" of a writable item.
                name : helix-defined. the name that appears on the dropdown list to run this function
                icon : helix-defined. the icon that appears next to the name. full list of icons can be found at https://heyter.github.io/js-famfamfam-search/
                OnRun : helix-defined. a variable that stores a function that runs whenever the dropdown menu option is clicked by the player.
                    OnRun = function(item)
                        item : helix-defined. the item that is currently running this function.
                        
                    if this is returned as true, then the item deletes itself after running the function.
                    if returned false, then the item doesn't delete itself from the player's inventory.
                OnCanRun : helix-defined. a variable that stores a function that is intended to be used as a conditional statement on whether or not the player should
                            be able to run the function OnRun.
                    OnCanRun = function(item)
                        item : helix-defined. the item that is currently running this function.
                        
                    if returned as true, then the player will be able to see this function of the item in the dropdown menu.
                    if returned as false, then the player won't be able to run the function of this item.
    
]]
ITEM.functions.Read = {
    name = "Read",
    icon = "icon16/zoom.png",
    OnRun = function(item)
        local canEdit = true

        -- if there's a signer to this item or the item is on the ground, then it can't be edited
        if item:GetData("itemSigner", false) or not(item:IsInPlayerInventory()) then
            canEdit = false
        end

        -- tell the server to initiate a client-side derma menu
        netstream.Start(item.player, "readingWritableItem", 
                        item:GetID(), item.windowHeight, 
                        item.windowWidth, canEdit, 
                        item:GetData("previousPages", {}), 
                        item.pages) 

        return false
    end,
    OnCanRun = function(item)
        -- players can always read a readable item
        return true
    end
}


--[[
    ITEM : specifying that this is a property (variable) of an item
        ITEM.functions : helix-defined property that stores functions of the item ITEM
            ITEM.functions.Sign : a function that is meant to prevent the writable item from further edits.
                name : helix-defined. the name that appears on the dropdown list to run this function
                icon : helix-defined. the icon that appears next to the name. full list of icons can be found at https://heyter.github.io/js-famfamfam-search/
                OnRun : helix-defined. a variable that stores a function that runs whenever the dropdown menu option is clicked by the player.
                    OnRun = function(item)
                        item : helix-defined. the item that is currently running this function.
                        
                    if this is returned as true, then the item deletes itself after running the function.
                    if returned false, then the item doesn't delete itself from the player's inventory.
                OnCanRun : helix-defined. a variable that stores a function that is intended to be used as a conditional statement on whether or not the player should
                            be able to run the function OnRun.
                    OnCanRun = function(item)
                        item : helix-defined. the item that is currently running this function.
                        
                    if returned as true, then the player will be able to see this function of the item in the dropdown menu.
                    if returned as false, then the player won't be able to run the function of this item.
    
]]
ITEM.functions.Sign = {
    name = "Sign",
    icon = "icon16/accept.png",
    OnRun = function(item)
        item:SetData("itemSigner", item.player:GetCharacter():GetID())
        return false
    end,
    OnCanRun = function(item)
        -- if the item is in the player's inventory AND there is no signer, then you can sign this
        if item:IsInPlayerInventory() and item:GetData("itemSigner", nil) == nil then
            return true
        end

        return false
    end
}


--[[
    ITEM : specifying that this is a property (variable) of an item
        ITEM.functions : helix-defined property that stores functions of the item ITEM
            ITEM.functions.Unsign : a function that is meant to allow edits on an item that has been signed. can only be done by the player who signed this item.
                name : helix-defined. the name that appears on the dropdown list to run this function
                icon : helix-defined. the icon that appears next to the name. full list of icons can be found at https://heyter.github.io/js-famfamfam-search/
                OnRun : helix-defined. a variable that stores a function that runs whenever the dropdown menu option is clicked by the player.
                    OnRun = function(item)
                        item : helix-defined. the item that is currently running this function.
                        
                    if this is returned as true, then the item deletes itself after running the function.
                    if returned false, then the item doesn't delete itself from the player's inventory.
                OnCanRun : helix-defined. a variable that stores a function that is intended to be used as a conditional statement on whether or not the player should
                            be able to run the function OnRun.
                    OnCanRun = function(item)
                        item : helix-defined. the item that is currently running this function.
                        
                    if returned as true, then the player will be able to see this function of the item in the dropdown menu.
                    if returned as false, then the player won't be able to run the function of this item.
    
]]
ITEM.functions.Unsign = {
    name = "Unsign",
    icon = "icon16/cancel.png",
    OnRun = function(item)
        -- remove the current signer
        item:SetData("itemSigner", nil)

        return false
    end,
    OnCanRun = function(item)
        -- if the item is in the player's inventory AND there is a signer and that signer is the current player with this item, then you can unsign this
        if item:IsInPlayerInventory() and item:GetData("itemSigner", nil) == item.player:GetCharacter():GetID() then
            return true
        end

        return false
    end
}
