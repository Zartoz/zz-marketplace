local QBCore = exports['qb-core']:GetCoreObject()

local itemsForSale = {}
local recentBuys = {}

local function openMainMenu()
    if Config.MenuSystem == 'qb-menu' then
        local menu = {
            {
                header = 'Public Marketplace',
                isMenuHeader = true
            },
            {
                header = 'Items for Sale',
                txt = 'Browse available items',
                params = {
                    event = 'zz-marketplace:showItemsForSale'
                }
            },
            {
                header = 'Recent Buys',
                txt = 'See what people have bought recently',
                params = {
                    event = 'zz-marketplace:showRecentBuys'
                }
            },
            {
                header = 'Sell an Item',
                txt = 'Sell an item from your inventory',
                params = {
                    event = 'zz-marketplace:sellItem'
                }
            }
        }
        exports['qb-menu']:openMenu(menu)
    elseif Config.MenuSystem == 'ox_lib' then
        local menu = {
            {
                title = 'Marketplace',
                disabled = true
            },
            {
                title = 'Items for Sale',
                description = 'Browse available items',
                event = 'zz-marketplace:showItemsForSale'
            },
            {
                title = 'Recent Buys',
                description = 'See what people have bought recently',
                event = 'zz-marketplace:showRecentBuys'
            },
            {
                title = 'Sell an Item',
                description = 'Sell an item from your inventory',
                event = 'zz-marketplace:sellItem'
            }
        }
        lib.registerContext({ id = 'marketplace_main_menu', title = 'Marketplace', options = menu })
        lib.showContext('marketplace_main_menu')
    end
end

RegisterNetEvent('zz-marketplace:showItemsForSale')
AddEventHandler('zz-marketplace:showItemsForSale', function()
    local menu = {
        {
            title = 'Items for Sale',
            disabled = true
        }
    }

    for id, item in pairs(itemsForSale) do
        table.insert(menu, {
            title = item.label,
            description = 'Price: $' .. item.price .. ' | Seller: ' .. item.seller .. ' | Description: ' .. item.description,
            event = 'zz-marketplace:buyItem',
            args = id
        })
    end

    if Config.MenuSystem == 'qb-menu' then
        exports['qb-menu']:openMenu(menu)
    elseif Config.MenuSystem == 'ox_lib' then
        lib.registerContext({ id = 'marketplace_items_for_sale', title = 'Items for Sale', options = menu })
        lib.showContext('marketplace_items_for_sale')
    end
end)

RegisterNetEvent('zz-marketplace:showRecentBuys')
AddEventHandler('zz-marketplace:showRecentBuys', function()
    local menu = {
        {
            title = 'Recent Buys',
            disabled = true
        }
    }

    for _, item in ipairs(recentBuys) do
        table.insert(menu, {
            title = item.label,
            description = 'Bought by: ' .. item.buyer .. ' | Price: $' .. item.price .. ' | Seller: ' .. item.seller,
            event = '',
            args = nil
        })
    end

    if Config.MenuSystem == 'qb-menu' then
        exports['qb-menu']:openMenu(menu)
    elseif Config.MenuSystem == 'ox_lib' then
        lib.registerContext({ id = 'marketplace_recent_buys', title = 'Recent Buys', options = menu })
        lib.showContext('marketplace_recent_buys')
    end
end)

RegisterNetEvent('zz-marketplace:buyItem')
AddEventHandler('zz-marketplace:buyItem', function(itemId)
    TriggerServerEvent('zz-marketplace:buyItem', itemId)
end)

RegisterNetEvent('zz-marketplace:sellItem')
AddEventHandler('zz-marketplace:sellItem', function()
    QBCore.Functions.TriggerCallback('zz-marketplace:getInventory', function(inventory)
        local menu = {}

        for _, item in ipairs(inventory) do
            if item.amount > 0 then
                table.insert(menu, {
                    title = item.label,
                    description = 'Amount: ' .. item.amount,
                    event = 'zz-marketplace:confirmSellItem',
                    args = {name = item.name, label = item.label}
                })
            end
        end

        table.insert(menu, { title = 'Close', event = '' })

        if Config.MenuSystem == 'qb-menu' then
            exports['qb-menu']:openMenu(menu)
        elseif Config.MenuSystem == 'ox_lib' then
            lib.registerContext({ id = 'marketplace_sell_item', title = 'Sell Item', options = menu })
            lib.showContext('marketplace_sell_item')
        end
    end)
end)

RegisterNetEvent('zz-marketplace:confirmSellItem')
AddEventHandler('zz-marketplace:confirmSellItem', function(data)
    local input = lib.inputDialog('Set Item Price and Description', {
        { type = 'number', label = 'Price', default = 0, required = true },
        { type = 'input', label = 'Description', default = '', required = true }
    })

    if input and input[1] and input[2] then
        local price = tonumber(input[1])
        local description = tostring(input[2])
        TriggerServerEvent('zz-marketplace:sellItem', data.name, price, description)
    else
        QBCore.Functions.Notify('You must set a price and description', 'error')
    end
end)

local function spawnMarketplacePed()
    local model = GetHashKey(Config.PedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    local ped = CreatePed(4, model, Config.PedPosition.x, Config.PedPosition.y, Config.PedPosition.z, Config.PedPosition.h, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_AA_SMOKET", 0, true)

    if Config.TargetSystem == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    event = "zz-marketplace:openMenu",
                    icon = "fas fa-shopping-cart",
                    label = "Open Marketplace",
                    action = function(entity)
                        TriggerEvent('zz-marketplace:openMenu')
                    end
                }
            },
            distance = 2.5
        })
    elseif Config.TargetSystem == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = "marketplace_ped",
                icon = "fas fa-shopping-cart",
                label = "Open Marketplace",
                onSelect = function()
                    TriggerEvent('zz-marketplace:openMenu')
                end
            }
        })
    end
end

local function addBlip()
    local blip = AddBlipForCoord(Config.PedPosition.x, Config.PedPosition.y, Config.PedPosition.z)
    SetBlipSprite(blip, 521) -- Example blip sprite, change as needed
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 26) -- Example blip color, change as needed
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Public Marketplace") -- Blip name
    EndTextCommandSetBlipName(blip)
end

CreateThread(function()
    spawnMarketplacePed()
    addBlip()
end)

RegisterNetEvent('zz-marketplace:openMenu')
AddEventHandler('zz-marketplace:openMenu', function()
    TriggerServerEvent('zz-marketplace:requestItemsForSale')
end)

RegisterNetEvent('zz-marketplace:updateItemsForSale')
AddEventHandler('zz-marketplace:updateItemsForSale', function(receivedItems, recent)
    itemsForSale = receivedItems or {}
    recentBuys = recent or {}
    openMainMenu()
end)
