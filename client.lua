-- Variables
local QBCore = exports[Config.Core.CoreName]:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData() -- Just for resource restart (same as event handler)
local insideZones = {}

for name in pairs(Config.ExclusiveShops) do
    insideZones[name] = false
end

local testDriveVeh, inTestDrive = 0, false
local ClosestVehicle = 0
local zones = {}

-- \ If Inside Shop get name
local function GetInsideShopInfo()
    for name in pairs(Config.ExclusiveShops) do
        if insideZones[name] then
            return name
        end
    end
    return nil
end

-- \ Drawtext function
local function DrawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

-- \ Set comma value for amount
local function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

local function GetVehicleName()
    return QBCore.Shared.Vehicles[Config.ExclusiveShops[GetInsideShopInfo()].DisplayVehicles[ClosestVehicle].chosenVehicle]["name"]
end

local function GetVehiclePrice()
    return comma_value(QBCore.Shared.Vehicles[Config.ExclusiveShops[GetInsideShopInfo()].DisplayVehicles[ClosestVehicle].chosenVehicle]["price"])
end

local function GetVehicleBrand()
    return QBCore.Shared.Vehicles[Config.ExclusiveShops[GetInsideShopInfo()].DisplayVehicles[ClosestVehicle].chosenVehicle]["brand"]
end

local function SetClosestXvehshopVehicle()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    local closestShop = GetInsideShopInfo()
    for id in pairs(Config.ExclusiveShops[closestShop].DisplayVehicles) do
        local dist2 = #(pos - vector3(Config.ExclusiveShops[closestShop].DisplayVehicles[id].coords.x, Config.ExclusiveShops[closestShop].DisplayVehicles[id].coords.y, Config.ExclusiveShops[closestShop].DisplayVehicles[id].coords.z))
        if current then
            if dist2 < dist then
                current = id
                dist = dist2
            end
        else
            dist = dist2
            current = id
        end
    end
    if current ~= ClosestVehicle then
        ClosestVehicle = current
    end
end

local function CreateTestDriveReturn()
    testDriveZone = BoxZone:Create(
        Config.ExclusiveShops[GetInsideShopInfo()].ReturnLocation,
        3.0,
        5.0,
    {
        name = "Xtestdrive_return_"..GetInsideShopInfo(),
    })

    testDriveZone:onPlayerInOut(function(isPointInside)
        if isPointInside and IsPedInAnyVehicle(PlayerPedId()) then
			SetVehicleForwardSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 0)
            local returnTestDrive = {
                {
                    header = 'Finish Test Drive',
                    params = {
                        event = 'cad-xvehshop:client:TestDriveReturn'
                    }
                }
            }
            exports[Config.Core.MenuName]:openMenu(returnTestDrive)
        else
            exports[Config.Core.MenuName]:closeMenu()
        end
    end)
end

local function InitiateTestDriveTimer(testDriveTime)
    local gameTimer = GetGameTimer()
    CreateThread(function()
        while inTestDrive do
            if GetGameTimer() < gameTimer + tonumber(1000 * testDriveTime) then
                local secondsLeft = GetGameTimer() - gameTimer
                DrawTxt('Test Drive Time Remaining: '..math.ceil(testDriveTime - secondsLeft / 1000), 4, 0.5, 0.93, 0.50, 255, 255, 255, 180)
            end
            Wait(0)
        end
    end)
end

-- \ Create Xvehicle shop zones 
local function CreateXVehZones(shopName, entity)
    if not Config.TargetEnabled then
        for i = 1, #Config.ExclusiveShops[shopName].DisplayVehicles do
            zones[#zones+1] = BoxZone:Create(
                vector3(Config.ExclusiveShops[shopName].DisplayVehicles[i]['coords'].x,
                Config.ExclusiveShops[shopName].DisplayVehicles[i]['coords'].y,
                Config.ExclusiveShops[shopName].DisplayVehicles[i]['coords'].z),
                Config.ExclusiveShops[shopName].Zone.size,
                Config.ExclusiveShops[shopName].Zone.size,
            {
                name = "X"..shopName.."_"..i,
                debugPoly = false,
            })
        end
        local combo = ComboZone:Create(zones, {name = "XvehCombo", debugPoly = false})
        combo:onPlayerInOut(function(isPointInside)
            local insideShop = GetInsideShopInfo()
            if isPointInside then        
                TriggerEvent("cad-xvehshop:client:ShowExlusiveOptions")      
            end
        end)
    else
        exports[Config.Core.TargetName]:AddTargetEntity(entity, {
            options = {
                {
                    type = "client",
                    event = "cad-xvehshop:client:ShowExlusiveOptions",
                    icon = "fas fa-car",
                    label = "Exclusive Options",
                    canInteract = function()
                        local closestShop = GetInsideShopInfo()
                        return closestShop
                    end
                },
            },
            distance = 2.0
        })
    end
