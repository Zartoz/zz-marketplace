local QBCore = exports['qb-core']:GetCoreObject()
local recentBuys = {}

local function GetCharacterName(player)
    return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
end

local function loadItemsForSale(callback)
    MySQL.query('SELECT * FROM marketplace_items WHERE is_sold = 0', {}, function(results)
        callback(results)
    end)
end

RegisterServerEvent('marketplace:getItemsForSale')
AddEventHandler('marketplace:getItemsForSale', function()
    local source = source
    loadItemsForSale(function(items)
        TriggerClientEvent('marketplace:showItemsForSale', source, items)
    end)
end)

RegisterServerEvent('marketplace:sellItem')
AddEventHandler('marketplace:sellItem', function(itemName, price, description)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)

    local charName = GetCharacterName(player)

    if player.Functions.RemoveItem(itemName, 1) then
        MySQL.insert('INSERT INTO marketplace_items (seller_id, seller_name, name, price, description, is_sold) VALUES (?, ?, ?, ?, ?, 0)', {
            player.PlayerData.citizenid,
            charName,
            itemName,
            price,
            description
        })

        TriggerClientEvent('QBCore:Notify', source, 'Item listed for sale!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to list item for sale.', 'error')
    end
end)

RegisterServerEvent('marketplace:buyItem')
AddEventHandler('marketplace:buyItem', function(itemId)
    local source = source
    local buyer = QBCore.Functions.GetPlayer(source)
    local buyerName = GetCharacterName(buyer)

    MySQL.prepare('SELECT * FROM marketplace_items WHERE id = ?', {itemId}, function(item)
        if item and buyer.Functions.RemoveMoney('cash', item.price) then
            MySQL.update('UPDATE marketplace_items SET is_sold = 1 WHERE id = ?', {itemId})

            if buyer.Functions.AddItem(item.name, 1) then
                local seller = QBCore.Functions.GetPlayerByCitizenId(item.seller_id)
                if seller then
                    seller.Functions.AddMoney('cash', item.price)
                    TriggerClientEvent('QBCore:Notify', seller.PlayerData.source, 'You sold ' .. item.name .. ' for $' .. item.price, 'success')
                else

                end

                MySQL.insert('INSERT INTO recent_buys (item_name, price, buyer_name, seller_name) VALUES (?, ?, ?, ?)', {
                    item.name,
                    item.price,
                    buyerName,
                    item.seller_name
                })

                TriggerClientEvent('QBCore:Notify', source, 'Item purchased!', 'success')
            else
                TriggerClientEvent('QBCore:Notify', source, 'Failed to add item to inventory.', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Not enough money', 'error')
        end
    end)
end)

RegisterServerEvent('marketplace:getRecentBuys')
AddEventHandler('marketplace:getRecentBuys', function()
    local source = source

    MySQL.query('SELECT * FROM recent_buys ORDER BY bought_at DESC LIMIT ?', {Config.MaxRecentBuys}, function(buys)
        TriggerClientEvent('marketplace:showRecentBuys', source, buys)
    end)
end)

RegisterServerEvent('marketplace:getSellers')
AddEventHandler('marketplace:getSellers', function()
    local source = source
    MySQL.query('SELECT DISTINCT seller_id, seller_name AS name FROM marketplace_items WHERE is_sold = 0', {}, function(results)

        if #results > 0 then
            TriggerClientEvent('marketplace:showSellers', source, results)
        else
            TriggerClientEvent('QBCore:Notify', source, 'Currently there arent sellers!', 'error')
        end
    end)
end)

RegisterServerEvent('marketplace:getItemsBySeller')
AddEventHandler('marketplace:getItemsBySeller', function(sellerId)
    local source = source
    MySQL.query('SELECT * FROM marketplace_items WHERE seller_id = ? AND is_sold = 0', {sellerId}, function(results)
        TriggerClientEvent('marketplace:showItemsBySeller', source, results)
    end)
end)
