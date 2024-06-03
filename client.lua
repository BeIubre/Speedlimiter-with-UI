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

        
        local speeds = {}
        for _,v in ipairs(Config.Speed) do
            local speedlabel = "kmh"

            if Config.useMPH then
                speedlabel = "mph"
            end

            local speed = {label = v.. " " ..speedlabel, value = v}
            table.insert(speeds,speed)

        end
        table.insert(speeds,{label = "Benutzerdefiniert", value = "custom"})
        table.insert(speeds,{label = "Deaktivieren", value = "disable"})

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'speed_limit_menu',
        {
            title = "Geschwindigkeitsbegrenzer",
            align = 'top-left',
            elements = speeds
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
        TriggerEvent('notifications', "#780099", Config.NotifyTitle, Config.Mustbeinvehicle)
    end
end

function OpenCustomSpeedDialog()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'custom_speed_dialog',
    {
        title = Config.CustomSpeedMenu
    }, function(data, menu)
        local customSpeed = tonumber(data.value)

        if customSpeed == nil or customSpeed <= 0 then
            TriggerEvent('notifications', "#780099", Config.NotifyTitle, Config.invalidvalue)
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
        TriggerEvent('notifications', "#780099", Config.NotifyTitle, Config.SetSpeed .. limit .. Config.ConfirmSpeed)
        speedLimit = limit
        isSpeedLimitActive = true
        ApplySpeedLimit()
    else
        TriggerEvent('notifications', "#780099", Config.NotifyTitle, Config.alreadyactive)
    end
end

function DisableSpeedLimit()
    if isSpeedLimitActive then
        TriggerEvent('notifications', "#780099", Config.NotifyTitle, Config.disabel)
        isSpeedLimitActive = false
        RemoveSpeedLimit()
    else
        TriggerEvent('notifications', "#780099", Config.NotifyTitle, Config.alreadydisabled)
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
        if Config.useMPH then 
            currentSpeed = GetEntitySpeed(vehicle) * 2.236936
        end

        if currentSpeed > speedLimit then
            if Config.useMPH then
                SetEntityMaxSpeed(vehicle, speedLimit / 2.236936)
            else
                SetEntityMaxSpeed(vehicle, speedLimit / 3.6)
            end
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

        if IsControlJustReleased(0, Config.OpenMenuKey) then 
            OpenSpeedLimitMenu()
        end
    end
end)