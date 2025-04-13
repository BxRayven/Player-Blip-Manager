local whitelist = {
    ['steam:11000014177461a'] = true,
    ['steam:110000142fa33da'] = true,
    ['steam:11000013370d35c'] = true, 
    ['steam:11000015a65b331'] = true,
	['steam:11000016b46e5d9'] = true
}

local toggledUsers = {}

RegisterNetEvent('blips:requestToggle')
AddEventHandler('blips:requestToggle', function()
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local allowed = false

    for _, id in ipairs(identifiers) do
        if whitelist[id] then
            allowed = true
            break
        end
    end

    if not allowed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access Denied',
            description = 'You are not authorized to use player blips.',
            type = 'error'
        })
        return
    end

    toggledUsers[src] = not toggledUsers[src]
    TriggerClientEvent('blips:toggleBlips', src, toggledUsers[src])
end)

AddEventHandler('playerDropped', function()
    local src = source
    toggledUsers[src] = nil
    TriggerClientEvent('blips:removeBlip', -1, src)
end)