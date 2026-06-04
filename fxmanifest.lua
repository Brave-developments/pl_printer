fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

name 'Printer Script'
author 'PulseScripts - pulsescripts.com'
version '1.1.0'

ui_page 'web/index.html'

shared_scripts {
    'config.lua',
    'locales/locale.lua'
}

client_scripts {
    'client/main.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'pl_lib',
}

files {
    'web/index.html',
    'locales/*.json'
}
