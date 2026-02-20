local lastTriggers = {}
local lastExplosions = {}
local resourceStarting = true

local function nowMs()
    return GetGameTimer()
end

local function getPlayerIdentifiersMap(src)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        local key = id:match('^(%w+):')
        if key then
            ids[key] = id
        end
    end
    return ids
end

local function isStaff(src)
    if IsPlayerAceAllowed(src, Config.Permissions.aceGroup) then
        return true
    end

    local playerIds = getPlayerIdentifiersMap(src)
    for _, expected in ipairs(Config.StaffIdentifiers) do
        for _, pid in pairs(playerIds) do
            if pid == expected then
                return true
            end
        end
    end
    return false
end

exports('IsStaff', isStaff)

local function sendLog(webhook, title, message, color)
    if webhook == nil or webhook == '' then
        return
    end

    PerformHttpRequest(webhook, function() end, 'POST', json.encode({
        username = 'ShieldX',
        embeds = {
            {
                title = title,
                description = message,
                color = color or 16711680,
                footer = { text = os.date('%Y-%m-%d %H:%M:%S') }
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

local function punish(src, reason)
    local msg = ('%s (%s)'):format(GetPlayerName(src) or 'unknown', reason)
    print(('[ShieldX] Punish -> %s'):format(msg))
    sendLog(Config.Webhooks.anticheat, 'Détection anticheat', msg)
    DropPlayer(src, Config.Messages.playerDropped)
end

RegisterNetEvent('shieldx:server:validateAction', function(action)
    local src = source
    if isStaff(src) then
        return
    end

    local timestamp = nowMs()
    lastTriggers[src] = lastTriggers[src] or {}
    table.insert(lastTriggers[src], timestamp)

    local keepAfter = timestamp - Config.Thresholds.triggerWindowMs
    local filtered = {}
    for _, t in ipairs(lastTriggers[src]) do
        if t >= keepAfter then
            filtered[#filtered + 1] = t
        end
    end
    lastTriggers[src] = filtered

    if Config.Protection.antiTriggerSpam and #filtered > Config.Thresholds.maxTriggerPerWindow then
        punish(src, ('trigger spam (%s)'):format(action or 'unknown'))
    end
end)

AddEventHandler('explosionEvent', function(sender, ev)
    if not Config.Protection.antiExplosionSpam then
        return
    end

    if isStaff(sender) then
        return
    end

    if Config.Blacklists.explosionTypes[ev.explosionType] then
        CancelEvent()
        punish(sender, ('explosion blacklist (%s)'):format(ev.explosionType))
        return
    end

    local timestamp = nowMs()
    lastExplosions[sender] = lastExplosions[sender] or {}
    table.insert(lastExplosions[sender], timestamp)

    local keepAfter = timestamp - Config.Thresholds.explosionWindowMs
    local filtered = {}
    for _, t in ipairs(lastExplosions[sender]) do
        if t >= keepAfter then
            filtered[#filtered + 1] = t
        end
    end
    lastExplosions[sender] = filtered

    if #filtered > Config.Thresholds.maxExplosionsPerWindow then
        CancelEvent()
        punish(sender, 'explosion spam')
    end
end)

AddEventHandler('entityCreating', function(entity)
    if not DoesEntityExist(entity) then
        return
    end

    local owner = NetworkGetEntityOwner(entity)
    if owner == 0 or isStaff(owner) then
        return
    end

    local entityType = GetEntityType(entity)
    local model = GetEntityModel(entity)

    if entityType == 2 and Config.Protection.antiBlacklistedVehicles then
        for _, blacklisted in ipairs(Config.Blacklists.vehicles) do
            if model == blacklisted then
                CancelEvent()
                punish(owner, ('spawn véhicule blacklist (%s)'):format(model))
                return
            end
        end
    elseif entityType == 1 and Config.Protection.antiBlacklistedPeds then
        for _, blacklisted in ipairs(Config.Blacklists.peds) do
            if model == blacklisted then
                CancelEvent()
                punish(owner, ('spawn ped blacklist (%s)'):format(model))
                return
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(stoppedResource)
    if not Config.Protection.antiResourceStop then
        return
    end

    if stoppedResource == Config.ResourceName then
        print('[ShieldX] Resource stopped, restart recommended immediately.')
    end
end)

RegisterNetEvent('shieldx:server:reportViolation', function(reason)
    local src = source
    if isStaff(src) then
        return
    end
    punish(src, reason or 'raison inconnue')
end)

RegisterNetEvent('shieldx:server:logStaffAction', function(action)
    local src = source
    if not isStaff(src) then
        punish(src, 'staff action spoof')
        return
    end
    local playerName = GetPlayerName(src) or ('id %s'):format(src)
    sendLog(Config.Webhooks.staff, 'Action staff', ('%s -> %s'):format(playerName, action), 3447003)
end)

CreateThread(function()
    Wait(3000)
    resourceStarting = false
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastTriggers[src] = nil
    lastExplosions[src] = nil
end)
