fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'byTekaz + Codex'
description 'ShieldX - Anticheat + Staff management menu'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/anticheat.lua',
    'client/menu.lua'
}

server_scripts {
    'server/anticheat.lua',
    'server/admin.lua'
}
