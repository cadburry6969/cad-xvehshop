-- \ Core Export
local QBCore = exports[Config.CoreExport]:GetCoreObject()
local PriorityMethod = Config.PriorityMethod

-- \ Generates plate numbers
function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

-- \ Discord get requestData
local bottoken = "Bot "..Discord.BotToken
function GetDiscord(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = bottoken})
    while data == nil do
        Wait(0)
    end
    return data
end

-- \ Get player discord roles
function CheckPlayerRole(user, roleid, category)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			break
		end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(Discord.ServerId, discordId)
		local member = GetDiscord("GET", endpoint, {})
        local userrole = Discord.Tiers[roleid].roleid
        local useraccess = Discord.Tiers[roleid].canaccess
		if member.code == 200 then
			local data = json.decode(member.data)
            local roles = data.roles
			for i=1, #roles do
				if roles[i] == userrole then
                    if category then
                        for _, cat in pairs(useraccess) do
                            if cat == category then
                                return true
                            end
                        end
                        return false
                    end
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

-- \ Has priority and returns level
exports("GetPriority", function(src)
    if PriorityMethod == "discord" then
        for i=1, #Discord.Tiers do
            if CheckPlayerRole(src, i) then
                return true, i
            end
        end
        return false, 0
    elseif PriorityMethod == "sql" then
        local license = QBCore.Functions.GetIdentifier(src, "license")
        local result = MySQL.scalar.await('SELECT priority FROM players WHERE license = ? LIMIT 1', {license})
        if result then
            result = json.decode(result)
            return true, result.prio
        end
        return false, 0
    else
        print("^2`Config.PriorityMethod` is not set properly in `config.lua`")
    end
end)

-- \ Get Priority level of a user
function HasAccessToCategory(src, category)
    if PriorityMethod == "discord" then
        for i=1, #Discord.Tiers do
            if CheckPlayerRole(src, i, category) then
                return true
            end
        end
        return false
    elseif PriorityMethod == "sql" then
        local license = QBCore.Functions.GetIdentifier(src, "license")
        local result = MySQL.scalar.await('SELECT priority FROM players WHERE license = ? LIMIT 1', {license})
        if result then
            result = json.decode(result)
            for _, level in ipairs(result.canaccess) do
                if level == category then
                    return true
                end
            end
        end
        return false
    else
        print("^2`Config.PriorityMethod` is not set properly in `config.lua`")
    end
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
    if HasAccessToCategory(src, category) then
        if pData.PlayerData.money['bank'] > price then
            MySQL.prepare('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {pData.PlayerData.license, pData.PlayerData.citizenid, vehicle, GetHashKey(vehicle), '{}', plate, 0})
            TriggerClientEvent('cad-xvehshop:notify', src, 'Congratulations on your purchase!', 'success')
            TriggerClientEvent('cad-xvehshop:client:BuyXvehicle', src, vehicle, plate)
            pData.Functions.RemoveMoney('bank', price, 'vehicle-bought-exclusive')
        else
            TriggerClientEvent('cad-xvehshop:notify', src, 'You dont have enough money in bank', 'error')
        end
    else
        TriggerClientEvent("cad-xvehshop:notify", src, "You dont have "..Config.ExclusiveShops[shop].Categories[category].." membership", "error")
    end
end)

-- \ Spawn vehicle callback
QBCore.Functions.CreateCallback('cad-xvehshop:spawnVehicle', function(source, cb, model, coords, warp)
    local ped = GetPlayerPed(source)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then while GetVehiclePedIsIn(ped) ~= veh do Wait(0) TaskWarpPedIntoVehicle(ped, veh, -1) end end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

if PriorityMethod == "sql" then
    RegisterCommand("priority_add", function(source, args)
        local pid = tonumber(args[1])
        local plevel = tonumber(args[2])
        local identifier = QBCore.Functions.GetIdentifier(pid, "license")
        local canaccess = {}
        for i=1, #args, 1 do
            if i > 2 then
                canaccess[#canaccess+1] = args[i]
            end
        end
        if identifier then
            local priority = {
                prio = plevel,
                canaccess = canaccess,
            }
            MySQL.insert("UPDATE players SET priority = ? WHERE license = ?",{json.encode(priority), identifier})
        end
    end, true)
    RegisterCommand("priority_get", function (source, args)
        local pid = tonumber(args[1])
        local license = QBCore.Functions.GetIdentifier(pid, "license")
        local result = MySQL.scalar.await('SELECT priority FROM players WHERE license = ? LIMIT 1', {license})
        if result then
            result = json.decode(result)
            print("level", result.prio)
            for _, level in ipairs(result.canaccess) do
                print(level)
            end
        end
    end, true)
end
