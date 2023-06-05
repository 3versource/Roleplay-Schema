ITEM.name = "writables base"
ITEM.description = "some writable surface"
ITEM.model = "models/Gibs/HGIBS.mdl"
ITEM.category = "Writables"
ITEM.width = 1
ITEM.height = 1
ITEM.windowHeight = 600
ITEM.windowWidth = 600
ITEM.pages = 1

function ITEM:PopulateTooltip(tooltip)
    if self:GetData("itemSigner") then
        local panel = tooltip:AddRowAfter("name", "portions")
        panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
        panel:SetText("This writable item has been signed; its contents can't be edited.")
        panel:SizeToContents()
    end
end	


ITEM.functions.Read = {
    name = "Read",
    icon = "icon16/zoom.png",
    OnRun = function(item)
        local canEdit = true

        -- if there's a signer to this item or the item is on the ground, then it can't be edited
        if item:GetData("itemSigner", false) or item.player ~= item:GetOwner() then
            canEdit = false
        end

        netstream.Start(item.player, "readingWritableItem", 
                        item:GetID(), item.windowHeight, 
                        item.windowWidth, canEdit, 
                        item:GetData("previousPages", {}), 
                        item.pages) 
        
        item.player:GetCharacter():SetData("canRead", false)
        return false
    end,
    OnCanRun = function(item)
        -- players can read this whenever they want as long as they aren't reading something else (editing priviledges vary, however)
        return item.player:GetCharacter():GetData("canRead", true)
    end
}

ITEM.functions.Sign = {
    name = "Sign",
    icon = "icon16/accept.png",
    OnRun = function(item)
        item:SetData("itemSigner", item.player:GetCharacter():GetID())
        return false
    end,
    OnCanRun = function(item)
        -- if the player can't read or the item isn't in the player's inventory, then don't sign
        if not(item.player:GetCharacter():GetData("canRead", true)) or item.player ~= item:GetOwner() then
            return false
        -- if there is no signer, then you can sign this
        elseif item:GetData("itemSigner", nil) == nil then
            return true
        end
        return false
    end
}

ITEM.functions.Unsign = {
    name = "Unsign",
    icon = "icon16/cancel.png",
    OnRun = function(item)
        -- remove the current signer
        item:SetData("itemSigner", nil)

        return false
    end,
    OnCanRun = function(item)
        -- if the player can't read or the item isn't in the player's inventory, return false
        if not(item.player:GetCharacter():GetData("canRead", true)) or item.player ~= item:GetOwner() then
            return false
        -- if there is a signer and that signer is the current player with this item, then you can unsign this
        elseif item:GetData("itemSigner", nil) == item.player:GetCharacter():GetID() then
            return true
        end
        return false
    end
}

-- netstream allows us to communicate from server to the client or client to server, very useful
netstream.Hook("readingWritableItem", function(item, height, width, isEditable, pastText, pages)
    -- serverside variables, such as item.var or item:getdata() won't work here since this is clientside ONLY!

    local frame = vgui.Create("DFrame") -- create the derma frame
    frame:SetTitle("") -- the name of the derma frame that pops up onto yours screen
    frame:SetSize( ScrW() * (width/1920), ScrH() * (height/1080) ) -- width, height
    frame:Center() -- place the frame in the center of the user's screen
    frame:SetDrawOnTop(true)

    local scrollBar = vgui.Create("DScrollPanel", frame)
    scrollBar:Dock(FILL)

    for i = 1, pages do
        local textBox = scrollBar:Add("DTextEntry")
        -- print("received text '"..tostring(pastText[i]).."' at index "..tostring(i))
        textBox:Dock(TOP)
        textBox:DockMargin(0,0,0,5)
        -- width position, height position
        textBox:SetSize(width, height)
        textBox:SetMultiline(true)
        textBox:SetEditable(isEditable)

        if pastText[i] then
            textBox:SetText(pastText[i])
        else
            textBox:SetText("")
        end

        textBox:SetPlaceholderText("Page "..i)
    end

    frame.OnClose = function()
        -- print("onclosed initiated")
        if isEditable then
            -- In index 1 of scrollBar:GetChildren(), the panel itself is present.
            -- In index 2 of scrollbar:GetChildren(), the scroll bar itself is present.

            -- The panel in index 1 has children of its own, which is where the text boxes are stored.
            --     This means that doing,
            --         scrollBar:GetChildren[1]:GetChildren()
            --     will return a text entry box.
            
            local panelChildren = scrollBar:GetChildren()[1]:GetChildren()
            local pagesWithText = {}

            for i = 1, pages do
                local text = panelChildren[i]:GetValue()
                -- print("current text is "..tostring(panelChildren[i]:GetValue()))
                -- print("iteration is "..i)

                -- searches for a number after the word "Page"
                local textPage = tonumber(string.match(panelChildren[i]:GetPlaceholderText(), "Page%s*(%S+)"))
                -- print("current text page is "..tostring(textPage))

                pagesWithText[textPage] = text
            end

            netstream.Start("addWritableEdit", item, pagesWithText)

        end

        netstream.Start("setPlayerNotReading")

        frame:Remove()
    end

    frame:SetVisible(true)
    frame:MakePopup() -- the derma frame shows up on your screen
    frame:DoModal(true) -- forces to only have focus on this window. players can't interact with the helix menu or the gmod menu. quite powerful and dangerous, no?
end)    

-- serverside
netstream.Hook("addWritableEdit", function(client, itemID, list)
    local item = ix.item.instances[itemID]

    -- save the previous pages
    item:SetData("previousPages", list)

    -- print("edits saved")
end)

-- serverside
netstream.Hook("setPlayerNotReading", function(client)
    -- state that the character is now able to read other things
    client:GetCharacter():SetData("canRead", true)

    -- print("player can read")
end)