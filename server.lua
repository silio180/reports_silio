-- Server.lua
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local reports = {}
local reportIdCounter = 1
local deathLogs = {}

-- Configuración de grupos admin
local adminGroups = {
    'admin',
    'superadmin',
    'moderator'
}

-- Discord Webhook para notificaciones
local discordWebhook = "TU_WEBHOOK_DISCORD_AQUI"

-- Función para verificar si es admin
function IsPlayerAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    for _, group in ipairs(adminGroups) do
        if xPlayer.getGroup() == group then
            return true
        end
    end
    return false
end

-- Función para enviar mensaje a Discord
function SendToDiscord(title, message, color)
    if discordWebhook == "TU_WEBHOOK_DISCORD_AQUI" then return end
    
    local embed = {
        {
            ["color"] = color or 3447003,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Sistema de Reportes FiveM",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    PerformHttpRequest(discordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = "Sistema de Reportes",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Obtener identifiers del jugador
function GetPlayerIdentifiers(source)
    local identifiers = {}
    
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        local prefix = string.match(identifier, "(.-):")
        if prefix then
            identifiers[prefix] = identifier
        end
    end
    
    return identifiers
end

-- Evento para enviar reporte
RegisterServerEvent('reports:sendReport')
AddEventHandler('reports:sendReport', function(reportData)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    local report = {
        id = reportIdCounter,
        playerId = source,
        playerName = xPlayer.getName(),
        subject = reportData.subject,
        description = reportData.description,
        screenshot = reportData.screenshot,
        coords = reportData.coords,
        timestamp = reportData.timestamp,
        status = "open",
        assigned = nil
    }
    
    reports[reportIdCounter] = report
    reportIdCounter = reportIdCounter + 1
    
    -- Notificar a todos los admins
    local players = ESX.GetPlayers()
    for _, playerId in ipairs(players) do
        if IsPlayerAdmin(playerId) then
            TriggerClientEvent('reports:newReportNotification', playerId, report)
        end
    end
    
    -- Enviar a Discord
    local discordMessage = string.format(
        "**🚨 Nuevo Reporte #%d**\n" ..
        "**👤 Jugador:** %s (ID: %d)\n" ..
        "**📝 Asunto:** %s\n" ..
        "**📄 Descripción:** %s\n" ..
        "**⏰ Fecha:** %s\n" ..
        "**📸 Captura:** %s",
        report.id, report.playerName, report.playerId, 
        report.subject, report.description, 
        os.date("%Y-%m-%d %H:%M:%S", report.timestamp), 
        report.screenshot
    )
    
    SendToDiscord("Nuevo Reporte", discordMessage, 15158332) -- Color rojo
    
    print(string.format("[REPORTES] Nuevo reporte #%d de %s: %s", report.id, report.playerName, report.subject))
end)

-- Verificar si es admin y abrir menú
RegisterServerEvent('reports:checkAdmin')
AddEventHandler('reports:checkAdmin', function()
    local source = source
    
    if IsPlayerAdmin(source) then
        local activeReports = {}
        for _, report in pairs(reports) do
            if report.status == "open" then
                table.insert(activeReports, report)
            end
        end
        
        TriggerClientEvent('reports:openMenu', source, activeReports)
    else
        TriggerClientEvent('reports:notify', source, 'No tienes permisos para usar este comando', 'error')
    end
end)

-- Espectear jugador
RegisterServerEvent('reports:spectatePlayer')
AddEventHandler('reports:spectatePlayer', function(targetId)
    local source = source
    
    if IsPlayerAdmin(source) then
        TriggerClientEvent('reports:startSpectating', source, targetId)
        TriggerClientEvent('reports:notify', source, 'Especteando a ' .. GetPlayerName(targetId), 'success')
    end
end)

-- Dar vehículo
RegisterServerEvent('reports:giveVehicle')
AddEventHandler('reports:giveVehicle', function(targetId, vehicleType)
    local source = source
    
    if IsPlayerAdmin(source) then
        local vehicleModel = vehicleType == 'bike' and 'bmx' or 'sultan'
        TriggerClientEvent('esx:spawnVehicle', targetId, vehicleModel)
        
        local adminName = GetPlayerName(source)
        local targetName = GetPlayerName(targetId)
        local vehicleName = vehicleType == 'bike' and 'moto' or 'coche'
        
        TriggerClientEvent('reports:notify', source, 'Has dado un ' .. vehicleName .. ' a ' .. targetName, 'success')
        TriggerClientEvent('reports:notify', targetId, 'Un admin te ha dado un ' .. vehicleName, 'info')
    end
end)

-- Enviar mensaje
RegisterServerEvent('reports:sendMessage')
AddEventHandler('reports:sendMessage', function(targetId, message)
    local source = source
    
    if IsPlayerAdmin(source) then
        local adminName = GetPlayerName(source)
        TriggerClientEvent('chat:addMessage', targetId, {
            args = {'[ADMIN] ' .. adminName, message},
            color = {255, 0, 0}
        })
        
        TriggerClientEvent('reports:notify', source, 'Mensaje enviado a ' .. GetPlayerName(targetId), 'success')
    end
end)

-- Teleportarse al jugador
RegisterServerEvent('reports:teleportToPlayer')
AddEventHandler('reports:teleportToPlayer', function(targetId)
    local source = source
    
    if IsPlayerAdmin(source) then
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        TriggerClientEvent('esx:teleport', source, targetCoords)
        TriggerClientEvent('reports:notify', source, 'Te has teleportado a ' .. GetPlayerName(targetId), 'success')
    end
end)

-- Teleportar jugador
RegisterServerEvent('reports:teleportPlayerToMe')
AddEventHandler('reports:teleportPlayerToMe', function(targetId)
    local source = source
    
    if IsPlayerAdmin(source) then
        local adminCoords = GetEntityCoords(GetPlayerPed(source))
        TriggerClientEvent('esx:teleport', targetId, adminCoords)
        
        TriggerClientEvent('reports:notify', source, 'Has teleportado a ' .. GetPlayerName(targetId), 'success')
        TriggerClientEvent('reports:notify', targetId, 'Un admin te ha teleportado', 'info')
    end
end)

-- Teleportar a ubicación específica
RegisterServerEvent('reports:teleportPlayer')
AddEventHandler('reports:teleportPlayer', function(targetId, coords)
    local source = source
    
    if IsPlayerAdmin(source) then
        TriggerClientEvent('esx:teleport', targetId, coords)
        TriggerClientEvent('reports:notify', source, 'Has teleportado a ' .. GetPlayerName(targetId), 'success')
        TriggerClientEvent('reports:notify', targetId, 'Has sido teleportado por un admin', 'info')
    end
end)

-- Banear jugador
RegisterServerEvent('reports:banPlayer')
AddEventHandler('reports:banPlayer', function(targetId, reason)
    local source = source
    
    if IsPlayerAdmin(source) then
        local adminName = GetPlayerName(source)
        local targetName = GetPlayerName(targetId)
        
        -- Aquí puedes integrar tu sistema de bans favorito
        -- Ejemplo básico:
        DropPlayer(targetId, 'Has sido baneado por ' .. adminName .. '. Razón: ' .. reason)
        
        -- Log a Discord
        local discordMessage = string.format(
            "**Jugador Baneado**\n" ..
            "**Admin:** %s\n" ..
            "**Jugador:** %s (ID: %d)\n" ..
            "**Razón:** %s",
            adminName, targetName, targetId, reason
        )
        
        SendToDiscord("Ban Aplicado", discordMessage, 16711680) -- Color rojo brillante
        
        TriggerClientEvent('reports:notify', source, targetName .. ' ha sido baneado', 'success')
    end
end)

-- Kickear jugador
RegisterServerEvent('reports:kickPlayer')
AddEventHandler('reports:kickPlayer', function(targetId, reason)
    local source = source
    
    if IsPlayerAdmin(source) then
        local adminName = GetPlayerName(source)
        local targetName = GetPlayerName(targetId)
        
        DropPlayer(targetId, 'Has sido kickeado por ' .. adminName .. '. Razón: ' .. reason)
        TriggerClientEvent('reports:notify', source, targetName .. ' ha sido kickeado', 'success')
    end
end)

-- Curar jugador
RegisterServerEvent('reports:healPlayer')
AddEventHandler('reports:healPlayer', function(targetId)
    local source = source
    
    if IsPlayerAdmin(source) then
        TriggerClientEvent('esx_basicneeds:healPlayer', targetId)
        TriggerClientEvent('reports:notify', source, 'Has curado a ' .. GetPlayerName(targetId), 'success')
        TriggerClientEvent('reports:notify', targetId, 'Has sido curado por un admin', 'info')
    end
end)

-- Matar jugador
RegisterServerEvent('reports:killPlayer')
AddEventHandler('reports:killPlayer', function(targetId)
    local source = source
    
    if IsPlayerAdmin(source) then
        TriggerClientEvent('esx:killPlayer', targetId)
        TriggerClientEvent('reports:notify', source, 'Has matado a ' .. GetPlayerName(targetId), 'success')
    end
end)

-- Obtener identificadores
RegisterServerEvent('reports:getIdentifiers')
AddEventHandler('reports:getIdentifiers', function(targetId)
    local source = source
    
    if IsPlayerAdmin(source) then
        local identifiers = GetPlayerIdentifiers(targetId)
        identifiers['Nombre'] = GetPlayerName(targetId)
        identifiers['ID'] = targetId
        
        TriggerClientEvent('reports:showIdentifiers', source, identifiers)
    end
end)

-- Obtener logs de muerte
RegisterServerEvent('reports:getDeathLogs')
AddEventHandler('reports:getDeathLogs', function(targetId)
    local source = source
    
    if IsPlayerAdmin(source) then
        local playerLogs = {}
        
        for _, log in ipairs(deathLogs) do
            if log.playerId == targetId then
                table.insert(playerLogs, log)
            end
        end
        
        TriggerClientEvent('reports:showDeathLogs', source, playerLogs)
    end
end)

-- Asignar reporte
RegisterServerEvent('reports:assignReport')
AddEventHandler('reports:assignReport', function(reportId)
    local source = source
    
    if IsPlayerAdmin(source) and reports[reportId] then
        local adminName = GetPlayerName(source)
        reports[reportId].assigned = adminName
        
        TriggerClientEvent('reports:notify', source, 'Te has asignado el reporte #' .. reportId, 'success')
        
        -- Actualizar menú
        local activeReports = {}
        for _, report in pairs(reports) do
            if report.status == "open" then
                table.insert(activeReports, report)
            end
        end
        TriggerClientEvent('reports:openMenu', source, activeReports)
    end
end)

-- Cerrar reporte
RegisterServerEvent('reports:closeReport')
AddEventHandler('reports:closeReport', function(reportId)
    local source = source
    
    if IsPlayerAdmin(source) and reports[reportId] then
        local adminName = GetPlayerName(source)
        reports[reportId].status = "closed"
        reports[reportId].closedBy = adminName
        reports[reportId].closedAt = os.date("%Y-%m-%d %H:%M:%S")
        
        -- Notificar al jugador que hizo el reporte
        local reportPlayerId = reports[reportId].playerId
        if GetPlayerName(reportPlayerId) then
            TriggerClientEvent('reports:notify', reportPlayerId, 'Tu reporte ha sido cerrado por ' .. adminName, 'info')
        end
        
        TriggerClientEvent('reports:notify', source, 'Reporte #' .. reportId .. ' cerrado', 'success')
        
        -- Log a Discord
        local discordMessage = string.format(
            "**📋 Reporte Cerrado #%d**\n" ..
            "**👨‍💼 Admin:** %s\n" ..
            "**👤 Jugador Original:** %s\n" ..
            "**📝 Asunto:** %s\n" ..
            "**📄 Descripción:** %s",
            reportId, adminName, reports[reportId].playerName, 
            reports[reportId].subject, reports[reportId].description
        )
        
        SendToDiscord("Reporte Cerrado", discordMessage, 65280) -- Color verde
    end
end)

-- Registrar muerte para logs
AddEventHandler('esx:onPlayerDeath', function(playerId, data)
    table.insert(deathLogs, {
        id = #deathLogs + 1,
        playerId = playerId,
        playerName = GetPlayerName(playerId),
        reason = data.deathCause or "Desconocido",
        date = os.date("%Y-%m-%d %H:%M:%S"),
        coords = GetEntityCoords(GetPlayerPed(playerId))
    })
    
    -- Mantener solo los últimos 50 logs por jugador
    if #deathLogs > 500 then
        table.remove(deathLogs, 1)
    end
end)

-- Comando para ver estadísticas de reportes
RegisterCommand('reportstats', function(source)
    if IsPlayerAdmin(source) then
        local openReports = 0
        local closedReports = 0
        
        for _, report in pairs(reports) do
            if report.status == "open" then
                openReports = openReports + 1
            else
                closedReports = closedReports + 1
            end
        end
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {'[SISTEMA]', 'Reportes abiertos: ' .. openReports .. ' | Reportes cerrados: ' .. closedReports},
            color = {0, 255, 255}
        })
    end
end, false)

print("^2[REPORTES] Sistema de reportes cargado correctamente^0")