local function isStaff(src)
    local exp = exports[Config.ResourceName]
    if exp and exp.IsStaff then
        return exp:IsStaff(src)
    end
    return IsPlayerAceAllowed(src, Config.Permissions.aceGroup)
end

local function notify(src, msg)
    TriggerClientEvent('chat:addMessage', src, { args = { '^1ShieldX', msg } })
end

local function foreachPlayer(cb)
    for _, id in ipairs(GetPlayers()) do
        cb(tonumber(id))
    end
end

RegisterCommand(Config.Permissions.menuCommand, function(source)
    if source == 0 then
        print('[ShieldX] Commande disponible uniquement en jeu.')
        return
    end

    if not isStaff(source) then
        notify(source, Config.Messages.noPermission)
        return
    end

    TriggerClientEvent('shieldx:client:toggleMenu', source)
end, false)

RegisterNetEvent('shieldx:server:requestMenu', function()
    local src = source
    if not isStaff(src) then
        notify(src, Config.Messages.noPermission)
        return
    end
    TriggerClientEvent('shieldx:client:toggleMenu', src)
end)

RegisterNetEvent('shieldx:server:setWeather', function(weather)
    local src = source
    if not isStaff(src) then return end

    foreachPlayer(function(pid)
        TriggerClientEvent('shieldx:client:setWeather', pid, weather)
    end)
    TriggerEvent('shieldx:server:logStaffAction', ('Météo -> %s'):format(weather))
end)

RegisterNetEvent('shieldx:server:setTime', function(hour, minute)
    local src = source
    if not isStaff(src) then return end

    foreachPlayer(function(pid)
        TriggerClientEvent('shieldx:client:setTime', pid, hour, minute)
    end)
    TriggerEvent('shieldx:server:logStaffAction', ('Temps -> %02d:%02d'):format(hour, minute))
end)

RegisterNetEvent('shieldx:server:teleportToMarker', function()
    local src = source
    if not isStaff(src) then return end
    TriggerClientEvent('shieldx:client:teleportToMarker', src)
    TriggerEvent('shieldx:server:logStaffAction', 'Téléportation waypoint')
end)

RegisterNetEvent('shieldx:server:giveWeapon', function(target, weapon)
    local src = source
    if not isStaff(src) then return end

    target = tonumber(target)
    if not target or not GetPlayerName(target) then
        notify(src, 'ID invalide.')
        return
    end

    TriggerClientEvent('shieldx:client:giveWeapon', target, weapon)
    TriggerEvent('shieldx:server:logStaffAction', ('Give weapon %s -> %s'):format(weapon, target))
end)

RegisterNetEvent('shieldx:server:revive', function(target)
    local src = source
    if not isStaff(src) then return end

    target = tonumber(target)
    if not target or not GetPlayerName(target) then
        notify(src, 'ID invalide.')
        return
    end

    TriggerClientEvent('shieldx:client:revive', target)
    TriggerEvent('shieldx:server:logStaffAction', ('Revive -> %s'):format(target))
end)

RegisterNetEvent('shieldx:server:freezePlayer', function(target, state)
    local src = source
    if not isStaff(src) then return end

    target = tonumber(target)
    if not target or not GetPlayerName(target) then
        notify(src, 'ID invalide.')
        return
    end

    TriggerClientEvent('shieldx:client:freeze', target, state)
    TriggerEvent('shieldx:server:logStaffAction', ('Freeze %s -> %s'):format(state and 'ON' or 'OFF', target))
end)

RegisterNetEvent('shieldx:server:spawnVehicle', function(model)
    local src = source
    if not isStaff(src) then return end

    TriggerClientEvent('shieldx:client:spawnVehicle', src, model)
    TriggerEvent('shieldx:server:logStaffAction', ('Spawn véhicule -> %s'):format(model))
end)
