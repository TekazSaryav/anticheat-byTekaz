fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'byTekaz + Codex'
description 'ShieldX + PulseLite RP (core economy/jobs/hud/inventory)'
version '2.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/rp_config.lua'
}

client_scripts {
    'client/anticheat.lua',
    'client/menu.lua',
    'client/rp_core.lua'
}

server_scripts {
    'server/anticheat.lua',
    'server/admin.lua',
    'server/rp_core.lua'
}
