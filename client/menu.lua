local menuOpen = false
local selectedIndex = 1
local noclipEnabled = false
local freecamEnabled = false
local freecam = nil

local menuItems = {
    { label = 'Noclip ON/OFF', action = 'noclip' },
    { label = 'Freecam ON/OFF', action = 'freecam' },
    { label = 'TP sur waypoint', action = 'tp_waypoint' },
    { label = 'Changer météo', action = 'weather' },
    { label = 'Changer heure', action = 'time' },
    { label = 'Spawn véhicule', action = 'spawn_vehicle' },
    { label = 'Give arme (sur vous)', action = 'give_weapon_self' },
    { label = 'Revive vous', action = 'revive_self' },
    { label = 'Freeze vous ON/OFF', action = 'freeze_self' }
}

local frozen = false
local weatherIndex = 1
local timeIndex = 1

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName('[ShieldX] ' .. message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function drawText(x, y, scale, text, r, g, b, a, center)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(center and true or false)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function drawMenu()
    local x, y, width, itemHeight = 0.83, 0.25, 0.30, 0.032
    DrawRect(x, y, width, 0.04, 20, 20, 20, 220)
    drawText(x - 0.14, y - 0.015, 0.35, 'ShieldX Staff Menu', 255, 255, 255, 255, false)

    for i, item in ipairs(menuItems) do
        local yy = y + (i * itemHeight)
        local selected = i == selectedIndex
        DrawRect(x, yy, width, itemHeight - 0.001, selected and 180 or 35, selected and 40 or 35, selected and 40 or 35, 210)
        drawText(x - 0.14, yy - 0.012, 0.30, item.label, 255, 255, 255, 255, false)
    end

    drawText(x - 0.14, y + ((#menuItems + 1) * itemHeight), 0.25, '↑ ↓ naviguer | ← → option | Entrée valider | Backspace quitter', 200, 200, 200, 255, false)
end

local function getCamDirection(rotation)
    local rotZ = math.rad(rotation.z)
    local rotX = math.rad(rotation.x)
    local cosX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosX, math.cos(rotZ) * cosX, math.sin(rotX))
end

local function toggleFreecam()
    freecamEnabled = not freecamEnabled
    local ped = PlayerPedId()

    if freecamEnabled then
        local coords = GetEntityCoords(ped)
        freecam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamCoord(freecam, coords.x, coords.y, coords.z + 1.0)
        SetCamRot(freecam, 0.0, 0.0, GetEntityHeading(ped), 2)
        SetCamActive(freecam, true)
        RenderScriptCams(true, true, 500, true, true)
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, false)
        notify('Freecam activée')
    else
        RenderScriptCams(false, true, 500, true, true)
        if freecam then
            DestroyCam(freecam, false)
            freecam = nil
        end
        FreezeEntityPosition(ped, false)
        SetEntityVisible(ped, true, false)
        notify('Freecam désactivée')
    end
end

local function handleFreecamMovement()
    if not freecamEnabled or not freecam then return end

    local speed = Config.AdminMenu.noclip.speed
    if IsControlPressed(0, 21) then
        speed = speed * Config.AdminMenu.noclip.fastMultiplier
    end

    local camCoord = GetCamCoord(freecam)
    local camRot = GetCamRot(freecam, 2)
    local direction = getCamDirection(camRot)
    local right = vector3(direction.y, -direction.x, 0.0)

    if IsControlPressed(0, Config.AdminMenu.noclip.forwardKey) then
        camCoord = camCoord + (direction * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.backwardKey) then
        camCoord = camCoord - (direction * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.leftKey) then
        camCoord = camCoord - (right * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.rightKey) then
        camCoord = camCoord + (right * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.upKey) then
        camCoord = camCoord + vector3(0.0, 0.0, speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.downKey) then
        camCoord = camCoord - vector3(0.0, 0.0, speed)
    end

    SetCamCoord(freecam, camCoord.x, camCoord.y, camCoord.z)

    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)
    camRot = vector3(camRot.x + rightAxisY * -8.0, 0.0, camRot.z + rightAxisX * -8.0)
    SetCamRot(freecam, camRot.x, 0.0, camRot.z, 2)
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    local ped = PlayerPedId()

    SetEntityCollision(ped, not noclipEnabled, not noclipEnabled)
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, noclipEnabled)
    SetEveryoneIgnorePlayer(PlayerId(), noclipEnabled)
    notify(noclipEnabled and 'Noclip activé' or 'Noclip désactivé')
end

local function handleNoclipMovement()
    if not noclipEnabled then return end

    local ped = PlayerPedId()
    local speed = Config.AdminMenu.noclip.speed
    if IsControlPressed(0, 21) then
        speed = speed * Config.AdminMenu.noclip.fastMultiplier
    end

    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local right = vector3(forward.y, -forward.x, 0.0)

    if IsControlPressed(0, Config.AdminMenu.noclip.forwardKey) then
        coords = coords + (forward * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.backwardKey) then
        coords = coords - (forward * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.leftKey) then
        coords = coords - (right * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.rightKey) then
        coords = coords + (right * speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.upKey) then
        coords = coords + vector3(0.0, 0.0, speed)
    end
    if IsControlPressed(0, Config.AdminMenu.noclip.downKey) then
        coords = coords - vector3(0.0, 0.0, speed)
    end

    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)