end

-- \ Create Xvehicle shop 
function CreateXvehshop(shopShape, name)
    local zone = PolyZone:Create(shopShape, {
        name= name,
        minZ = shopShape.minZ,
        maxZ = shopShape.maxZ
    })

    zone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            insideZones[name] = true
            CreateThread(function()
                while insideZones[name] do
                    SetClosestXvehshopVehicle()
                    vehicleMenu = {
                        {
                            isMenuHeader = true,
                            header = GetVehicleBrand():upper()..' '..GetVehicleName():upper()..' - $'..GetVehiclePrice(),
                        },
                        {
                            header = 'Test Drive',
                            txt = 'Test drive currently selected vehicle',
                            params = {
                                event = 'cad-xvehshop:client:TestDrive',
                            }
                        },
                        {
                            header = "Buy Vehicle",
                            txt = 'Purchase currently selected vehicle',
                            params = {
                                isServer = true,
                                event = 'cad-xvehshop:server:BuyXvehicle',
                                args = {
                                    BuyVehicle = Config.ExclusiveShops[GetInsideShopInfo()].DisplayVehicles[ClosestVehicle].chosenVehicle,
                                    ShopName = GetInsideShopInfo()
                                }
                            }
                        },
                        {
                            header = 'Swap Vehicle',
                            txt = 'Change currently selected vehicle',
                            params = {
                                event = 'cad-xvehshop:client:SwapXvehCategoryMain',
                            }
                        },
                    }
                    Wait(1000)
                end
            end)
        else
            insideZones[name] = false -- leave the shops zone
            ClosestVehicle = 0
        end
    end)
end

for name, shop in pairs(Config.ExclusiveShops) do
    CreateXvehshop(shop.Zone.Shape, name)
end

-- \ Show Xvehicle shop options
RegisterNetEvent('cad-xvehshop:client:ShowExlusiveOptions', function()
    exports[Config.Core.MenuName]:openMenu(vehicleMenu)
end)

-- \ Provide vehicle for testdrive
RegisterNetEvent('cad-xvehshop:client:TestDrive', function()
    if not inTestDrive and ClosestVehicle ~= 0 then
        inTestDrive = true
        local prevCoords = GetEntityCoords(PlayerPedId())
        QBCore.Functions.SpawnVehicle(Config.ExclusiveShops[GetInsideShopInfo()].DisplayVehicles[ClosestVehicle].chosenVehicle, function(veh)
            local closestShop = GetInsideShopInfo()
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            exports[Config.Core.FuelName]:SetFuel(veh, 100)
            SetVehicleNumberPlateText(veh, 'TESTDRIVE')
            SetEntityAsMissionEntity(veh, true, true)
            SetEntityHeading(veh, Config.ExclusiveShops[closestShop].VehicleSpawn.w)
            TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
            TriggerServerEvent('qb-vehicletuning:server:SaveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            testDriveVeh = veh
            QBCore.Functions.Notify('You have '..Config.ExclusiveShops[closestShop].TestDriveTimeLimit..' minutes remaining')
            SetTimeout(Config.ExclusiveShops[closestShop].TestDriveTimeLimit * 60000, function()
                if testDriveVeh ~= 0 then
                    testDriveVeh = 0
                    inTestDrive = false
                    QBCore.Functions.DeleteVehicle(veh)
                    SetEntityCoords(PlayerPedId(), prevCoords)
                    QBCore.Functions.Notify('Vehicle test drive complete')
                end
            end)
        end, Config.ExclusiveShops[GetInsideShopInfo()].VehicleSpawn, false)
        CreateTestDriveReturn()
        InitiateTestDriveTimer(Config.ExclusiveShops[GetInsideShopInfo()].TestDriveTimeLimit * 60)
    else
        QBCore.Functions.Notify('Already in test drive', 'error')
    end
end)

-- \ Return testdrive vehicle
RegisterNetEvent('cad-xvehshop:client:TestDriveReturn', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    if veh == testDriveVeh then
        testDriveVeh = 0
        inTestDrive = false
        QBCore.Functions.DeleteVehicle(veh)
        exports[Config.Core.MenuName]:closeMenu()
        testDriveZone:destroy()
    else
        QBCore.Functions.Notify('This is not your test drive vehicle', 'error')
    end
end)

-- \ Provide vehicle for testdrive
RegisterNetEvent('cad-xvehshop:client:SwapXvehCategoryMain', function()
    local categoryMenu = {
        {
            header = '< Go Back',
            params = {
                event = 'cad-xvehshop:client:ShowExlusiveOptions'
            }
        }
    }
    for k,v in pairs(Config.ExclusiveShops[GetInsideShopInfo()].Categories) do
        categoryMenu[#categoryMenu + 1] = {
            header = v,
            params = {
                event = 'cad-xvehshop:client:SwapXvehCategories',
                args = {
                    catName = k
                }
            }
        }
    end
    exports[Config.Core.MenuName]:openMenu(categoryMenu)
end)

RegisterNetEvent('cad-xvehshop:client:SwapXvehCategories', function(data)
    local vehicleMenu = {
        {
            header = '< Go Back',
            params = {
                event = 'cad-xvehshop:client:SwapXvehCategoryMain'
            }
        }
    }
    for k,v in pairs(QBCore.Shared.Vehicles) do
        if QBCore.Shared.Vehicles[k]["category"] == data.catName and QBCore.Shared.Vehicles[k]["shop"] == GetInsideShopInfo() then
            vehicleMenu[#vehicleMenu + 1] = {
                header = v.name,
                txt = 'Price: $'..v.price,
                params = {
                    isServer = true,
                    event = 'cad-xvehshop:server:SwapXvehicle',
                    args = {
                        toVehicle = v.model,
                        ClosestVehicle = ClosestVehicle,
                        ClosestShop = GetInsideShopInfo()
                    }
                }
            }
        end
    end
    exports[Config.Core.MenuName]:openMenu(vehicleMenu)
end)

RegisterNetEvent('cad-xvehshop:client:SwapXvehicle', function(data)
    local shopName = data.ClosestShop
    if Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].chosenVehicle ~= data.toVehicle then
        local closestVehicle, closestDistance = QBCore.Functions.GetClosestVehicle(vector3(Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].coords.x, Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].coords.y, Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].coords.z))
        if closestVehicle == 0 then return end
        if closestDistance < 5 then QBCore.Functions.DeleteVehicle(closestVehicle) end
        while DoesEntityExist(closestVehicle) do
            Wait(50)
        end
        Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].chosenVehicle = data.toVehicle
        local model = GetHashKey(data.toVehicle)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(50)
        end
        local veh = CreateVehicle(model, Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].coords.x, Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].coords.y, Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].coords.z, false, false)
        while not DoesEntityExist(veh) do
            Wait(50)
        end
        SetModelAsNoLongerNeeded(model)
        SetVehicleOnGroundProperly(veh)
        SetEntityInvincible(veh,true)
        SetEntityHeading(veh, Config.ExclusiveShops[shopName].DisplayVehicles[data.ClosestVehicle].coords.w)
        SetVehicleDoorsLocked(veh, 3)
        FreezeEntityPosition(veh, true)
        SetVehicleNumberPlateText(veh, 'EXCLUSIVE')
        if Config.TargetEnabled then CreateXVehZones(shopName, veh) end
    end
