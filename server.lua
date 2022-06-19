-- \ Core Export
local QBCore = exports[Config.Core.CoreName]:GetCoreObject()

-- \ Function which generates plate numbers
function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM '..Config.Core.VehiclesTable..' WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

-- \ Buy Vehicle
function BuyXVehicle(src, pData, price, vehicle, plate)
    if pData.PlayerData.money['cash'] > price then
        MySQL.insert('INSERT INTO '..Config.Core.VehiclesTable..' (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {pData.PlayerData.license, pData.PlayerData.citizenid, vehicle, GetHashKey(vehicle), '{}', plate, 0})
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('cad-xvehshop:client:BuyXvehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('cash', price, 'vehicle-bought-exclusive')
    elseif pData.PlayerData.money['bank'] > price then
        MySQL.insert('INSERT INTO '..Config.Core.VehiclesTable..' (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {pData.PlayerData.license, pData.PlayerData.citizenid, vehicle, GetHashKey(vehicle), '{}', plate, 0})
        TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your purchase!', 'success')
        TriggerClientEvent('cad-xvehshop:client:BuyXvehicle', src, vehicle, plate)
        pData.Functions.RemoveMoney('bank', price, 'vehicle-bought-exclusive')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
    end
end

-- \ Discord Role Request
local BotToken = "Bot "..Config.Discord.BotToken
function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = BotToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

-- \ Get player discord roles
function CheckPlayerRole(user, role)
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

-- \ Get Priority level of a user
exports("GetPriority", function(src)
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
        MySQL.scalar('SELECT priority FROM '..Config.Core.Players..' WHERE license = ?', {pData.PlayerData.license}, function(level) 
            priority = level
        end)
    end
    Wait(10)
    return priority
end)

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
    local isexclusivemember = false    
    if Config.Discord.Enabled then
        if (category == "level1") and (CheckPlayerRole(src, Config.Discord.Tiers[1].name) or CheckPlayerRole(src, Config.Discord.Tiers[2].name) or CheckPlayerRole(src, Config.Discord.Tiers[3].name)) then    
            isexclusivemember = true
        elseif (category == "level2") and (CheckPlayerRole(src, Config.Discord.Tiers[2].name) or CheckPlayerRole(src, Config.Discord.Tiers[3].name)) then
            isexclusivemember = true
        elseif (category == "level3") and CheckPlayerRole(src, Config.Discord.Tiers[3].name) then
            isexclusivemember = true        
        end	
        if isexclusivemember then
            BuyXVehicle(src, pData, price, vehicle, plate)
        else
            TriggerClientEvent("QBCore:Notify", src, "You dont have "..Config.ExclusiveShops[shop].Categories[category].." membership", "error")
        end
    else
        MySQL.scalar('SELECT priority FROM '..Config.Core.Players..' WHERE license = ?', {pData.PlayerData.license}, function(level) 
            -- [[Here Prio is Category & level is number in SQL]]			
            if (category == "level1") and (level == 1 or level == 2 or level == 3) then
                isexclusivemember = true
            elseif (category == "level2") and (level == 2 or level == 3) then
                isexclusivemember = true
            elseif (category == "level3") and (level == 3) then              
                isexclusivemember = true
            end
            if isexclusivemember then
                BuyXVehicle(src, pData, price, vehicle, plate)
            else
                TriggerClientEvent("QBCore:Notify", src, "You dont have "..Config.ExclusiveShops[shop].Categories[category].." membership", "error")
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
            MySQL.update('UPDATE '..Config.Core.Players..' SET priority = ? WHERE license = ?', {tonumber(args[2]), xPlayer.PlayerData.license})				
            TriggerClientEvent("QBCore:Notify", source, "Given Priority to ["..args[1].."] ")
            TriggerClientEvent("QBCore:Notify", args[1], "You were given Priority of level: ["..args[2].."].")	
        else
            TriggerClientEvent("QBCore:Notify", source, "Invalid Input")			
        end
    end, "admin")
end