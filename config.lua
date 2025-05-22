Config = {}

-- Configuración general
Config.Command = "report"                    -- Comando para enviar reportes
Config.AdminCommand = "reports"              -- Comando para ver reportes (admins)
Config.MenuKey = 121                        -- Tecla para abrir menú (F10)
Config.Language = "es"                      -- Idioma del sistema

-- Configuración de Discord
Config.Discord = {
    Webhook = "TU_WEBHOOK_DISCORD_AQUI",    -- Webhook de Discord
    BotName = "Sistema de Reportes",         -- Nombre del bot
    EnableLogs = true                       -- Activar logs en Discord
}

-- Configuración de capturas
Config.Screenshots = {
    Enable = true,                          -- Activar capturas automáticas
    Quality = 0.8,                         -- Calidad de la imagen (0.1 - 1.0)
    ImgurClientID = "TU_CLIENT_ID"         -- Client ID de Imgur
}

-- Grupos de administradores
Config.AdminGroups = {
    'admin',
    'superadmin',
    'moderator',
    'helper'
}

-- Ubicaciones de teleporte
Config.TeleportLocations = {
    LosSantos = vector3(-269.4, -957.3, 31.2),
    SandyShores = vector3(1961.1, 3740.5, 32.3),
    PaletoBay = vector3(-104.9, 6327.5, 31.9),
    CayoPerico = vector3(4840.5, -5174.4, 2.0)
}

-- Vehículos para dar
Config.Vehicles = {
    Bike = {
        'bmx',
        'cruiser',
        'fixter',
        'scorcher'
    },
    Car = {
        'sultan',
        'futo',
        'blista',
        'asea'
    }
}

-- Configuración de notificaciones
Config.Notifications = {
    Duration = 5000,                        -- Duración en ms
    Position = "top-right",                 -- Posición de las notificaciones
    Sound = true                           -- Reproducir sonido
}

-- Límites del sistema
Config.Limits = {
    MaxReports = 100,                      -- Máximo reportes almacenados
    MaxDeathLogs = 500,                    -- Máximo logs de muerte
    ReportCooldown = 30,                   -- Cooldown entre reportes (segundos)
    MessageLength = 500                    -- Longitud máxima del mensaje
}

-- Configuración de espectador
Config.Spectator = {
    EnableControls = true,                 -- Permitir controles en modo espectador
    ShowHUD = false,                       -- Mostrar HUD en modo espectador
    AllowWeapons = false                   -- Permitir armas en modo espectador
}

-- Mensajes del sistema
Config.Messages = {
    es = {
        -- Mensajes generales
        report_sent = "Reporte enviado correctamente",
        report_received = "Nuevo reporte recibido",
        no_permission = "No tienes permisos para usar este comando",
        player_not_found = "Jugador no encontrado",
        invalid_id = "ID de jugador inválido",
        
        -- Mensajes de admin
        spectating_player = "Especteando a %s",
        stopped_spectating = "Modo espectador desactivado",
        vehicle_given = "Vehículo entregado a %s",
        message_sent = "Mensaje enviado a %s",
        player_teleported = "Jugador teleportado",
        player_healed = "Jugador curado",
        player_killed = "Jugador eliminado",
        player_banned = "%s ha sido baneado",
        player_kicked = "%s ha sido kickeado",
        report_assigned = "Reporte asignado",
        report_closed = "Reporte cerrado",
        
        -- Errores
        screenshot_failed = "Error al tomar captura",
        teleport_failed = "Error en teleporte",
        action_failed = "Acción fallida",
        cooldown_active = "Espera %d segundos antes de enviar otro reporte"
    }
}

-- Configuración de la base de datos (opcional)
Config.Database = {
    Enable = false,                        -- Usar base de datos
    Table = "player_reports",              -- Nombre de la tabla
    SaveDeathLogs = true,                  -- Guardar logs de muerte
    SaveScreenshots = true                 -- Guardar URLs de capturas
}

-- Configuración de sonidos
Config.Sounds = {
    NewReport = "CHALLENGE_UNLOCKED",      -- Sonido para nuevo reporte
    ReportClosed = "WAYPOINT_SET",         -- Sonido cuando se cierra reporte
    AdminAction = "SELECT"                 -- Sonido para acciones de admin
}