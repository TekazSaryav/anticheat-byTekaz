RPConfig = {}

RPConfig.SaveIntervalMs = 30000
RPConfig.StartCash = 2500
RPConfig.StartBank = 15000
RPConfig.PaycheckIntervalMs = 15 * 60 * 1000
RPConfig.DefaultSpawn = vector4(-1042.16, -2745.61, 21.36, 329.17)
RPConfig.MaxTransfer = 50000
RPConfig.UseStateBags = true

RPConfig.Jobs = {
    unemployed = {
        label = 'Sans emploi',
        grades = {
            [0] = { label = 'Citoyen', salary = 100 }
        }
    },
    police = {
        label = 'LSPD',
        grades = {
            [0] = { label = 'Cadet', salary = 450 },
            [1] = { label = 'Officier', salary = 650 },
            [2] = { label = 'Sergent', salary = 850 },
            [3] = { label = 'Lieutenant', salary = 1100 }
        }
    },
    ems = {
        label = 'EMS',
        grades = {
            [0] = { label = 'Interne', salary = 420 },
            [1] = { label = 'Ambulancier', salary = 620 },
            [2] = { label = 'Médecin', salary = 900 }
        }
    },
    mechanic = {
        label = 'Mécano',
        grades = {
            [0] = { label = 'Apprenti', salary = 400 },
            [1] = { label = 'Technicien', salary = 600 },
            [2] = { label = 'Chef atelier', salary = 850 }
        }
    }
}

RPConfig.Items = {
    water = { label = 'Bouteille d\'eau', weight = 1, canUse = true },
    bread = { label = 'Pain', weight = 1, canUse = true },
    bandage = { label = 'Bandage', weight = 1, canUse = true },
    repairkit = { label = 'Kit de réparation', weight = 3, canUse = true },
    phone = { label = 'Téléphone', weight = 1, canUse = false }
}

RPConfig.MaxInventoryWeight = 40

RPConfig.StarterItems = {
    { name = 'water', count = 3 },
    { name = 'bread', count = 2 },
    { name = 'phone', count = 1 }
}

RPConfig.Commands = {
    stats = 'rpstats',
    transfer = 'pay',
    setjob = 'setjob'
}
