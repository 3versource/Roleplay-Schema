

-- this is initiated from the client and communicates with the server
netstream.Hook("addWritableEdit", function(client, itemID, list)
    local item = ix.item.instances[itemID]

    -- if the item exists
    if item then
        -- save the previous pages
        item:SetData("previousPages", list)
    end

    -- print("edits saved")
end)