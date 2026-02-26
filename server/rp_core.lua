local Players = {}
local Dirty = {}

local function now()
    return os.time()
end

local function decodeJson(str, fallback)
    if not str or str == '' then return fallback end
    local ok, data = pcall(json.decode, str)
    if not ok or type(data) ~= 'table' then return fallback end
    return data
end

local function encodeJson(data)
    local ok, text = pcall(json.encode, data)
    return ok and text or '{}'
end

local function getIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find('license:') == 1 then
            return id
        end
    end
    return GetPlayerIdentifierByType(src, 'license') or ('temp:%s'):format(src)
end

local function makeStarterInventory()
    local inv = {}
    for _, entry in ipairs(RPConfig.StarterItems) do
        inv[entry.name] = (inv[entry.name] or 0) + entry.count
    end
    return inv
end

local function getJobData(jobName, grade)
    local job = RPConfig.Jobs[jobName] or RPConfig.Jobs.unemployed
    local jobGrade = job.grades[grade] or job.grades[0]
    return job, jobGrade
end

local function notify(src, msg)
    TriggerClientEvent('chat:addMessage', src, { args = { '^2PulseLite', msg } })
end

local function markDirty(src)
    Dirty[src] = true
end

local function setPlayerState(src)
    local data = Players[src]
    if not data then return end

    if RPConfig.UseStateBags then
        local state = Player(src).state
        state:set('rp:money', data.money, true)
        state:set('rp:bank', data.bank, true)
        state:set('rp:job', data.job.name, true)
        state:set('rp:grade', data.job.grade, true)
    end

    TriggerClientEvent('pulselite:client:syncPlayer', src, {
        money = data.money,
        bank = data.bank,
        hunger = data.hunger,
        thirst = data.thirst,
        stress = data.stress,
        job = data.job
    })
end

local function getWeight(inventory)
    local total = 0
    for item, count in pairs(inventory) do
        local def = RPConfig.Items[item]
        if def and count > 0 then
            total = total + (def.weight * count)
        end
    end
    return total
end

local function canCarry(inventory, itemName, count)
    local def = RPConfig.Items[itemName]
    if not def then return false, 'Objet inconnu.' end
    local newWeight = getWeight(inventory) + (def.weight * count)
    return newWeight <= RPConfig.MaxInventoryWeight, ('Inventaire plein (%s/%s).'):format(newWeight, RPConfig.MaxInventoryWeight)
end

local function addItem(src, itemName, count)
    local player = Players[src]
    if not player or count <= 0 then return false end
    local ok, reason = canCarry(player.inventory, itemName, count)
    if not ok then return false, reason end
    player.inventory[itemName] = (player.inventory[itemName] or 0) + count
    markDirty(src)
    return true
end

local function removeItem(src, itemName, count)
    local player = Players[src]
    if not player or count <= 0 then return false end
    local cur = player.inventory[itemName] or 0
    if cur < count then
        return false, 'Quantité insuffisante.'
    end
    local newValue = cur - count
    player.inventory[itemName] = newValue > 0 and newValue or nil
    markDirty(src)
    return true
end

local function savePlayer(src)
    local data = Players[src]
    if not data then return end

    Dirty[src] = nil

    local payload = {
        money = data.money,
        bank = data.bank,
        hunger = data.hunger,
        thirst = data.thirst,
        stress = data.stress,
        inventory = data.inventory,
        position = data.position,
        updatedAt = now()
    }

    SetResourceKvp(('pulselite:player:%s'):format(data.identifier), encodeJson(payload))
    SetResourceKvp(('pulselite:job:%s'):format(data.identifier), encodeJson(data.job))
end

