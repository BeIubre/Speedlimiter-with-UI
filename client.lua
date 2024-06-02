ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local isSpeedLimitActive = false
local speedLimit = 0

function OpenSpeedLimitMenu()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        ESX.UI.Menu.CloseAll()

        local elements = {
            {label = "25 km/h", value = 25},
            {label = "50 km/h", value = 50},
            {label = "100 km/h", value = 100},
            {label = "150 km/h", value = 150},
            {label = "Benutzerdefiniert", value = "custom"},
            {label = "Deaktivieren", value = "disable"},
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'speed_limit_menu',
        {
            title = "Geschwindigkeitsbegrenzer",
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            if data.current.value == "disable" then
                DisableSpeedLimit()
            elseif data.current.value == "custom" then
                OpenCustomSpeedDialog()
            else
                SetSpeedLimit(data.current.value)
            end
        end, function(data, menu)
            menu.close()
        end)
    else
        TriggerEvent('notifications', "#780099", "Geschwindigkeitsbegrenzung", "Du musst in einem Fahrzeug sein, um das Menü zu öffnen.")
    end
end

function OpenCustomSpeedDialog()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'custom_speed_dialog',
    {
        title = "Benutzerdefinierte Geschwindigkeit (km/h)"
    }, function(data, menu)
        local customSpeed = tonumber(data.value)

        if customSpeed == nil or customSpeed <= 0 then
            TriggerEvent('notifications', "#780099", "Geschwindigkeitsbegrenzung", "Ungültiger Wert. Bitte gib eine positive Zahl ein.")
        else
            SetSpeedLimit(customSpeed)
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function SetSpeedLimit(limit)
    if not isSpeedLimitActive then
        TriggerEvent('notifications', "#780099", "Geschwindigkeitsbegrenzung", "Die Geschwindigkeitsbegrenzung wurde auf " .. limit .. " km/h gesetzt.")
        speedLimit = limit
        isSpeedLimitActive = true
        ApplySpeedLimit()
    else
        TriggerEvent('notifications', "#780099", "Geschwindigkeitsbegrenzung", "Die Geschwindigkeitsbegrenzung ist bereits aktiv. Deaktivieren Sie sie zuerst.")
    end
end

function DisableSpeedLimit()
    if isSpeedLimitActive then
        TriggerEvent('notifications', "#780099", "Geschwindigkeitsbegrenzung", "Die Geschwindigkeitsbegrenzung wurde deaktiviert.")
        isSpeedLimitActive = false
        RemoveSpeedLimit()
    else
        TriggerEvent('notifications', "#780099", "Geschwindigkeitsbegrenzung", "Die Geschwindigkeitsbegrenzung ist bereits deaktiviert.")
    end
end


function RemoveSpeedLimit()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    SetEntityMaxSpeed(vehicle, 999.0)
end

function ApplySpeedLimit()
    if isSpeedLimitActive then
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local currentSpeed = GetEntitySpeed(vehicle) * 3.6

        if currentSpeed > speedLimit then
            SetEntityMaxSpeed(vehicle, speedLimit / 3.6)
        else
            SetEntityMaxSpeed(vehicle, 999.0)
        end
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        
        ApplySpeedLimit()
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustReleased(0, 20) then 
            OpenSpeedLimitMenu()
        end
    end
end)
