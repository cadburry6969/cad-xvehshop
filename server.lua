-- \ Core Export
local QBCore = exports[Config.Core.CoreName]:GetCoreObject()

-- \ Function which generates plate numbers
local function GeneratePlate()
    local plate = Config.PlateFormat
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM '..Config.Core.VehiclesTable..' WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

-- \ Buy Vehicle
local function BuyXVehicle(src, pData, price, vehicle, plate)
    if pData.PlayerData.money['cash'] > price then
        MySQL.Async.insert('INSERT INTO '..Config.Core.VehiclesTable..' (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {pData.PlayerData.license, pData.PlayerData.citizenid, vehicle, GetHashKey(vehicle), '{}', plate, 0})
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('cad-xvehshop:client:BuyXvehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('cash', price, 'vehicle-bought-exclusive')
    elseif pData.PlayerData.money['bank'] > price then
        MySQL.Async.insert('INSERT INTO '..Config.Core.VehiclesTable..' (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {pData.PlayerData.license, pData.PlayerData.citizenid, vehicle, GetHashKey(vehicle), '{}', plate, 0})
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('cad-xvehshop:client:BuyXvehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('bank', price, 'vehicle-bought-exclusive')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
    end
end

-- \ Discord Role Request
local FormattedToken = "Bot "..Config.Discord.BotToken
local function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

-- \ Get player discord roles
local function CheckPlayerRole(user, role)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			break
		end
	end

	local theRole = nil
	if type(role) == "number" then
		theRole = tostring(role)
	else
        for i=1, #Config.Discord.Tiers do
            if Config.Discord.Tiers[i].name == role then
                theRole = Config.Discord.Tiers[i].roleid
                break
            end
        end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(Config.Discord.ServerId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			for i=1, #roles do
				if roles[i] == theRole then
					return true
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

-- \ Get Priority of a user
local function GetPriority(src)
    local pData = QBCore.Functions.GetPlayer(src)
    local priority = 0
    if Config.Discord.Enabled then
        if CheckPlayerRole(src, Config.Discord.Tiers[1].name) then
            priority = 1
        elseif CheckPlayerRole(src, Config.Discord.Tiers[2].name) then
            priority = 2
        elseif CheckPlayerRole(src, Config.Discord.Tiers[3].name) then
            priority = 3
        end
    else
        MySQL.Async.fetchScalar('SELECT priority FROM players WHERE license = @license', {['@license'] = pData.PlayerData.license}, function(level) 
            priority = level
        end)
    end
    Config.Discord.Tiers[priority].name = nil
    return priority
end

-- \ Swap vehicle sync to others
RegisterNetEvent('cad-xvehshop:server:SwapXvehicle', function(data)
    local src = source
    TriggerClientEvent('cad-xvehshop:client:SwapXvehicle', -1, data)
    Wait(1500)
    TriggerClientEvent('cad-xvehshop:client:ShowExlusiveOptions', src)
end)

-- \ Check prio and buy vehicle
RegisterNetEvent('cad-xvehshop:server:BuyXvehicle', function(data)
    local src = source
    local vehicle = data.BuyVehicle
    local shop = data.ShopName
    local pData = QBCore.Functions.GetPlayer(src)
    local price = QBCore.Shared.Vehicles[vehicle]['price']
    local category = QBCore.Shared.Vehicles[vehicle]['category']
    local plate = GeneratePlate()
    if Config.Discord.Enabled then
        if (category == "level1") and (CheckPlayerRole(src, Config.Discord.Tiers[1].name) or CheckPlayerRole(src, Config.Discord.Tiers[2].name) or CheckPlayerRole(src, Config.Discord.Tiers[3].name)) then    
            BuyXVehicle(src, pData, price, vehicle, plate)
        elseif (category == "level2") and (CheckPlayerRole(src, Config.Discord.Tiers[2].name) or CheckPlayerRole(src, Config.Discord.Tiers[3].name)) then
            BuyXVehicle(src, pData, price, vehicle, plate)
        elseif (category == "level3") and CheckPlayerRole(src, Config.Discord.Tiers[3].name) then
            BuyXVehicle(src, pData, price, vehicle, plate)
        else
            TriggerClientEvent("QBCore:Notify", src, "You are not a exclusive member", "error")
        end	
    else
        MySQL.Async.fetchScalar('SELECT priority FROM players WHERE license = @license', {['@license'] = pData.PlayerData.license}, function(level) 
            -- [[Here Prio is Category & level is number in SQL]]			
            if (category == "level1") and (level == 1 or level == 2 or level == 3) then
                BuyXVehicle(src, pData, price, vehicle, plate)
            elseif (category == "level2") and (level == 2 or level == 3) then
                BuyXVehicle(src, pData, price, vehicle, plate)
            elseif (category == "level3") and (level == 3) then              
                BuyXVehicle(src, pData, price, vehicle, plate)
            else
                TriggerClientEvent("QBCore:Notify", src, "You are not a exclusive member", "error")
            end
        end)
    end    
end)

-- \ Give Priority Cmd For Admins (SQL ONLY)
if not Config.Discord.Enabled then	
    QBCore.Commands.Add('givepriority', 'Provide Someone with priority', {{name='id', help='Player ID'}, {name='prio', help='Prio Level'}}, false, function(source, args)
        local Self = QBCore.Functions.GetPlayer(source)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
        if args[1] ~= nil or args[2] ~= nil then
            MySQL.Async.execute('UPDATE players SET priority = @priority WHERE license = @license', {['license']  = xPlayer.PlayerData.license,['priority'] = tonumber(args[2])})				
            TriggerClientEvent("QBCore:Notify", source, "Given Priority to ["..args[1].."] ")
            TriggerClientEvent("QBCore:Notify", args[1], "You were given Priority of level: ["..args[2].."].")	
        else
            TriggerClientEvent("QBCore:Notify", source, "Invalid Input")			
        end
    end, "admin")
end