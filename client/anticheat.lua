local lastPosition = nil
local lastAmmoByWeapon = {}
local jumpStartZ = nil

local function report(reason)
    TriggerServerEvent('shieldx:server:reportViolation', reason)
end

local function isStaffLocal()
    return IsPlayerAceAllowed(PlayerId(), Config.Permissions.aceGroup)
end

local function hasWeaponBlacklisted(ped)
    local _, weapon = GetCurrentPedWeapon(ped, true)
    for _, blacklisted in ipairs(Config.Blacklists.weapons) do
        if weapon == blacklisted then
            return true
        end
    end
    return false
end

CreateThread(function()
    while true do
        Wait(Config.Thresholds.antiCheatTickMs)

        local ped = PlayerPedId()
        if ped == 0 then goto continue end
        if isStaffLocal() then goto continue end

        if Config.Protection.antiInvisible and GetEntityAlpha(ped) < 150 then
            report('invisibilité détectée')
        end

        if Config.Protection.antiGodmode then
            local canBeDamaged = GetEntityCanBeDamaged(ped)
            if not canBeDamaged then
                report('godmode (canBeDamaged false)')
            end
        end

        if Config.Protection.antiSuperJump and IsPedJumping(ped) then
            local z = GetEntityCoords(ped).z
            jumpStartZ = jumpStartZ or z
            if z - jumpStartZ > Config.Thresholds.maxJumpHeight then
                report('super jump détecté')
            end
        else
            jumpStartZ = nil
        end

        if Config.Protection.antiSpeedHack then
            local speed = GetEntitySpeed(ped)
            if not IsPedInAnyVehicle(ped, false) and speed > Config.Thresholds.maxPlayerSpeed then
                report(('speedhack (%.2f)'):format(speed))
            end
        end

        if Config.Protection.antiBlacklistedWeapons and hasWeaponBlacklisted(ped) then
            RemoveAllPedWeapons(ped, true)
            report('arme blacklist')
        end

        if Config.Protection.antiInfiniteAmmo then
            local _, currentWeapon = GetCurrentPedWeapon(ped, true)
            if currentWeapon and currentWeapon ~= 0 then
                local ammo = GetAmmoInPedWeapon(ped, currentWeapon)
                local old = lastAmmoByWeapon[currentWeapon] or ammo
                if ammo - old > Config.Thresholds.maxAmmoDelta then
                    report(('munitions anormales (%s -> %s)'):format(old, ammo))
                end
                lastAmmoByWeapon[currentWeapon] = ammo
            end
        end

        if Config.Protection.antiTeleport then
            local coords = GetEntityCoords(ped)
            if lastPosition then
                local dist = #(coords - lastPosition)
                if dist > Config.Thresholds.maxTeleportDistance and not IsPedInAnyVehicle(ped, false) then
                    report(('téléportation suspecte (%.2f m)'):format(dist))
                end
            end
            lastPosition = coords
        end

        if Config.Protection.antiThermalVision and GetUsingseethrough() then
            report('vision thermique détectée')
        end

        if Config.Protection.antiNightVision and GetUsingnightvision() then
            report('vision nocturne détectée')
        end

        ::continue::
    end
end)

AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == 'CEventNetworkEntityDamage' and Config.Protection.antiWeaponDamageModifier then
        local victim = args[1]
        local attacker = args[2]
        if attacker == PlayerPedId() and victim ~= 0 then
            local modifier = GetPlayerWeaponDamageModifier(PlayerId())
            if modifier > Config.Thresholds.maxDamageModifier then
                report(('weapon damage modifier %.2f'):format(modifier))
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        TriggerServerEvent('shieldx:server:validateAction', 'heartbeat')
    end
end)
