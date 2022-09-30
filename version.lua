CreateThread(function()
    Wait(5000)
    local function ToNumber(cd) return tonumber(cd) end
    local resource_name = GetCurrentResourceName()
    local current_version = GetResourceMetadata(resource_name, 'version', 0)
    PerformHttpRequest('https://raw.githubusercontent.com/cadburry6969/cadburry-tebex-version/master/cad-xvehshop',function(error, result, headers)
        if not result then print('^1Version check disabled because github is down.^0') return end
        local result = json.decode(result:sub(1, -2))
        if ToNumber(result.version:gsub('%.', '')) > ToNumber(current_version:gsub('%.', '')) then
            print('^2['..resource_name..'] New Update Available.^0\nCurrent Version: ^5'..current_version..'^0.\nNew Version: ^5'..result.version..'^0.\nChangelogs: ^5'..result.notes..'^0.')
        elseif ToNumber(result.version:gsub('%.', '')) == ToNumber(current_version:gsub('%.', '')) then
            print('^2['..resource_name..'] running on latest version^0.')
        end
    end,'GET')
end)