Config = {}

-- \ Core resource name
Config.CoreExport = 'qb-core'      -- default: qb-core
-- \ Fuel resource name
Config.FuelExport = 'LegacyFuel'   -- default: LegacyFuel

-- \ Choose the PriorityMethod you want to fetch/save data
-- \ Remember if you choose discord then make sure you edit `config_discord.lua`
Config.PriorityMethod = 'sql' -- "discord", "sql"

-- \ Notification (Client Side Function)
SendNotification = function(msg, type)
    TriggerEvent("QBCore:Notify", msg, type)
end

-- \ Exclusive Shops
Config.ExclusiveShops = {
    ['exclusive'] = {
        ShopLabel = 'Exclusive Dealer Motorsport',           -- Shop Blip Label
        showBlip = true,                                     -- Shop Blip Display(Show/Not Show)
        blipSprite = 326,                                    -- Shop Blip Sprite
        blipColor = 3,                                       -- Shop Blip Colour
        Categories = {
            ['level1'] = 'Bronze',                           -- Category Name | Label (can be anything)
            ['level2'] = 'Silver',                           -- Category Name | Label (can be anything)
            ['level3'] = 'Gold',                             -- Category Name | Label (can be anything)
        },
        TestDriveTimeLimit = 0.6,                            -- Test Drive Time Limit
        Location = vector3(-1257.6, -367.5, 36.91),             -- Shop Location (Blip)
        ReturnLocation = vector4(-1233.5, -346.44, 37.33, 24.63), -- Return TestDrive Location
        VehicleSpawn = vector4(-1233.5, -346.44, 37.33, 24.63), -- Vehicle Spawn Location
        Zone = {  -- POLYZONE OF XVEHSHOP
            Shape = {
                vector2(-1234.1281738281, -335.5260925293),
                vector2(-1225.7338867188, -352.52774047852),
                vector2(-1267.3453369141, -376.65267944336),
                vector2(-1275.6800537109, -359.98114013672),
                vector2(-1271.9147949219, -354.57739257813)
            },
            minZ = 36.509433746338,
            maxZ = 37.332794189453,
            size = 2.75,
        },
        DisplayPlate = "EXCLUSIVE",
        DisplayVehicles = {  -- Vehicles to display (also used to swap vehicle)
            [1] = {
                coords = vector4(-1270.26, -358.7, 36.3, 249.95), -- Vehicle Spawn Location
                defaultVehicle = 'asbo', -- Default Vehicle (change this)
                chosenVehicle = 'asbo', -- Chosen Vehicle (change this)
            },
            [2] = {
                coords = vector4(-1268.83, -364.72, 36.3, 295.29), -- Vehicle Spawn Location
                defaultVehicle = 'blista', -- Default Vehicle (change this)
                chosenVehicle = 'blista', -- Chosen Vehicle (change this)
            },
            [3] = {
                coords = vector4(-1265.28, -354.75, 36.3, 205.81), -- Vehicle Spawn Location
                defaultVehicle = 'brioso', -- Default Vehicle (change this)
                chosenVehicle = 'brioso', -- Chosen Vehicle (change this)
            },
        }
    }
}