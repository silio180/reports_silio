ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Client.lua
local isReportMenuOpen = false
local currentReports = {}
local isSpectating = false
local spectatingTarget = nil

-- Initialize report data structure
local reportData = {
    subject = nil,
    description = nil,
    screenshot = nil,
    coords = nil,
    timestamp = nil
}

-- Function to reset report data
function ResetReportData()
    reportData = {
        subject = nil,
        description = nil,
        screenshot = nil,
        coords = nil,
        timestamp = nil
    }
end

-- Configuración
local Config = {
    Command = "report",
    AdminCommand = "reports",
    MenuKey = 121, -- F10
    DiscordWebhook = "TU_WEBHOOK_AQUI"
}

-- Función para tomar screenshot
function TakeScreenshot(cb)
    if not exports['screenshot-basic'] then
        print("Error: screenshot-basic no está disponible")
        return cb(nil)
    end

    exports['screenshot-basic']:requestScreenshotUpload(GetConvar('screenshot_basic_url', 'https://api.imgur.com/3/image'), 'imgur', {
        encoding = 'jpg',
        headers = {
            ['authorization'] = 'Client-ID ' .. GetConvar('imgur_client_id', 'YOUR_IMGUR_CLIENT_ID')
        }
    }, function(data)
        local response = json.decode(data)
        if response and response.data and response.data.link then
            cb(response.data.link)
        else
            print("Error al subir la captura")
            cb(nil)
        end
    end)
end

-- Función para enviar reporte (modificada)
-- Replace the SendReport function
function SendReport(reportData)
    print("Enviando reporte con:", json.encode(reportData)) -- Debug

    if not reportData or not reportData.subject or reportData.subject == "" then
        TriggerEvent('reports:notify', 'Debes seleccionar un asunto', 'error')
        return
    end
    
    if not reportData.description or reportData.description == "" then
        TriggerEvent('reports:notify', 'Debes escribir una descripción', 'error')
        return
    end

    TakeScreenshot(function(screenshotUrl)
        local playerData = {
            id = GetPlayerServerId(PlayerId()),
            name = GetPlayerName(PlayerId()),
            coords = GetEntityCoords(PlayerPedId()),
            subject = reportData.subject,
            description = reportData.description,
            screenshot = screenshotUrl or "No disponible",
            timestamp = GetGameTimer() -- Changed from os.time()
        }
        
        print("Datos finales:", json.encode(playerData)) -- Debug
        TriggerServerEvent('reports:sendReport', playerData)
        TriggerEvent('reports:notify', '~g~Reporte enviado correctamente!', 'success')
    end)
end

-- Comando para enviar reporte - Ahora abre menú
RegisterCommand(Config.Command, function(source, args)
    OpenReportSubmissionMenu()
end)