local function loadPlayer(src)
    local identifier = getIdentifier(src)
    local raw = GetResourceKvpString(('pulselite:player:%s'):format(identifier))
    local saved = decodeJson(raw, {})

    local savedJob = decodeJson(GetResourceKvpString(('pulselite:job:%s'):format(identifier)), { name = 'unemployed', grade = 0 })
    local _, gradeData = getJobData(savedJob.name, savedJob.grade)

    local player = {
        source = src,
        identifier = identifier,
        name = GetPlayerName(src) or ('Player %s'):format(src),
        money = tonumber(saved.money) or RPConfig.StartCash,
        bank = tonumber(saved.bank) or RPConfig.StartBank,
        hunger = tonumber(saved.hunger) or 100,
        thirst = tonumber(saved.thirst) or 100,
        stress = tonumber(saved.stress) or 0,
        inventory = type(saved.inventory) == 'table' and saved.inventory or makeStarterInventory(),
        position = saved.position or {
            x = RPConfig.DefaultSpawn.x,
            y = RPConfig.DefaultSpawn.y,
            z = RPConfig.DefaultSpawn.z,
            w = RPConfig.DefaultSpawn.w
        },
        job = {
            name = savedJob.name,
            grade = savedJob.grade,
            gradeLabel = gradeData.label,
            salary = gradeData.salary
        }
    }

    Players[src] = player
    setPlayerState(src)

    return player
end

local function getPlayer(src)
    return Players[src]
end

local function changeMoney(src, account, amount, reason)
    local player = getPlayer(src)
    if not player then return false, 'Joueur introuvable.' end
    if amount == 0 then return true end

    local key = account == 'bank' and 'bank' or 'money'
    local newValue = player[key] + amount
    if newValue < 0 then
        return false, 'Fonds insuffisants.'
    end

    player[key] = newValue
    markDirty(src)
    setPlayerState(src)

    TriggerClientEvent('pulselite:client:moneyChanged', src, account, amount, reason or 'Mise à jour')
    return true
end

local function setJob(src, jobName, grade)
    local player = getPlayer(src)
    if not player then return false, 'Joueur introuvable.' end

    local job, gradeData = getJobData(jobName, grade)
    player.job = {
        name = jobName,
        grade = grade,
        gradeLabel = gradeData.label,
        salary = gradeData.salary,
        label = job.label
    }

    markDirty(src)
    setPlayerState(src)
    return true
end

AddEventHandler('playerDropped', function()
    local src = source
    if Players[src] then
        savePlayer(src)
        Players[src] = nil
        Dirty[src] = nil
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for src in pairs(Players) do
        savePlayer(src)
    end
end)

RegisterNetEvent('pulselite:server:playerLoaded', function()
    local src = source
    local player = loadPlayer(src)
    TriggerClientEvent('pulselite:client:loadComplete', src, {
        position = player.position,
        inventory = player.inventory
    })
end)

RegisterNetEvent('pulselite:server:updateNeeds', function(hunger, thirst, stress)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    player.hunger = math.max(0, math.min(100, tonumber(hunger) or player.hunger))
    player.thirst = math.max(0, math.min(100, tonumber(thirst) or player.thirst))
    player.stress = math.max(0, math.min(100, tonumber(stress) or player.stress))
    markDirty(src)
end)

RegisterNetEvent('pulselite:server:updatePosition', function(position)
    local src = source
    local player = getPlayer(src)
    if not player or type(position) ~= 'table' then return end

    player.position = {
        x = tonumber(position.x) or player.position.x,
        y = tonumber(position.y) or player.position.y,
        z = tonumber(position.z) or player.position.z,
        w = tonumber(position.w) or player.position.w
    }
    markDirty(src)
end)

RegisterNetEvent('pulselite:server:transfer', function(target, amount)
    local src = source
    local player = getPlayer(src)
    local targetId = tonumber(target)
    local transferAmount = tonumber(amount)

    if not player then return end
    if not targetId or not Players[targetId] then
        notify(src, 'Cible invalide.')
        return
    end
    if not transferAmount or transferAmount <= 0 or transferAmount > RPConfig.MaxTransfer then
        notify(src, ('Montant invalide (max %s).'):format(RPConfig.MaxTransfer))
        return
    end

    local ok, reason = changeMoney(src, 'money', -transferAmount, 'Virement sortant')
    if not ok then
        notify(src, reason)
        return
    end

    changeMoney(targetId, 'money', transferAmount, 'Virement entrant')
    notify(src, ('Vous avez envoyé $%s à %s'):format(transferAmount, GetPlayerName(targetId)))
    notify(targetId, ('Vous avez reçu $%s de %s'):format(transferAmount, GetPlayerName(src)))
end)

