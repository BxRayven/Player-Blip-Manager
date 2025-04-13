local showBlips = false
local playerBlips = {}

RegisterNetEvent('blips:toggleBlips')
AddEventHandler('blips:toggleBlips', function(state)
    showBlips = state

    if not state then
        for _, blip in pairs(playerBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        playerBlips = {}
    end

    lib.notify({
        title = 'Player Blips',
        description = showBlips and 'Blips enabled' or 'Blips disabled',
        type = showBlips and 'success' or 'info'
    })
end)

RegisterNetEvent('blips:removeBlip')
AddEventHandler('blips:removeBlip', function(id)
    if playerBlips[id] then
        RemoveBlip(playerBlips[id])
        playerBlips[id] = nil
    end
end)

RegisterCommand('playerblips', function()
    TriggerServerEvent('blips:requestToggle')
end, false)

Citizen.CreateThread(function()
    TriggerServerEvent('blips:requestToggle')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if not showBlips then goto continue end

        local players = GetActivePlayers()

        for _, i in ipairs(players) do
            local serverId = GetPlayerServerId(i)

            if serverId ~= nil and serverId ~= GetPlayerServerId(PlayerId()) then
                local ped = GetPlayerPed(i)

                if DoesEntityExist(ped) and NetworkIsPlayerActive(i) and IsPedAPlayer(ped) then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    local blip = playerBlips[serverId]

                    if DoesBlipExist(blip) then
                        RemoveBlip(blip)
                        playerBlips[serverId] = nil
                    end

                    if vehicle ~= 0 then
                        blip = AddBlipForEntity(vehicle)
                        SetBlipCategory(blip, 7)
                        SetBlipScale(blip, 0.85)
                        ShowHeadingIndicatorOnBlip(blip, false)
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(vehicle)))
                        SetBlipAsShortRange(blip, false)

                        -- Vehicle blip sprite logic
                        local class = GetVehicleClass(vehicle)
                        local sprite

                        if class == 8 then -- Motorcycles
                            sprite = 226
                        elseif class == 13 then -- Bicycles
                            sprite = 348
                        elseif class == 14 then -- Boats
                            sprite = 427
                        elseif class == 15 then -- Helicopters
                            sprite = 422
                        elseif class == 16 then -- Planes
                            sprite = 307
                        elseif class == 18 then -- Emergency
                            sprite = 227
                        elseif class == 19 then -- Military
                            sprite = 421
                        elseif class == 20 then -- Commercial
                            sprite = 477
                        else -- All normal road vehicles
                            sprite = 227
                        end

                        SetBlipSprite(blip, sprite)

                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(GetPlayerName(i) .. " [ID: " .. serverId .. "]")
                        EndTextCommandSetBlipName(blip)

                        playerBlips[serverId] = blip
                    else
                        blip = AddBlipForEntity(ped)
                        SetBlipCategory(blip, 7)
                        SetBlipScale(blip, 0.85)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(ped)))
                        SetBlipAsShortRange(blip, false)

                        SetBlipSprite(blip, 271)

                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString(GetPlayerName(i) .. " [ID: " .. serverId .. "]")
                        EndTextCommandSetBlipName(blip)

                        playerBlips[serverId] = blip
                    end
                else
                    if playerBlips[serverId] then
                        RemoveBlip(playerBlips[serverId])
                        playerBlips[serverId] = nil
                    end
                end
            end
        end

        ::continue::
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, blip in pairs(playerBlips) do
            RemoveBlip(blip)
        end
    end
end)