-- Función para abrir menú de envío de reporte
function OpenReportSubmissionMenu()
    local elements = {
        {label = "📝 Asunto del reporte", value = "subject", description = "Selecciona el tipo de reporte"},
        {label = "📄 Descripción detallada", value = "description", description = "Describe lo que ha ocurrido"},
        {label = "📤 Enviar reporte", value = "send", description = "Enviar el reporte a los administradores"}
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'report_submission', {
        title = '📋 Enviar Reporte',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'subject' then
            OpenSubjectMenu(menu)
        elseif data.current.value == 'description' then
            OpenDescriptionInput(menu)
        elseif data.current.value == 'screenshot' then
            TakeScreenshot(function(url)
                reportData.screenshot = url
                TriggerEvent('reports:notify', 'Captura guardada', 'success')
            end)
        elseif data.current.value == 'send' then
            SendReport(reportData)
            menu.close()
            ResetReportData()
        end
    end, function(data, menu)
        menu.close()
        ResetReportData()
    end)
end

-- Menú para seleccionar asunto
function OpenSubjectMenu(parentMenu)
    local elements = {
        {label = "🚫 Jugador rompiendo reglas", value = "rules"},
        {label = "🤖 Posible cheater/hacker", value = "cheater"},
        {label = "🎭 Rol inadecuado", value = "roleplay"},
        {label = "💬 Toxicidad/Insultos", value = "toxicity"},
        {label = "🚗 Fail driving/VDM", value = "driving"},
        {label = "🔫 RDM (Random Death Match)", value = "rdm"},
        {label = "🏃 Metagaming", value = "metagaming"},
        {label = "🚁 Abuso de bugs", value = "bugs"},
        {label = "🆘 Solicitar ayuda", value = "help"},
        {label = "📝 Otro (especificar)", value = "other"}
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'report_subject', {
        title = '📝 Seleccionar Asunto',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == "other" then
            DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Especifica el asunto:", "", "", "", 64)
            while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                Citizen.Wait(0)
            end
            if UpdateOnscreenKeyboard() ~= 2 then
                reportData.subject = GetOnscreenKeyboardResult()
            end
        else
            reportData.subject = data.current.label
        end
        
        if reportData.subject and reportData.subject ~= "" then
            TriggerEvent('reports:notify', 'Asunto seleccionado: ' .. reportData.subject, 'success')
            menu.close()
            OpenReportSubmissionMenu()
        else
            TriggerEvent('reports:notify', 'Debes seleccionar un asunto válido', 'error')
        end
    end, function(data, menu)
        menu.close()
        OpenReportSubmissionMenu()
    end)
end

-- Input para descripción
function OpenDescriptionInput(parentMenu)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Describe detalladamente lo ocurrido:", "", "", "", 255)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        reportData.description = GetOnscreenKeyboardResult()
        if reportData.description and reportData.description ~= "" then
            TriggerEvent('reports:notify', 'Descripción guardada', 'success')
        end
    end
    OpenReportSubmissionMenu()
end

-- Comando para abrir menú de reportes (solo admins)
RegisterCommand(Config.AdminCommand, function()
    TriggerServerEvent('reports:checkAdmin')
end)

-- Tecla para abrir menú de reportes y ESC para salir de espectador
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- F10 para abrir menú de reportes
        if IsControlJustPressed(0, Config.MenuKey) then
            TriggerServerEvent('reports:checkAdmin')
        end
        
        -- ESC para salir del modo espectador
        if isSpectating and IsControlJustPressed(0, 322) then -- 322 = ESC
            TriggerEvent('reports:stopSpectating')
        end
    end
end)

-- Abrir menú de reportes
RegisterNetEvent('reports:openMenu')
AddEventHandler('reports:openMenu', function(reports)
    currentReports = reports
    OpenReportsMenu()
end)

-- Función para abrir el menú principal
function OpenReportsMenu()
    local elements = {}
    
    if #currentReports == 0 then
        table.insert(elements, {
            label = "📭 No hay reportes disponibles",
            value = "no_reports"
        })
    else
        for i, report in ipairs(currentReports) do
            local status = report.assigned and ("👤 " .. report.assigned) or "❌ Sin asignar"
            local timeAgo = GetTimeAgo(report.timestamp)
            table.insert(elements, {
                label = string.format("📋 #%d | %s | %s\n📝 %s\n⏰ %s", 
                    report.id, report.playerName, status, report.subject, timeAgo),
                value = "report_" .. i,
                report = report
            })
        end
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'reports_menu', {
        title = '🚨 Sistema de Reportes (' .. #currentReports .. ')',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value ~= "no_reports" then
            OpenReportDetailsMenu(data.current.report)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Menú de detalles del reporte
function OpenReportDetailsMenu(report)
    -- Mostrar información detallada primero
    local timeAgo = GetTimeAgo(report.timestamp)
    local assigned = report.assigned or "Sin asignar"
    
    -- Mostrar la información como notificación
    SetNotificationTextEntry("STRING")
    AddTextComponentString(string.format(
        "~y~📋 INFORMACIÓN DEL REPORTE #%d~w~\n" ..
        "~b~👤 Jugador:~w~ %s (ID: %s)\n" ..
        "~g~📝 Asunto:~w~ %s\n" ..
        "~o~📄 Descripción:~w~ %s\n" ..
        "~c~⏰ Enviado:~w~ %s\n" ..
        "~p~👨‍💼 Asignado a:~w~ %s\n" ..
        "~y~📍 Ubicación:~w~ %.1f, %.1f, %.1f",
        report.id,
        report.playerName,
        report.playerId,
        report.subject,
        report.description,
        timeAgo,
        assigned,
        report.coords.x, report.coords.y, report.coords.z
    ))
    DrawNotification(true, false)
    
    -- Mostrar captura automáticamente si existe
    if report.screenshot then
        SendNUIMessage({
            type = "showScreenshot",
            url = report.screenshot
        })
    end
    
    -- Esperar un momento antes de mostrar el menú
    Citizen.Wait(500)
    
    -- Menú de acciones
    local elements = {
        {label = "─────── ACCIONES ───────", value = "separator1"},
        {label = "👁️ Espectear jugador", value = "spectate"},
        {label = "💬 Enviar mensaje privado", value = "send_message"},
        {label = "─────── TELEPORTE ───────", value = "separator2"},
        {label = "📍 Teleportarse al jugador", value = "tp_to_player"},
        {label = "📍 Teleportar jugador a ti", value = "tp_player_to_me"},
        {label = "🌴 TP jugador a Los Santos", value = "tp_ls"},
        {label = "🏜️ TP jugador a Sandy Shores", value = "tp_sandy"},
        {label = "🏔️ TP jugador a Paleto Bay", value = "tp_paleto"},
        {label = "🏝️ TP jugador a Cayo Perico", value = "tp_cayo"},
        {label = "─────── VEHÍCULOS ───────", value = "separator3"},
        {label = "🏍️ Dar motocicleta", value = "give_bike"},
        {label = "🚗 Dar automóvil", value = "give_car"},
        {label = "─────── INFORMACIÓN ───────", value = "separator4"},
        {label = "🆔 Ver identificadores", value = "view_identifiers"},
        {label = "💀 Ver logs de muerte", value = "death_logs"},
        {label = "─────── MODERACIÓN ───────", value = "separator5"},
        {label = "❤️ Curar jugador", value = "heal_player"},
        {label = "💀 Matar jugador", value = "kill_player"},
        {label = "👢 Kickear jugador", value = "kick_player"},
        {label = "🔨 Banear jugador", value = "ban_player"},
        {label = "─────── GESTIÓN ───────", value = "separator6"},
        {label = "📝 Asignarse reporte", value = "assign_report"},
        {label = "✅ Cerrar reporte", value = "close_report"}
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'report_details', {
        title = string.format('📋 Reporte #%d - %s', report.id, report.playerName),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if string.find(data.current.value, "separator") then
            return
        end
        HandleReportAction(data.current.value, report, menu)
    end, function(data, menu)
        menu.close()
        OpenReportsMenu()
    end)
end

-- Mostrar información completa del reporte
function ShowReportInfo(report)
    local timeAgo = GetTimeAgo(report.timestamp)
    local assigned = report.assigned or "Sin asignar"
    
    local elements = {
        {label = "🆔 ID: " .. report.id, value = "info"},
        {label = "👤 Jugador: " .. report.playerName .. " (ID: " .. report.playerId .. ")", value = "info"},
        {label = "📝 Asunto: " .. report.subject, value = "info"},
        {label = "📄 Descripción: " .. report.description, value = "info"},
        {label = "⏰ Enviado: " .. timeAgo, value = "info"},
        {label = "👨‍💼 Asignado a: " .. assigned, value = "info"},
        {label = "📍 Ubicación: " .. string.format("%.1f, %.1f, %.1f", report.coords.x, report.coords.y, report.coords.z), value = "info"}
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'report_info', {
        title = '📋 Información del Reporte #' .. report.id,
        align = 'top-left',
        elements = elements
    }, function(data, menu) end, function(data, menu)
        menu.close()
    end)
end

-- Función para calcular tiempo transcurrido
function GetTimeAgo(timestamp)
    local currentTime = GetGameTimer()
    local diff = math.floor((currentTime - timestamp) / 1000) -- Convert to seconds
    
    if diff < 60 then
        return "Hace " .. diff .. " segundos"
    elseif diff < 3600 then
        return "Hace " .. math.floor(diff / 60) .. " minutos"
    elseif diff < 86400 then
        return "Hace " .. math.floor(diff / 3600) .. " horas"
    else
        return "Hace " .. math.floor(diff / 86400) .. " días"
    end
end

-- Manejar acciones del reporte
function HandleReportAction(action, report, menu)
    if action == "spectate" then
        TriggerServerEvent('reports:spectatePlayer', report.playerId)
    elseif action == "give_bike" then
        TriggerServerEvent('reports:giveVehicle', report.playerId, 'bike')
    elseif action == "give_car" then
        TriggerServerEvent('reports:giveVehicle', report.playerId, 'car')
    elseif action == "send_message" then
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 128)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(0)
        end
        if UpdateOnscreenKeyboard() ~= 2 then
            local message = GetOnscreenKeyboardResult()
            TriggerServerEvent('reports:sendMessage', report.playerId, message)
        end
    elseif action == "view_screenshot" then
        SendNUIMessage({
            type = "showScreenshot",
            url = report.screenshot
        })
    elseif action == "tp_to_player" then
        TriggerServerEvent('reports:teleportToPlayer', report.playerId)
    elseif action == "tp_player_to_me" then
        TriggerServerEvent('reports:teleportPlayerToMe', report.playerId)
    elseif action == "death_logs" then
        TriggerServerEvent('reports:getDeathLogs', report.playerId)
    elseif action == "tp_ls" then
        TriggerServerEvent('reports:teleportPlayer', report.playerId, vector3(-269.4, -957.3, 31.2))
    elseif action == "tp_sandy" then
        TriggerServerEvent('reports:teleportPlayer', report.playerId, vector3(1961.1, 3740.5, 32.3))
    elseif action == "tp_paleto" then
        TriggerServerEvent('reports:teleportPlayer', report.playerId, vector3(-104.9, 6327.5, 31.9))
    elseif action == "tp_cayo" then
        TriggerServerEvent('reports:teleportPlayer', report.playerId, vector3(4840.5, -5174.4, 2.0))
    elseif action == "ban_player" then
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Razón del ban:", "", "", "", 128)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(0)
        end
        if UpdateOnscreenKeyboard() ~= 2 then
            local reason = GetOnscreenKeyboardResult()
            TriggerServerEvent('reports:banPlayer', report.playerId, reason)
        end
    elseif action == "kick_player" then
        DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "Razón del kick:", "", "", "", 128)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(0)
        end
        if UpdateOnscreenKeyboard() ~= 2 then
            local reason = GetOnscreenKeyboardResult()
            TriggerServerEvent('reports:kickPlayer', report.playerId, reason)
        end
    elseif action == "heal_player" then
        TriggerServerEvent('reports:healPlayer', report.playerId)
    elseif action == "kill_player" then
        TriggerServerEvent('reports:killPlayer', report.playerId)
    elseif action == "view_identifiers" then
        TriggerServerEvent('reports:getIdentifiers', report.playerId)
    elseif action == "assign_report" then
        TriggerServerEvent('reports:assignReport', report.id)
    elseif action == "close_report" then
        TriggerServerEvent('reports:closeReport', report.id)
        menu.close()
        OpenReportsMenu()
    end
end

-- Eventos de notificación
RegisterNetEvent('reports:notify')
AddEventHandler('reports:notify', function(message, type)
    type = type or 'info'
    local color = type == 'success' and '~g~' or type == 'error' and '~r~' or '~y~'
    
    SetNotificationTextEntry("STRING")
    AddTextComponentString(color .. message)
    DrawNotification(false, false)
end)

-- Mostrar identificadores
RegisterNetEvent('reports:showIdentifiers')
AddEventHandler('reports:showIdentifiers', function(identifiers)
    local elements = {}
    for k, v in pairs(identifiers) do
        table.insert(elements, {
            label = k .. ": " .. v,
            value = k
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'identifiers', {
        title = 'Identificadores del Jugador',
        align = 'top-left',
        elements = elements
    }, function(data, menu) end, function(data, menu)
        menu.close()
    end)
end)

-- Mostrar logs de muerte
RegisterNetEvent('reports:showDeathLogs')
AddEventHandler('reports:showDeathLogs', function(logs)
    local elements = {}
    for _, log in ipairs(logs) do
        table.insert(elements, {
            label = log.date .. " - " .. log.reason,
            value = log.id
        })
    end
    
    if #elements == 0 then
        table.insert(elements, {
            label = "No hay logs de muerte disponibles",
            value = "no_logs"
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'death_logs', {
        title = 'Logs de Muerte',
        align = 'top-left',
        elements = elements
    }, function(data, menu) end, function(data, menu)
        menu.close()
    end)
end)

-- Modo espectador
RegisterNetEvent('reports:startSpectating')
AddEventHandler('reports:startSpectating', function(targetId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    if targetPed ~= 0 then
        isSpectating = true
        spectatingTarget = targetId
        NetworkSetInSpectatorMode(true, targetPed)
        TriggerEvent('reports:notify', 'Modo espectador activado', 'success')
    end
end)

RegisterNetEvent('reports:stopSpectating')
AddEventHandler('reports:stopSpectating', function()
    if isSpectating then
        NetworkSetInSpectatorMode(false, PlayerPedId())
        isSpectating = false
        spectatingTarget = nil
        TriggerEvent('reports:notify', 'Modo espectador desactivado', 'info')
    end
end)

-- Comando para salir del modo espectador
RegisterCommand('stopspec', function()
    if isSpectating then
        TriggerEvent('reports:stopSpectating')
    end
end)

-- Notificación de nuevo reporte para admins
RegisterNetEvent('reports:newReportNotification')
AddEventHandler('reports:newReportNotification', function(reportData)
    -- Notificación visual mejorada
    SetNotificationTextEntry("STRING")
    AddTextComponentString(string.format(
        "~r~🚨 ¡NUEVO REPORTE! ~w~#%d\n" ..
        "~b~👤 De:~w~ %s\n" ..
        "~y~📝 Asunto:~w~ %s\n" ..
        "~g~Usa~w~ /%s ~g~para verlo",
        reportData.id, reportData.playerName, reportData.subject, Config.AdminCommand
    ))
    DrawNotification(false, false)
    
    -- Sonido de notificación
    PlaySoundFrontend(-1, "CHALLENGE_UNLOCKED", "HUD_AWARDS", 1)
    
    -- Notificación adicional en chat
    TriggerEvent('chat:addMessage', {
        args = {'[REPORTES]', string.format('Nuevo reporte #%d de %s: %s', reportData.id, reportData.playerName, reportData.subject)},
        color = {255, 100, 100}
    })
end)