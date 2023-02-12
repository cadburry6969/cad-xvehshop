fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Exclusive Priority Dealership'
author "Cadburry#7547"
version '3.0'

shared_script 'config.lua'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'nui/init.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- oxmysql (v2.3+)
    'config_discord.lua',
    'server/*.lua'
}

files {
    'nui/*',
}

ui_page 'nui/index.html'

dependencies {
    '/onesync',
}

escrow_ignore {
    'config_discord.lua',
    'config.lua',
    'client/*.lua',
    'server/*.lua',
}