fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Zartoz'
description 'Simple marketplace script for QBCore Framework.'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua', -- Ensure you have mysql-async installed
    'server.lua'
}

dependencies {
    'qb-core'
}
