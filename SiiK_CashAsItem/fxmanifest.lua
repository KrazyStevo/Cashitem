fx_version 'cerulean'
game 'gta5'

author 'SiiKStevo x ChatGPT'
description 'Cash as Item (sync QB cash <-> inventory item) for CodeM Bank v2 + JPR Inventory'
version '1.0.0'

shared_scripts {
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