end)

RegisterNetEvent('cad-xvehshop:client:BuyXvehicle', function(vehicle, plate)
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports[Config.Core.FuelName]:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, Config.ExclusiveShops[GetInsideShopInfo()].VehicleSpawn.w)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", QBCore.Functions.GetVehicleProperties(veh))
    end, Config.ExclusiveShops[GetInsideShopInfo()].VehicleSpawn, true)
end)

-- Threads

CreateThread(function()
    for k, v in pairs(Config.ExclusiveShops) do
        if v.showBlip then
            local Dealer = AddBlipForCoord(Config.ExclusiveShops[k].Location)
            SetBlipSprite (Dealer, Config.ExclusiveShops[k].blipSprite)
            SetBlipDisplay(Dealer, 4)
            SetBlipScale  (Dealer, 0.70)
            SetBlipAsShortRange(Dealer, true)
            SetBlipColour(Dealer, Config.ExclusiveShops[k].blipColor)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Config.ExclusiveShops[k].ShopLabel)
            EndTextCommandSetBlipName(Dealer)
        end
    end
end)

CreateThread(function()
    for k in pairs(Config.ExclusiveShops) do
        for i = 1, #Config.ExclusiveShops[k].DisplayVehicles do
            local model = GetHashKey(Config.ExclusiveShops[k].DisplayVehicles[i].defaultVehicle)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            local veh = CreateVehicle(model, Config.ExclusiveShops[k].DisplayVehicles[i].coords.x, Config.ExclusiveShops[k].DisplayVehicles[i].coords.y, Config.ExclusiveShops[k].DisplayVehicles[i].coords.z, false, false)
            SetModelAsNoLongerNeeded(model)
            SetEntityAsMissionEntity(veh, true, true)
            SetVehicleOnGroundProperly(veh)
            SetEntityInvincible(veh,true)
            SetVehicleDirtLevel(veh, 0.0)
            SetVehicleDoorsLocked(veh, 3)
            SetEntityHeading(veh, Config.ExclusiveShops[k].DisplayVehicles[i].coords.w)
            FreezeEntityPosition(veh,true)
            SetVehicleNumberPlateText(veh, 'EXCLUSIVE')
            if Config.TargetEnabled then CreateXVehZones(k, veh) end
        end
        if not Config.TargetEnabled then CreateXVehZones(k) end
    end
end)
