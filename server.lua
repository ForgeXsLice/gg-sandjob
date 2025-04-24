QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('glassjob:buyShovel', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveMoney('cash', 100) then -- How much cash need the player? change it to 'bank' if you want to use bankmoney
        exports.ox_inventory:AddItem(src, 'shovel', 1)
        TriggerClientEvent('glassjob:shovelGiven', src)
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Too little money', description = 'You need $100.', type = 'error' }) -- Change the description behind the $ if you change line 6.
    end
end)

RegisterServerEvent('glassjob:giveSand', function()
    local src = source
    local amount = Config.SandPerDig
    exports.ox_inventory:AddItem(src, 'sand', amount)
end)

RegisterServerEvent('glassjob:smeltSand', function()
    local src = source
    local required = Config.SandRequiredToSmelt
    local reward = Config.GlassPerSmelt
    local hasSand = exports.ox_inventory:Search(src, 'count', 'sand')

    if hasSand >= required then
        exports.ox_inventory:RemoveItem(src, 'sand', required)
        exports.ox_inventory:AddItem(src, 'glass', reward)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Molten!',
            description = 'You smelted '..required..' sand into '..reward..' glass.',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'No sand',
            description = 'You need at least '..required..' sand to melt.',
            type = 'error'
        })
    end
end)

lib.callback.register('glassjob:hasEnoughSand', function(source)
    local required = Config.SandRequiredToSmelt
    local hasSand = exports.ox_inventory:Search(source, 'count', 'sand')
    return hasSand >= required
end)

-- Nieuwe event voor wanneer een voertuig wordt ingeleverd
lib.callback.register('glassjob:payDeposit', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    local amount = Config.VehicleDeposit

    if Player.Functions.RemoveMoney('cash', amount) then
        return true
    else
        return false
    end
end)

RegisterServerEvent('glassjob:vehicleReturned', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = Config.VehicleDeposit

    Player.Functions.AddMoney('cash', amount)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Guarantee',
        description = 'You have received $'..amount..' back for returning your work vehicle.',
        type = 'success'
    })
end)


lib.callback.register('glassjob:hasShovel', function(source)
    return exports.ox_inventory:Search(source, 'count', 'shovel') > 0
end)

lib.callback.register('glassjob:hasSand', function(source)
    return exports.ox_inventory:Search(source, 'count', 'sand') > 0
end)