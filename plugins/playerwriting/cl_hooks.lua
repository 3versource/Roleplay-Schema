
-- initiated from server and communicates with a client
netstream.Hook("readingWritableItem", function(item, height, width, isEditable, pastText, pages)
    -- serverside variables, such as item.var or item:getdata() won't work here since this is clientside ONLY!

    local frame = vgui.Create("DFrame") -- create the derma frame
    frame:SetTitle("") -- the name of the derma frame that pops up onto yours scree
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
            --[[
                In index 1 of scrollBar:GetChildren(), the panel itself is present.
                In index 2 of scrollbar:GetChildren(), the scroll bar itself is present.
                The panel in index 1 has children of its own, which is where the text boxes are stored.

                This means that doing,
                    scrollBar:GetChildren[1]:GetChildren()
                will return a text entry box object.
            ]]
            
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

        frame:Remove()
    end

    frame:SetVisible(true)
    frame:MakePopup() -- the derma frame shows up on your screen
    frame:DoModal(true) -- forces to only have focus on this window. players can't interact with the helix menu or the gmod menu. quite powerful and dangerous, no?
end)    

