Config = {}

Config.ResourceName = GetCurrentResourceName() or 'shieldx'
Config.Locale = 'fr'

Config.Permissions = {
    aceGroup = 'group.admin',
    menuCommand = 'shieldx',
    menuKey = 'F10'
}

Config.Webhooks = {
    anticheat = '',
    staff = ''
}

Config.Protection = {
    antiGodmode = true,
    antiInvisible = true,
    antiSuperJump = true,
    antiSpeedHack = true,
    antiBlacklistedWeapons = true,
    antiBlacklistedVehicles = true,
    antiBlacklistedPeds = true,
    antiExplosionSpam = true,
    antiTriggerSpam = true,
    antiSpectate = true,
    antiResourceStop = true,
    antiVPN = false,
    antiExecutorPatterns = true,
    antiTeleport = true,
    antiNoclip = false, -- mettre a true si vous voulez aussi bloquer le noclip hors staff
    antiThermalVision = true,
    antiNightVision = true,
    antiInfiniteAmmo = true,
    antiRapidFire = true,
    antiWeaponDamageModifier = true,
    antiVehicleGodmode = true
}

Config.Thresholds = {
    maxPlayerSpeed = 11.0,
    maxJumpHeight = 10.0,
    maxTeleportDistance = 250.0,
    maxExplosionsPerWindow = 6,
    explosionWindowMs = 3500,
    maxTriggerPerWindow = 40,
    triggerWindowMs = 5000,
    maxAmmoDelta = 250,
    maxDamageModifier = 1.5,
    antiCheatTickMs = 1000
}

Config.StaffIdentifiers = {
    'license:CHANGE_ME',
    'discord:CHANGE_ME'
}

Config.Blacklists = {
    weapons = {
        `WEAPON_RAILGUN`,
        `WEAPON_MINIGUN`,
        `WEAPON_RPG`,
        `WEAPON_HOMINGLAUNCHER`,
        `WEAPON_GRENADELAUNCHER`
    },
    vehicles = {
        `RHINO`,
        `LAZER`,
        `HYDRA`,
        `OPPRESSOR`,
        `OPPRESSOR2`
    },
    peds = {
        `S_M_Y_SWAT_01`,
        `U_M_Y_ZOMBIE_01`,
        `S_M_Y_MARINE_03`
    },
    explosionTypes = {
        [0] = false,
        [1] = false,
        [2] = true,
        [4] = true,
        [5] = true,
        [25] = true,
        [32] = true,
        [37] = true
    }
}

Config.AdminMenu = {
    maxGiveMoney = 500000,
    maxGiveItem = 100,
    weatherTypes = {
        'CLEAR', 'EXTRASUNNY', 'CLOUDS', 'OVERCAST', 'RAIN', 'THUNDER', 'FOGGY', 'XMAS'
    },
    timePresets = {
        { label = 'Matin', hour = 8, minute = 0 },
        { label = 'Midi', hour = 12, minute = 0 },
        { label = 'Soir', hour = 19, minute = 0 },
        { label = 'Nuit', hour = 23, minute = 0 }
    },
    noclip = {
        speed = 1.25,
        fastMultiplier = 3.0,
        upKey = 44, -- Q
        downKey = 38, -- E
        forwardKey = 32, -- Z (AZERTY)
        backwardKey = 33, -- S (AZERTY)
        leftKey = 34, -- Q / A
        rightKey = 35 -- D
    }
}

Config.Messages = {
    prefix = '^1[ShieldX]^7 ',
    noPermission = 'Vous n\'avez pas la permission.',
    menuOpenHint = 'Menu staff ouvert. Utilisez ↑ ↓ ← → Entrée Retour.',
    playerDropped = 'Vous avez été expulsé: activité suspecte détectée.'
}
