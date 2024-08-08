local QBCore = exports['qb-core']:GetCoreObject()

local itemsForSale = {}
local recentBuys = {}

local function loadItemsFromDatabase()
    local result = MySQL.query.await('SELECT * FROM marketplace_items')
    if result then
        for _, item in ipairs(result) do
            itemsForSale[item.id] = {
                name = item.name,
                label = item.label, 
                price = item.price,
                seller = item.seller,
                description = item.description,
                sellerId = item.seller_id
            }
        end
    end
end

local function loadRecentBuysFromDatabase()
    local result = MySQL.query.await('SELECT * FROM marketplace_recent_buys ORDER BY timestamp DESC LIMIT 10')
    if result then
        for _, item in ipairs(result) do
            table.insert(recentBuys, {
                label = item.item_label,
                price = item.price,
                buyer = item.buyer,
                seller = item.seller
            })
        end
    end
end

local function saveRecentBuyToDatabase(item)
    MySQL.insert('INSERT INTO marketplace_recent_buys (item_label, price, buyer, seller) VALUES (?, ?, ?, ?)', 
                 { item.label, item.price, item.buyer, item.seller })
end

local function saveItemToDatabase(item)
    MySQL.insert('INSERT INTO marketplace_items (name, label, price, seller, description, seller_id) VALUES (?, ?, ?, ?, ?, ?)', 
                 { item.name, item.label, item.price, item.seller, item.description, item.sellerId })
end

local function removeItemFromDatabase(itemId)
    MySQL.execute('DELETE FROM marketplace_items WHERE id = ?', { itemId })
end

loadItemsFromDatabase()
loadRecentBuysFromDatabase()

RegisterNetEvent('zz-marketplace:buyItem')
AddEventHandler('zz-marketplace:buyItem', function(itemId)
    local src = source
    local buyer = QBCore.Functions.GetPlayer(src)
    local item = itemsForSale[itemId]

    if not item then
        TriggerClientEvent('QBCore:Notify', src, 'Item not found', 'error')
        return
    end

    if buyer.Functions.RemoveMoney('cash', item.price) then
        buyer.Functions.AddItem(item.name, 1)
        local seller = QBCore.Functions.GetPlayerByCitizenId(item.sellerId)
        if seller then
            seller.Functions.AddMoney('cash', item.price)
        end

        local recentBuy = {
            label = item.label,
            price = item.price,
            buyer = buyer.PlayerData.charinfo.firstname .. " " .. buyer.PlayerData.charinfo.lastname,
            seller = item.seller
        }

        table.insert(recentBuys, 1, recentBuy)
        saveRecentBuyToDatabase(recentBuy) 

        if #recentBuys > 10 then
            table.remove(recentBuys, 11)
        end

        removeItemFromDatabase(itemId)
        itemsForSale[itemId] = nil
        TriggerClientEvent('QBCore:Notify', src, 'Successfully purchased ' .. item.label .. ' from ' .. item.seller, 'success')
        TriggerClientEvent('zz-marketplace:updateItemsForSale', -1, itemsForSale, recentBuys)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
    end
end)

RegisterNetEvent('zz-marketplace:requestItemsForSale')
AddEventHandler('zz-marketplace:requestItemsForSale', function()
    local src = source
    TriggerClientEvent('zz-marketplace:updateItemsForSale', src, itemsForSale, recentBuys)
end)

RegisterNetEvent('zz-marketplace:sellItem')
AddEventHandler('zz-marketplace:sellItem', function(itemName, itemPrice, itemDescription)
    local src = source
    local seller = QBCore.Functions.GetPlayer(src)
    local sellerName = seller.PlayerData.charinfo.firstname .. " " .. seller.PlayerData.charinfo.lastname
    local sellerId = seller.PlayerData.citizenid
    local itemLabel = QBCore.Shared.Items[itemName].label 

    -- Check if the price is valid
    if itemPrice <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid price. Please set a price greater than zero.', 'error')
        return
    end

    if seller.Functions.RemoveItem(itemName, 1) then
        local item = { name = itemName, label = itemLabel, price = itemPrice, seller = sellerName, description = itemDescription, sellerId = sellerId }
        saveItemToDatabase(item)
        itemsForSale[#itemsForSale + 1] = item

        TriggerClientEvent('QBCore:Notify', src, 'Item listed for sale!', 'success')
        TriggerClientEvent('zz-marketplace:updateItemsForSale', -1, itemsForSale, recentBuys)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have this item', 'error')
    end
end)


QBCore.Functions.CreateCallback('zz-marketplace:getInventory', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        cb(Player.PlayerData.items)
    else
        cb({})
    end
end)
