# 🚨 Sistema de Reportes FiveM

Un sistema completo de reportes para servidores FiveM con interfaz administrativa avanzada, capturas de pantalla automáticas y notificaciones en Discord.

## ✨ Características

### Para Jugadores
- 📝 Envío de reportes con `/report [mensaje]`
- 📸 Captura automática de pantalla al enviar reporte
- 🔔 Notificaciones cuando su reporte es atendido o cerrado

### Para Administradores
- 🎮 Menú completo accesible con `/reports` o **F10**
- 👁️ **Modo espectador** para observar jugadores
- 🚗 **Dar vehículos** (motos y coches)
- 💬 **Enviar mensajes** directos a jugadores
- 📸 **Ver capturas** del momento del reporte
- 📍 **Sistema de teleporte**:
  - Teleportarse al jugador
  - Teleportar jugador al admin
  - Teleporteos rápidos: Los Santos, Sandy Shores, Paleto Bay, Cayo Perico
- ⚡ **Acciones administrativas**:
  - Banear jugadores
  - Kickear jugadores
  - Curar jugadores
  - Eliminar jugadores
- 📊 **Información del jugador**:
  - Ver identificadores (Steam, Discord, etc.)
  - Logs de muerte
  - Historial de reportes
- 📋 **Gestión de reportes**:
  - Asignarse reportes
  - Cerrar reportes
  - Ver estadísticas

## 🛠️ Instalación

### Dependencias Requeridas
- **ESX Framework**
- **screenshot-basic** (para capturas)

### Pasos de Instalación

1. **Descargar el recurso**
   ```bash
   git clone [repositorio] reports-system
   ```

2. **Colocar en la carpeta resources**
   ```
   server-data/resources/[admin]/reports-system/
   ```

3. **Configurar dependencias**
   - Asegúrate de tener `screenshot-basic` instalado
   - Configura ESX correctamente

4. **Configurar Discord (Opcional)**
   - Edita `config.lua`
   - Añade tu webhook de Discord:
   ```lua
   Config.Discord.Webhook = "https://discord.com/api/webhooks/..."
   ```

5. **Configurar Imgur (Para capturas)**
   - Obtén un Client ID de Imgur
   - Edítalo en `config.lua`:
   ```lua
   Config.Screenshots.ImgurClientID = "tu_client_id"
   ```

6. **Añadir al server.cfg**
   ```
   ensure screenshot-basic
   ensure reports-system
   ```

## 🎮 Uso

### Comandos para Jugadores
- `/report [mensaje]` - Enviar un reporte

### Comandos para Administradores
- `/reports` - Abrir menú de reportes
- `/reportstats` - Ver estadísticas de reportes
- `/stopspec` - Salir del modo espectador
- **F10** - Abrir menú rápido (configurable)

### Grupos de Admin
Por defecto, estos grupos tienen acceso:
- `admin`
- `superadmin`
- `moderator`
- `helper`

Puedes modificar los grupos en `config.lua`.

## ⚙️ Configuración

### Ubicaciones de Teleporte
```lua
Config.TeleportLocations = {
    LosSantos = vector3(-269.4, -957.3, 31.2),
    SandyShores = vector3(1961.1, 3740.5, 32.3),
    PaletoBay = vector3(-104.9, 6327.5, 31.9),
    CayoPerico = vector3(4840.5, -5174.4, 2.0)
}
```

### Vehículos Disponibles
```lua
Config.Vehicles = {
    Bike = {'bmx', 'cruiser', 'fixter', 'scorcher'},
    Car = {'sultan', 'futo', 'blista', 'asea'}
}
```

### Límites del Sistema
```lua
Config.Limits = {
    MaxReports = 100,        -- Máximo reportes almacenados
    ReportCooldown = 30,     -- Cooldown entre reportes (segundos)
    MessageLength = 500      -- Longitud máxima del mensaje
}
```

## 🔧 Personalización

### Cambiar Tecla del Menú
En `config.lua`:
```lua
Config.MenuKey = 121  -- F10 (ver keycode en FiveM docs)
```

### Modificar Grupos Admin
```lua
Config.AdminGroups = {
    'admin',
    'superadmin',
    'tu_grupo_personalizado'
}
```

### Personalizar Mensajes
Todos los mensajes están en `Config.Messages` y son completamente personalizables.

## 📱 Discord Integration

El sistema puede enviar notificaciones automáticas a Discord:

- 🆕 **Nuevos reportes**
- ✅ **Reportes cerrados**
- 🔨 **Acciones administrativas** (bans, kicks)
- 📊 **Logs de actividad**

### Configurar Webhook
1. Crea un webhook en tu servidor de Discord
2. Copia la URL
3. Pégala en `config.lua`:
```lua
Config.Discord.Webhook = "tu_webhook_url"
```

## 🐛 Resolución de Problemas

### Los reportes no se envían
- Verifica que `screenshot-basic` esté funcionando
- Revisa que ESX esté correctamente configurado
- Comprueba la consola por errores

### Las capturas no funcionan
- Asegúrate de tener configurado el Client ID de Imgur
- Verifica que `screenshot-basic` esté actualizado
- Comprueba permisos del servidor

### Los admins no pueden acceder
- Verifica que el grupo del admin esté en `Config.AdminGroups`
- Revisa que ESX esté devolviendo el grupo correctamente
- Comprueba permisos en la base de datos

### Discord no recibe notificaciones
- Verifica que la URL del webhook sea correcta
- Comprueba que el webhook tenga permisos
- Revisa la consola por errores HTTP

## 📈 Características Avanzadas

### Sistema de Logs
- **Logs de muerte** automáticos
- **Historial de reportes** por jugador
- **Logs de acciones administrativas**

### Modo Espectador
- Vista libre del jugador reportado
- Controles intuitivos
- Salida rápida con comando

### Notificaciones Inteligentes
- Notificaciones visuales en el juego
- Sonidos personalizables
- Diferentes tipos (éxito, error, info)

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 🆘 Soporte

Si necesitas ayuda:
- 📚 Revisa la documentación
- 🐛 Reporta bugs en Issues
- 💬 Únete a nuestro Discord

---

**Desarrollado con ❤️ para la comunidad de FiveM**