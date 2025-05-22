fx_version 'cerulean'
game 'gta5'

name 'Sistema de Reportes'
description 'Sistema completo de reportes para administradores'
author 'Tu Nombre'
version '1.0.0'

-- Dependencias
dependencies {
    'es_extended',
    'mysql-async',
    'screenshot-basic' -- Para capturas de pantalla
}

-- Scripts del cliente
client_scripts {
    '@es_extended/locale.lua',
    'client.lua'
}

-- Scripts del servidor
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'server.lua'
}

-- Archivos UI
ui_page 'html/index.html'

files {
    'html/index.html'
}

-- Configuración
shared_scripts {
    'config.lua',
    '@es_extended/imports.lua'
}