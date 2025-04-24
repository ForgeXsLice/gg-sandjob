QBCore = exports['qb-core']:GetCoreObject()
local hasShovel = false
local workVehicle = nil
local checkAndReturnVehicle

function spawnWorkVehicle()
    if workVehicle ~= nil then
        if DoesEntityExist(workVehicle) then
            DeleteEntity(workVehicle)
        end
        workVehicle = nil
    end

    local model = Config.VehicleModel
    local spawnCoords = Config.VehicleSpawn
    if not spawnCoords then
        spawnCoords = GetEntityCoords(PlayerPedId())
        lib.notify({title = 'Warning', description = 'Vehicle spawn coordinates not set, use current position.', type = 'warning'})
    end

    local vehicles = GetGamePool('CVehicle')
    for _, veh in ipairs(vehicles) do
        if #(GetEntityCoords(veh) - vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z)) < 3.0 then
            lib.notify({
                title = 'Spawn Blocked',
                description = 'There is already a vehicle at the spawn location.',
                type = 'error'
            })
            return
        end
    end

    local paid = lib.callback.await('glassjob:payDeposit', false)
    if not paid then
        lib.notify({ title = 'Not enough money', description = 'You do not have enough money for the vehicle deposit.', type = 'error' })
        return
    end

    QBCore.Functions.SpawnVehicle(model, function(veh)
        if not DoesEntityExist(veh) then
            lib.notify({title = 'Wrong', description = 'Could not spawn vehicle.', type = 'error'})
            return
        end

        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        workVehicle = veh
        SetVehicleHasBeenOwnedByPlayer(veh, true)

        exports.ox_target:addLocalEntity(veh, {
            {
                label = 'Return work vehicle',
                icon = 'fa-solid fa-car',
                canInteract = function()
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - Config.VehicleReturn)
                    return distance <= 10.0
                end,
                onSelect = function()
                    returnWorkVehicle()
                end
            }
        })

        lib.notify({title = 'Vehicle', description = 'Work vehicle collected!', type = 'success'})
    end, spawnCoords, true)
end

