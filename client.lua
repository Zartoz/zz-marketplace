local QBCore = exports['qb-core']:GetCoreObject()

local function OpenMarketplaceMenu()
    local options = {
        {
            title = 'Buy an item',
            description = 'Browse items available for purchase',
            icon = 'shopping-cart',
            onSelect = function()
                TriggerServerEvent('marketplace:getItemsForSale')
            end
        },
        {
            title = 'Sell an item',
            description = 'Select an item from your inventory to sell',
            icon = 'money-bill',
            onSelect = function()
                TriggerEvent('marketplace:sellItemMenu')
            end
        },
        {
            title = 'Recent buys',
            description = 'View the latest purchased items',
            icon = 'receipt',
            onSelect = function()
                TriggerServerEvent('marketplace:getRecentBuys')
            end
        },
        {
            title = 'Sellers',
            description = 'Browse sellers with items for sale',
            icon = 'user-tag',
            onSelect = function()
                TriggerServerEvent('marketplace:getSellers')
            end
        }
    }

    lib.registerContext({
        id = 'marketplace_menu',
        title = 'Marketplace',
        options = options
    })

    lib.showContext('marketplace_menu')
end

local function CreateMarketplacePed()
    local pedModel = Config.PedModel 
    RequestModel(pedModel)
    
    while not HasModelLoaded(pedModel) do
        Wait(0)
    end

    local pedCoords = Config.PedCoords

    local ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    FreezeEntityPosition(ped, true)

    if Config.TargetSystem == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'marketplace_ped',
                label = 'Marketplace',
                icon = 'fas fa-shopping-cart',
                onSelect = function()
                    OpenMarketplaceMenu()
                end,
                distance = 2.0
            }
        })
    elseif Config.TargetSystem == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    label = 'Marketplace',
                    icon = 'fas fa-shopping-cart',
                    action = function()
                        OpenMarketplaceMenu()
                    end
                }
            },
            distance = 2.0
        })
    end
end

Citizen.CreateThread(function()
    CreateMarketplacePed()
end)

local function IsItemBlacklisted(itemName)
    for _, blacklistedItem in ipairs(Config.BlacklistedItems) do
        if blacklistedItem:lower() == itemName:lower() then
            return true
        end
    end
    return false
end

RegisterNetEvent('marketplace:sellItemMenu', function()
    local playerItems = QBCore.Functions.GetPlayerData().items
    local options = {}

    for _, item in pairs(playerItems) do
        if item ~= nil and item.amount > 0 then
            if IsItemBlacklisted(item.name) then
                TriggerEvent('QBCore:Notify', "Some items cannot be put on sale ", "error")
            else
                table.insert(options, {
                    title = item.label,
                    onSelect = function()
                        TriggerEvent('marketplace:sellItemDetails', item.name)
                    end
                })
            end
        end
    end

    if #options > 0 then
        lib.registerContext({
            id = 'marketplace_sell_item_menu',
            title = 'Select Item to Sell',
            options = options
        })

        lib.showContext('marketplace_sell_item_menu')
    else
        TriggerEvent('QBCore:Notify', "No items available for sale", "error")
    end
end)

RegisterNetEvent('marketplace:sellItemDetails', function(itemName)
    local input = lib.inputDialog('Sell an item', {
        {type = 'number', label = 'Price', required = true, min = 1},
        {type = 'textarea', label = 'Description', required = true},
    })

    if input then
        TriggerServerEvent('marketplace:sellItem', itemName, tonumber(input[1]), input[2])
    end
end)

RegisterNetEvent('marketplace:showItemsForSale', function(items)
    local options = {}

    for i, item in ipairs(items) do
        table.insert(options, {
            title = item.name .. ' - $' .. item.price,
            description = 'Seller: ' .. item.seller_name .. '\n Description: ' .. item.description,
            icon = 'tag',
            onSelect = function()
                TriggerServerEvent('marketplace:buyItem', item.id)
            end
        })
    end

    lib.registerContext({
        id = 'marketplace_buy_menu',
        title = 'Items for Sale',
        options = options
    })

    lib.showContext('marketplace_buy_menu')
end)

RegisterNetEvent('marketplace:showRecentBuys', function(buys)
    local options = {}

    for i, buy in ipairs(buys) do
        table.insert(options, {
            title = buy.item_name .. ' - $' .. buy.price,
            description = 'Bought by: ' .. buy.buyer_name .. '\nSold by: ' .. buy.seller_name
        })
    end

    lib.registerContext({
        id = 'marketplace_recent_buys_menu',
        title = 'Recent Buys',
        options = options
    })

    lib.showContext('marketplace_recent_buys_menu')
end)

local function addBlip()
    local blip = AddBlipForCoord(Config.MarketplaceCoords)
    SetBlipSprite(blip, 521) 
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 26) 
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Public Marketplace") 
    EndTextCommandSetBlipName(blip)
end

CreateThread(function()
    addBlip()
end)

RegisterNetEvent('marketplace:showSellers', function(sellers)
    local options = {}

    for i, seller in ipairs(sellers) do
        table.insert(options, {
            title = seller.name,
            description = 'View items from this seller',
            icon = 'user',
            onSelect = function()
                TriggerServerEvent('marketplace:getItemsBySeller', seller.seller_id)
            end
        })
    end

    lib.registerContext({
        id = 'marketplace_sellers_menu',
        title = 'Sellers with Items for Sale',
        options = options
    })

    lib.showContext('marketplace_sellers_menu')
end)

RegisterNetEvent('marketplace:showItemsBySeller', function(items)
    local options = {}

    for i, item in ipairs(items) do
        table.insert(options, {
            title = item.name .. ' - $' .. item.price,
            description = 'Seller: ' .. item.seller_name .. '\n' .. item.description,
            icon = 'tag',
            onSelect = function()
                TriggerServerEvent('marketplace:buyItem', item.id)
            end
        })
    end

    lib.registerContext({
        id = 'marketplace_seller_items_menu',
        title = 'Items for Sale by Seller',
        options = options
    })

    lib.showContext('marketplace_seller_items_menu')
end)
