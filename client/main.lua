
local spawnedObjects = {}
local imageDisplayed = false

RegisterNetEvent('pl_printer:notification')
AddEventHandler('pl_printer:notification', function(message, ntype)
    exports.pl_lib:Notify('Printer', message, ntype or 'success')
end)

function disableControls()
    SetEntityInvincible(PlayerPedId(), true)
    FreezeEntityPosition(PlayerPedId(), true)
end

function enableControls()
    SetEntityInvincible(PlayerPedId(), false)
    FreezeEntityPosition(PlayerPedId(), false)
end

RegisterNetEvent('pl_printer:showImage')
AddEventHandler('pl_printer:showImage', function(imageName)
    if not imageDisplayed then
        imageDisplayed = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action   = 'show',
            imageUrl = imageName
        })
        disableControls()
    end
end)

RegisterNUICallback('hideFrame', function(data, cb)
    imageDisplayed = false
    SetNuiFocus(false, false)
    enableControls()
    cb({})
end)

-- Local event only — triggered by target interaction, not via network
AddEventHandler('pl_printer:openprinter', function()
    local input = exports.pl_lib:ShowInputDialog(Locale('print_menu'), {
        {
            type        = 'input',
            label       = Locale('image_link'),
            description = Locale('image_url'),
            required    = true,
        },
        {
            type        = 'number',
            label       = Locale('copies'),
            description = Locale('enter_copies'),
            required    = true,
            placeholder = '1',
            icon        = 'hashtag',
        },
    }, Locale('submit'))

    if not input then
        _debug('[DEBUG] No input received')
        return
    end

    local imageLink, copies = input[1], input[2]

    if imageLink and copies then
        TriggerServerEvent('pl_printer:insertImageData', imageLink, copies)
    else
        _debug('[DEBUG] Invalid input values')
    end
end)


for _, model in ipairs(Config.PrinterModel) do
    exports.pl_lib:AddModelTarget(model, {
        {
            name     = 'printer_interaction',
            icon     = 'fa-solid fa-print',
            label    = Locale('prints'),
            event    = 'pl_printer:openprinter',
            distance = 2.0,
        }
    })
end


local function spawnObject(object, coords, heading)
    if not exports.pl_lib:EnsureModel(object) then
        _debug('[DEBUG] ' .. tostring(object) .. ' failed to load.')
        return
    end
    local entity = CreateObject(object, coords.x, coords.y, coords.z, true, true, true)

    if DoesEntityExist(entity) then
        SetEntityHeading(entity, heading)
        FreezeEntityPosition(entity, true)
        table.insert(spawnedObjects, entity)
    else
        _debug('[DEBUG] Failed to spawn object: ' .. tostring(object))
    end
end


local function deleteSpawnedObjects()
    for _, obj in ipairs(spawnedObjects) do
        if DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end
    spawnedObjects = {}
end


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, location in ipairs(Config.Locations) do
        spawnObject(location.object, location.coords, location.heading)
    end
end)


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    deleteSpawnedObjects()
end)

function onPlayerLoaded()
    Wait(3000)
    for _, location in ipairs(Config.Locations) do
        spawnObject(location.object, location.coords, location.heading)
    end
end

AddEventHandler('esx:playerLoaded', function() onPlayerLoaded() end)
AddEventHandler('QBCore:Client:OnPlayerLoaded', function() onPlayerLoaded() end)

function _debug(...)
    if Config.Debug then
        print(...)
    end
end
