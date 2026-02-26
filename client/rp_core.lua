local hudVisible = true
local playerData = {
    money = 0,
    bank = 0,
    hunger = 100,
    thirst = 100,
    stress = 0,
    job = { name = 'unemployed', grade = 0, gradeLabel = 'Citoyen' }
}

local function drawText(x, y, scale, text)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 220)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName('[PulseLite] ' .. msg)
    EndTextCommandThefeedPostTicker(false, true)
end

local function clampNeeds()
    playerData.hunger = math.max(0, math.min(100, playerData.hunger))
    playerData.thirst = math.max(0, math.min(100, playerData.thirst))
    playerData.stress = math.max(0, math.min(100, playerData.stress))
end

RegisterNetEvent('pulselite:client:syncPlayer', function(data)
    for k, v in pairs(data) do
        playerData[k] = v
    end
    clampNeeds()
end)

RegisterNetEvent('pulselite:client:loadComplete', function(data)
    if data and data.position then
        local ped = PlayerPedId()
        SetEntityCoordsNoOffset(ped, data.position.x, data.position.y, data.position.z, false, false, false)
        SetEntityHeading(ped, data.position.w or 0.0)
    end
end)

RegisterNetEvent('pulselite:client:moneyChanged', function(account, amount, reason)
    local sign = amount >= 0 and '+' or ''
    notify(('%s $%s (%s) - %s'):format(account:upper(), sign .. amount, reason, playerData.money))
end)

RegisterNetEvent('pulselite:client:healSmall', function()
    local ped = PlayerPedId()
    local hp = GetEntityHealth(ped)
    SetEntityHealth(ped, math.min(200, hp + 35))
    notify('Bandage utilisé.')
end)

RegisterNetEvent('pulselite:client:repairVehicle', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        notify('Vous devez être dans un véhicule.')
        return
    end

    local veh = GetVehiclePedIsIn(ped, false)
    SetVehicleFixed(veh)
    SetVehicleEngineHealth(veh, 1000.0)
    notify('Véhicule réparé.')
end)

RegisterCommand('hudrp', function()
    hudVisible = not hudVisible
    notify(hudVisible and 'HUD RP affiché.' or 'HUD RP masqué.')
end)

RegisterCommand('useitem', function(_, args)
    local itemName = args[1]
    if not itemName then
        notify('Usage: /useitem [nom]')
        return
    end

    TriggerServerEvent('pulselite:server:useItem', itemName)
end)

CreateThread(function()
    Wait(1500)
    TriggerServerEvent('pulselite:server:playerLoaded')
end)

CreateThread(function()
    while true do
        Wait(1000)
        playerData.hunger = playerData.hunger - 0.03
        playerData.thirst = playerData.thirst - 0.05

        if IsPedRunning(PlayerPedId()) or IsPedSprinting(PlayerPedId()) then
            playerData.stress = playerData.stress + 0.06
        else
            playerData.stress = playerData.stress - 0.02
        end

        clampNeeds()
    end
end)

CreateThread(function()
    while true do
        Wait(15000)
        TriggerServerEvent('pulselite:server:updateNeeds', playerData.hunger, playerData.thirst, playerData.stress)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        TriggerServerEvent('pulselite:server:updatePosition', {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            w = GetEntityHeading(ped)
        })
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if hudVisible then
            DrawRect(0.135, 0.905, 0.22, 0.08, 15, 15, 15, 170)
            drawText(0.03, 0.875, 0.30, ('Cash: $%s | Bank: $%s'):format(playerData.money, playerData.bank))
            drawText(0.03, 0.895, 0.28, ('Métier: %s (%s)'):format(playerData.job.label or playerData.job.name, playerData.job.gradeLabel or playerData.job.grade))
            drawText(0.03, 0.915, 0.27, ('Faim: %d%%  Soif: %d%%  Stress: %d%%'):format(playerData.hunger, playerData.thirst, playerData.stress))
        else
            Wait(250)
        end
    end
end)