RegisterNetEvent('pulselite:server:useItem', function(itemName)
    local src = source
    local player = getPlayer(src)
    local def = RPConfig.Items[itemName]

    if not player or not def or not def.canUse then return end

    local ok, reason = removeItem(src, itemName, 1)
    if not ok then
        notify(src, reason)
        return
    end

    if itemName == 'water' then
        player.thirst = math.min(100, player.thirst + 30)
    elseif itemName == 'bread' then
        player.hunger = math.min(100, player.hunger + 30)
    elseif itemName == 'bandage' then
        TriggerClientEvent('pulselite:client:healSmall', src)
    elseif itemName == 'repairkit' then
        TriggerClientEvent('pulselite:client:repairVehicle', src)
    end

    markDirty(src)
    setPlayerState(src)
end)

RegisterCommand(RPConfig.Commands.stats, function(source)
    if source == 0 then
        print('[PulseLite] Commande en jeu uniquement.')
        return
    end

    local player = getPlayer(source)
    if not player then
        notify(source, 'Profil non initialisé.')
        return
    end

    notify(source, ('Cash: $%s | Bank: $%s | Job: %s (%s)'):format(
        player.money,
        player.bank,
        player.job.label or player.job.name,
        player.job.gradeLabel
    ))
end, false)

RegisterCommand(RPConfig.Commands.transfer, function(source, args)
    if source == 0 then return end
    local targetId = tonumber(args[1])
    local transferAmount = tonumber(args[2])

    if not targetId or not transferAmount then
        notify(source, ('Usage: /%s [id] [montant]'):format(RPConfig.Commands.transfer))
        return
    end

    if not Players[targetId] then
        notify(source, 'Cible invalide.')
        return
    end

    if transferAmount <= 0 or transferAmount > RPConfig.MaxTransfer then
        notify(source, ('Montant invalide (max %s).'):format(RPConfig.MaxTransfer))
        return
    end

    local ok, reason = changeMoney(source, 'money', -transferAmount, 'Virement sortant')
    if not ok then
        notify(source, reason)
        return
    end

    changeMoney(targetId, 'money', transferAmount, 'Virement entrant')
    notify(source, ('Vous avez envoyé $%s à %s'):format(transferAmount, GetPlayerName(targetId)))
    notify(targetId, ('Vous avez reçu $%s de %s'):format(transferAmount, GetPlayerName(source)))
end, false)

RegisterCommand(RPConfig.Commands.setjob, function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.Permissions.aceGroup) then
        notify(source, Config.Messages.noPermission)
        return
    end

    local target = tonumber(args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0

    if not target or not jobName then
        local usage = ('Usage: /%s [id] [job] [grade]'):format(RPConfig.Commands.setjob)
        if source == 0 then print(usage) else notify(source, usage) end
        return
    end

    local success, reason = setJob(target, jobName, grade)
    if not success then
        if source == 0 then print(reason) else notify(source, reason) end
        return
    end

    notify(target, ('Nouveau métier: %s grade %s'):format(jobName, grade))
    if source ~= 0 then
        notify(source, ('Métier défini pour %s'):format(target))
    end
end, true)

CreateThread(function()
    while true do
        Wait(RPConfig.SaveIntervalMs)
        for src in pairs(Dirty) do
            if Players[src] then
                savePlayer(src)
            else
                Dirty[src] = nil
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(RPConfig.PaycheckIntervalMs)
        for src, data in pairs(Players) do
            local salary = data.job.salary or 0
            if salary > 0 then
                changeMoney(src, 'bank', salary, 'Salaire')
                notify(src, ('Salaire reçu: $%s'):format(salary))
            end
        end
    end
end)

exports('GetPlayerProfile', function(src)
    return Players[src]
end)

exports('AddItem', addItem)
exports('RemoveItem', removeItem)
exports('AddMoney', function(src, account, amount, reason)
    return changeMoney(src, account, amount, reason)
end)
exports('SetJob', setJob)
