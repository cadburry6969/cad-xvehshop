Config = {}

-- \ Use Target
Config.TargetEnabled = true -- [qb-target] 

-- \ Core Config
Config.Core = {
    CoreName = 'qb-core',             -- default: qb-core
    TargetName = 'qb-target',         -- default: qb-target
    MenuName = 'qb-menu',             -- default: qb-menu
    FuelName = 'LegacyFuel',          -- default: LegacyFuel
    Players = 'players',              -- default: players
    VehiclesTable = 'player_vehicles',-- default: player_vehicles
}

-- \ Discord Priority
Config.Discord = {
    Enabled = false, -- Enable/Disable Discord Integration
	BotToken = "",   -- Discord Bot Token
	ServerId = "",   -- Discord Server Id
	Tiers = {        -- Discord Role Tiers
        [1] = {name= "Bronze", roleid = ""}, -- Role Name | Role Id
        [2] = {name= "Silver", roleid = ""}, -- Role Name | Role Id
        [3] = {name= "Gold", roleid = ""}    -- Role Name | Role Id
	},
}

-- \ Plate Config
-- Dont Change if you dont know what you are doing
local QBCore = exports[Config.Core.CoreName]:GetCoreObject()
Config.PlateFormat = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)

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
        Location = vector3(-65.9, 70.24, 71.16),             -- Shop Location (Blip)
        ReturnLocation = vector4(-65.92, 81.35, 70.96, 63.77), -- Return TestDrive Location
        VehicleSpawn = vector4(-65.92, 81.35, 70.96, 63.77), -- Vehicle Spawn Location
        Zone = {  -- POLYZONE OF XVEHSHOP
            Shape = {
                vector2(-82.552360534668, 72.565864562988),
                vector2(-77.091873168945, 82.027137756348),
                vector2(-85.495170593262, 86.323265075684),
                vector2(-81.75853729248, 93.844581604004),
                vector2(-48.251068115234, 79.176368713379),
                vector2(-55.44372177124, 61.411182403564),
                vector2(-61.096984863281, 60.024063110352)
            },
            minZ = 71.519561767578,
            maxZ = 72.743873596191,
            size = 2.75,
        },
        DisplayVehicles = {  -- Vehicles to display (also used to swap vehicle)
            [1] = {
                coords = vector4(-75.91, 74.98, 71.3, 237.18), -- Vehicle Spawn Location
                defaultVehicle = 'police', -- Default Vehicle (chnage this)
                chosenVehicle = 'police', -- Chosen Vehicle (change this)
            },
        }
    }
}