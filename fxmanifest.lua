fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Zartoz'
description 'A simple QBCore Marketplace Script'
version '2.0.0'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_script 'client.lua'
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'qb-core'
}