CreateThread(function()
    RequestModel(Config.NPC.model)
    while not HasModelLoaded(Config.NPC.model) do Wait(0) end
    local npc = CreatePed(0, Config.NPC.model, Config.NPC.coords.xyz, Config.NPC.coords.w, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports.ox_target:addLocalEntity(npc, {
        {
            label = 'Talk to Marcel',
            icon = 'fa-solid fa-person-digging',
            onSelect = function()
                local hasItem = lib.callback.await('glassjob:hasShovel', false)
                hasShovel = hasItem
                showWorkerMenu()
                checkAndReturnVehicle()
            end
        }
    })
end)

checkAndReturnVehicle = function()
    if workVehicle ~= nil and DoesEntityExist(workVehicle) then
        local driver = GetPedInVehicleSeat(workVehicle, -1)
        local playerPed = PlayerPedId()
    end
end

function showWorkerMenu()
    lib.registerContext({
        id = 'glassjob_menu',
        title = 'Sand Work',
        options = {
            {
                title = 'Buy a shovel',
                description = 'A shovel will cost you €100',
                icon = 'fa-solid fa-money-bill',
                onSelect = function()
                    if hasShovel then
                        lib.notify({
                            title = 'You already have a shovel',
                            description = 'You already have a shovel in your pockets.',
                            type = 'error'
                        })
                        return
                    end

                    local alert = lib.alertDialog({
                        header = 'Confirmation',
                        content = 'Want to buy a shovel for €100?',
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('glassjob:buyShovel')
                    end
                end
            },
            {
                title = 'Rent a work vehicle',
                description = 'Renting a vehicle will cost you €500',
                icon = 'fa-solid fa-car',
                onSelect = function()
                    if not hasShovel then
                        lib.notify({
                            title = 'No shovel',
                            description = 'First you need a shovel to start working.',
                            type = 'error'
                        })
                        return
                    end

                    if workVehicle ~= nil and DoesEntityExist(workVehicle) then
                        local driver = GetPedInVehicleSeat(workVehicle, -1)
                        local playerPed = PlayerPedId()

                        if driver == playerPed then
                            lib.notify({
                                title = 'Vehicle control',
                                description = 'You already have a work vehicle. Please return this first, otherwise you will pay the deposit again.',
                                type = 'inform'
                            })
                        else
                            lib.notify({
                                title = 'Not your vehicle!',
                                description = 'You can only hand in your own work vehicle.',
                                type = 'error'
                            })
                        end
                        return
                    end

                    local alert = lib.alertDialog({
                        header = 'Rent a work vehicle',
                        content = 'Do you want to rent a work vehicle for €500?',
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        spawnWorkVehicle()
                    end
                end
            },
            {
                title = 'Return work vehicle',
                description = 'Return your current vehicle to Marcel',
                icon = 'fa-solid fa-truck-ramp-box',
                onSelect = function()
                    if workVehicle ~= nil and DoesEntityExist(workVehicle) then
                        local alert = lib.alertDialog({
                            header = 'Work Vehicle Return',
                            content = 'Do you want to return the work vehicle?',
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            returnWorkVehicle()
                        end
                    else
                        lib.notify({ title = 'No work vehicle', description = 'You have no vehicle to return.', type = 'error' })
                    end
                end
            },
        }
    })
    lib.showContext('glassjob_menu')
end

function returnWorkVehicle()
    if workVehicle ~= nil and DoesEntityExist(workVehicle) then
        DeleteEntity(workVehicle)
        workVehicle = nil
    end
    TriggerServerEvent('glassjob:vehicleReturned')
    lib.notify({ title = 'Succes', description = 'You have successfully returned the work vehicle!', type = 'success' })
end



-- Dig zones
for _, coords in pairs(Config.DigZones) do
    exports.ox_target:addSphereZone({
        coords = coords,
        radius = 30,
        debug = true,
        distance = 2.5, -- Added distance check - player must be very close
        onEnter = function()
            -- Optional: show notification when entering zone when you want to use it > unmark the lib.notify
            -- lib.notify({description = 'You can shovel sand here'})
        end,
        onExit = function()
            -- Optional: clear interaction when leaving zone when you want to use it > unmark the lib.notify
            -- lib.notify({description = 'You leave the sand zone'})
        end,
        options = {
            {
                label = 'Shovel sand',
                icon = 'fa-solid fa-bucket',
                canInteract = function(entity, distance)
                    -- Strict distance check - must be within 2.5 meters
                    return distance <= 2.5
                end,
                onSelect = function()
                    local hasItem = lib.callback.await('glassjob:hasShovel', false)
                    if not hasItem then
                        lib.notify({
                            title = 'No shovel!',
                            description = 'You need a shovel.',
                            type = 'error'
                        })
                        return
                    end

                    local ped = PlayerPedId()
                    if IsPedInAnyVehicle(ped, false) then
                        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
                        lib.notify({
                            title = 'Get out!',
                            description = 'You must get out of your vehicle before you can shovel.',
                            type = 'error'
                        })
                        return
                    end                

                    local ped = PlayerPedId()
                    TaskStartScenarioInPlace(ped, 'world_human_gardener_plant', 0, true)

                    local success = lib.progressBar({
                        duration = 7000,
                        label = 'Shoveling sand',
                        useWhileDead = false,
                        canCancel = true,
                        disable = { car = true, move = true, combat = true },
                    })

                    ClearPedTasks(ped)

                    if not success then
                        lib.notify({
                            title = 'Cancelled',
                            description = 'You have cancelled the creation.',
                            type = 'error'
                        })
                        return
                    end

                    TriggerServerEvent('glassjob:giveSand')
                end
            }
        }
    })
end

-- Smeltery - using BoxZone with proper boundary enforcement
local smelteryZone = exports.ox_target:addBoxZone({
    coords = Config.Smeltery,
    size = vec3(3.5, 5.0, 3.0),
    rotation = 135,
    debug = true,
    options = {
        {
            label = 'Melt sand into glass',
            icon = 'fa-solid fa-fire',
            distance = 2.0, -- Must be within 2 meters to interact
            canInteract = function(entity, distance)
                -- This ensures the player must be inside the zone AND close enough
                return distance <= 2.0
            end,
            onSelect = function()
                local hasEnough = lib.callback.await('glassjob:hasEnoughSand', false)
                    if not hasEnough then
                        local required = Config.SandRequiredToSmelt or 1
                        lib.notify({
                            title = 'Too little sand',
                            description = 'You need at least '..required..' sand to smelt.',
                            type = 'error'
                        })
                        return
                    end

                local ped = PlayerPedId()
                TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true)

                local success = lib.progressBar({
                    duration = 15000,
                    label = 'Sand is melting',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { car = true, move = true, combat = true },
                })

                ClearPedTasks(ped)

                if not success then
                    lib.notify({
                        title = 'Cancelled',
                        description = 'You cancelled the melting.',
                        type = 'error'
                    })
                    return
                end

                TriggerServerEvent('glassjob:smeltSand')
            end
        }
    }
})

-- For enhanced boundary checking using PolyZone (only if Config.UsePolyZone is true)
if Config.UsePolyZone then
    -- Create a variable to track if player is in smeltery zone
    local inSmelteryZone = false
    
    -- Create the PolyZone properly
    local smelteryPolyZone = PolyZone:Create({
        vector2(Config.Smeltery.x - 1.75, Config.Smeltery.y - 2.5),
        vector2(Config.Smeltery.x + 1.75, Config.Smeltery.y - 2.5),
        vector2(Config.Smeltery.x + 1.75, Config.Smeltery.y + 2.5),
        vector2(Config.Smeltery.x - 1.75, Config.Smeltery.y + 2.5)
    }, {
        name = "smelteryZone",
        minZ = Config.Smeltery.z - 1.5,
        maxZ = Config.Smeltery.z + 1.5,
        debugPoly = true
    })

    -- Listen for zone entry/exit events
    smelteryPolyZone:onPlayerInOut(function(isInside)
        inSmelteryZone = isInside
        if isInside then
            lib.notify({
                description = 'You can melt sand here',
                type = 'info'
            })
        end
    end)
end

-- Blips
CreateThread(function()

    -- Dig zone blips
    for i, coords in ipairs(Config.DigZones) do
        local digBlip = AddBlipForCoord(coords)
        SetBlipSprite(digBlip, 365)
        SetBlipScale(digBlip, 0.7)
        SetBlipColour(digBlip, 46)
        SetBlipAsShortRange(digBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Sand Zone "..i)  -- If you want to stack the blips on the mapinfo, remove the '..i'.
        EndTextCommandSetBlipName(digBlip)
    end

    -- Smeltery blip
    local smeltBlip = AddBlipForCoord(Config.Smeltery)
        SetBlipSprite(smeltBlip, 436)
        SetBlipScale(smeltBlip, 0.8)
        SetBlipColour(smeltBlip, 17)
        SetBlipAsShortRange(smeltBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Smelter")
        EndTextCommandSetBlipName(smeltBlip)
    end)