end

local function inputDialog(title, default)
    AddTextEntry('FMMC_KEY_TIP1', title)
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', default or '', '', '', '', 30)
    while UpdateOnscreenKeyboard() == 0 do Wait(0) end
    if GetOnscreenKeyboardResult() then
        return GetOnscreenKeyboardResult()
    end
    return nil
end

local function teleportToWaypoint()
    local waypoint = GetFirstBlipInfoId(8)
    if waypoint == 0 then
        notify('Aucun waypoint actif.')
        return
    end

    local coord = GetBlipInfoIdCoord(waypoint)
    SetPedCoordsKeepVehicle(PlayerPedId(), coord.x, coord.y, coord.z + 1.0)
    notify('Téléportation effectuée.')
end

local function handleAction(action)
    if action == 'noclip' then
        toggleNoclip()
    elseif action == 'freecam' then
        toggleFreecam()
    elseif action == 'tp_waypoint' then
        TriggerServerEvent('shieldx:server:teleportToMarker')
    elseif action == 'weather' then
        weatherIndex = weatherIndex + 1
        if weatherIndex > #Config.AdminMenu.weatherTypes then weatherIndex = 1 end
        local weather = Config.AdminMenu.weatherTypes[weatherIndex]
        TriggerServerEvent('shieldx:server:setWeather', weather)
        notify('Météo: ' .. weather)
    elseif action == 'time' then
        timeIndex = timeIndex + 1
        if timeIndex > #Config.AdminMenu.timePresets then timeIndex = 1 end
        local preset = Config.AdminMenu.timePresets[timeIndex]
        TriggerServerEvent('shieldx:server:setTime', preset.hour, preset.minute)
        notify('Heure: ' .. preset.label)
    elseif action == 'spawn_vehicle' then
        local model = inputDialog('Nom du modèle véhicule', 'adder')
        if model and model ~= '' then
            TriggerServerEvent('shieldx:server:spawnVehicle', model)
        end
    elseif action == 'give_weapon_self' then
        local weapon = inputDialog('Nom weapon (WEAPON_CARBINERIFLE)', 'WEAPON_CARBINERIFLE')
        if weapon and weapon ~= '' then
            TriggerServerEvent('shieldx:server:giveWeapon', GetPlayerServerId(PlayerId()), weapon)
        end
    elseif action == 'revive_self' then
        TriggerServerEvent('shieldx:server:revive', GetPlayerServerId(PlayerId()))
    elseif action == 'freeze_self' then
        frozen = not frozen
        TriggerServerEvent('shieldx:server:freezePlayer', GetPlayerServerId(PlayerId()), frozen)
    end
end

RegisterNetEvent('shieldx:client:toggleMenu', function()
    menuOpen = not menuOpen
    if menuOpen then
        notify(Config.Messages.menuOpenHint)
    end
end)

RegisterNetEvent('shieldx:client:setWeather', function(weather)
    SetWeatherTypeOvertimePersist(weather, 10.0)
    SetWeatherTypeNowPersist(weather)
    SetWeatherTypeNow(weather)
end)

RegisterNetEvent('shieldx:client:setTime', function(hour, minute)
    NetworkOverrideClockTime(hour, minute, 0)
end)

RegisterNetEvent('shieldx:client:teleportToMarker', teleportToWaypoint)

RegisterNetEvent('shieldx:client:giveWeapon', function(weaponName)
    local ped = PlayerPedId()
    local hash = GetHashKey(weaponName)
    GiveWeaponToPed(ped, hash, 250, false, true)
    notify(('Arme reçue: %s'):format(weaponName))
end)

RegisterNetEvent('shieldx:client:revive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    ClearPedBloodDamage(ped)
    SetEntityHealth(ped, 200)
    notify('Revive effectué.')
end)

RegisterNetEvent('shieldx:client:freeze', function(state)
    FreezeEntityPosition(PlayerPedId(), state)
    notify(state and 'Freeze activé.' or 'Freeze désactivé.')
end)

RegisterNetEvent('shieldx:client:spawnVehicle', function(modelName)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local hash = GetHashKey(modelName)

    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not HasModelLoaded(hash) then
        notify('Modèle invalide ou introuvable.')
        return
    end

    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetModelAsNoLongerNeeded(hash)
end)

RegisterCommand('openstaffmenu', function()
    TriggerServerEvent('shieldx:server:requestMenu')
end)

RegisterKeyMapping('openstaffmenu', 'Ouvrir le menu staff ShieldX', 'keyboard', Config.Permissions.menuKey)

CreateThread(function()
    while true do
        Wait(0)
        handleNoclipMovement()
        handleFreecamMovement()

        if menuOpen then
            drawMenu()

            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)

            if IsControlJustPressed(0, 172) then
                selectedIndex = selectedIndex - 1
                if selectedIndex < 1 then selectedIndex = #menuItems end
            elseif IsControlJustPressed(0, 173) then
                selectedIndex = selectedIndex + 1
                if selectedIndex > #menuItems then selectedIndex = 1 end
            elseif IsControlJustPressed(0, 191) then
                handleAction(menuItems[selectedIndex].action)
            elseif IsControlJustPressed(0, 177) then
                menuOpen = false
            end
        else
            Wait(100)
        end
    end
end)
