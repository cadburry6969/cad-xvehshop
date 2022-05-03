fx_version 'cerulean'
game 'gta5'

description 'Exclusive Priority Dealership [QBCore]'
author "Cadburry#7547"
version '2.0'

shared_script 'shared.lua'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

server_exports {
    "GetPriority",
}

lua54 'yes'

escrow_ignore {
    'client.lua',
    'server.lua',    
    'shared.lua',
}